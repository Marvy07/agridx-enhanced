import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/services/gemini_service.dart';
import '../../shared/services/diagnosis_service.dart';
import '../library/crops_data.dart';
import '../chat/chat_screen.dart';
import '../diagnosis/diagnosis_result_screen.dart';
import '../../core/connectivity_provider.dart';

class CropScanScreen extends ConsumerStatefulWidget {
  final String? initialCropName;
  
  const CropScanScreen({super.key, this.initialCropName});

  @override
  ConsumerState<CropScanScreen> createState() => _CropScanScreenState();
}

class _CropScanScreenState extends ConsumerState<CropScanScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _flashOn = false;
  String? _errorMessage;
  String _selectedCropFilter = 'Auto';

  @override
  void initState() {
    super.initState();
    final isOnline = ref.read(connectivityProvider) == ConnectivityStatus.online;
    if (isOnline) {
      _selectedCropFilter = 'Auto';
    } else {
      _selectedCropFilter = widget.initialCropName ?? 'Auto';
    }
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _errorMessage = 'No cameras found on this device.');
        return;
      }
      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _errorMessage = 'Camera error: ${e.toString()}');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _isInitialized = false;
      ctrl.dispose();
      if (mounted) {
        setState(() {});
      }
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    setState(() => _flashOn = !_flashOn);
    await _controller!.setFlashMode(
      _flashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;
    try {
      final file = await _controller!.takePicture();
      Uint8List? bytes;
      if (kIsWeb) {
        bytes = await file.readAsBytes();
      }
      if (!mounted) return;
      _showPreview(file, bytes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not capture image: $e')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked == null) return; // user cancelled
      if (!mounted) return;

      Uint8List? bytes;
      if (kIsWeb) {
        bytes = await picked.readAsBytes();
      }

      // Reuse same preview flow as camera capture
      _showPreview(XFile(picked.path), bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open gallery: $e')),
      );
    }
  }

  void _showNotACropDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Text('🌿', style: TextStyle(fontSize: 48)),
        title: const Text('Not a Crop Image',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.5)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showPreview(XFile file, Uint8List? bytes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CapturedImageSheet(
        file: file,
        imageBytes: bytes,
        onRetake: () {
          Navigator.pop(ctx);
        },
        onAnalyze: () async {
          Navigator.pop(ctx);
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
          );

          try {
            Uint8List? fileBytes = bytes;
            if (!kIsWeb && file.path.isNotEmpty && fileBytes == null) {
              fileBytes = await File(file.path).readAsBytes();
            }

            if (fileBytes == null) {
               throw Exception('Could not read image data.');
            }

            // ── Validate image before analysis ──
            final validationError = DiagnosisService.validateImage(fileBytes);
            if (validationError != null) {
              if (!mounted) return;
              Navigator.pop(context); // close loading
              _showNotACropDialog(validationError);
              return;
            }

            final connectivity = ref.read(connectivityProvider);
            final isOffline = connectivity == ConnectivityStatus.offline;

            if (isOffline) {
              // Offline Flow: TFLite offline inference
              final results = await DiagnosisService.diagnose(fileBytes, cropFilter: _selectedCropFilter);
              
              if (!mounted) return;
              Navigator.pop(context); // Close loading
              
              if (results.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not generate diagnosis offline.'), backgroundColor: Colors.red[700]),
                );
                return;
              }

              final topResult = results.first;
              final rawLabel = topResult['label'] as String;
              final confidenceVal = topResult['confidenceValue'] as double;
              
              if (!kIsWeb && confidenceVal < 0.50) {
                _showNotACropDialog(
                  'The AI could not confidently identify a crop in this image '
                  '(${(confidenceVal * 100).toStringAsFixed(0)}% confidence).\n\n'
                  'For best results:\n'
                  '- Hold the leaf close to fill the frame\n'
                  '- Ensure good lighting\n'
                  '- Scan the leaf side, not the background',
                );
                return;
              }

              final isHealthy = rawLabel.toLowerCase().contains('healthy');

              final displayName = isHealthy
                  ? 'Healthy Leaf — No Disease Detected'
                  : DiagnosisService.formatDiseaseName(rawLabel);
              final displayCrop = isHealthy
                  ? 'Your Crop'
                  : rawLabel.split('___').first.replaceAll('_', ' ');
              final severity = isHealthy ? null : DiagnosisService.getSeverity(confidenceVal);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DiagnosisResultScreen(
                    diseaseName: displayName,
                    confidence: confidenceVal * 100,
                    cropName: displayCrop,
                    imagePath: file.path,
                    topPredictions: results,
                    severity: severity,
                  ),
                ),
              );
            } else {
              // Online Flow: AI Diagnosis using Gemini Vision
              try {
                final result = await ref.read(geminiServiceProvider).getVisionDiagnosis(fileBytes);
                if (!mounted) return;
                Navigator.pop(context); // Close loading
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiagnosisResultScreen(
                      diseaseName: result['diseaseName'],
                      confidence: result['confidence'],
                      cropName: 'Crop',
                      imagePath: file.path,
                      imageBytes: fileBytes,
                      initialData: result,
                    ),
                  ),
                );
              } catch (e) {
                print('Gemini Vision failed. Falling back to offline diagnosis. Error: $e');
                
                // Fallback to offline DiagnosisService
                final results = await DiagnosisService.diagnose(fileBytes, cropFilter: _selectedCropFilter);
                if (!mounted) return;
                Navigator.pop(context); // Close loading
                
                if (results.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not generate diagnosis offline.'), backgroundColor: Colors.red[700]),
                  );
                  return;
                }

                final topResult = results.first;
                final rawLabel = topResult['label'] as String;
                final confidenceVal = topResult['confidenceValue'] as double;

                if (!kIsWeb && confidenceVal < 0.50) {
                  _showNotACropDialog(
                    'The AI could not confidently identify a crop in this image '
                    '(${(confidenceVal * 100).toStringAsFixed(0)}% confidence).\n\n'
                    'For best results:\n'
                    '- Hold the leaf close to fill the frame\n'
                    '- Ensure good lighting\n'
                    '- Scan the leaf side, not the background',
                  );
                  return;
                }

                final isHealthy = rawLabel.toLowerCase().contains('healthy');

                final displayName = isHealthy
                    ? 'Healthy Leaf — No Disease Detected'
                    : DiagnosisService.formatDiseaseName(rawLabel);
                final displayCrop = isHealthy
                    ? 'Your Crop'
                    : rawLabel.split('___').first.replaceAll('_', ' ');
                final severity = isHealthy ? null : DiagnosisService.getSeverity(confidenceVal);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiagnosisResultScreen(
                      diseaseName: displayName,
                      confidence: confidenceVal * 100,
                      cropName: displayCrop,
                      imagePath: file.path,
                      topPredictions: results,
                      severity: severity,
                    ),
                  ),
                );
              }
            }
          } catch (e) {
            if (!mounted) return;
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Diagnosis failed: $e'),
                backgroundColor: Colors.red[700],
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_enhance, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview fills screen
        CameraPreview(_controller!),

        // Scanning frame overlay
        _buildScanFrame(),

        // Top controls
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  _overlayButton(
                    Icons.arrow_back,
                    () => Navigator.pop(context),
                  ),
                  // Flash toggle
                  _overlayButton(
                    _flashOn ? Icons.flash_on : Icons.flash_off,
                    _toggleFlash,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Right side "Ask anything" floating bubble (Mockup for future AI chat)
        Positioned(
          right: 16,
          top: MediaQuery.of(context).size.height * 0.35,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Ask anything',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                  child: const Center(
                    child: Text('AI',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Crop Filter Selection
        Positioned(
          bottom: 110,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildCropFilterChip('Auto', '🎯'),
                ...availableCrops.map((c) => _buildCropFilterChip(c.name, c.emoji)),
              ],
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 24, left: 48, right: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gallery button — pick from phone gallery
                  GestureDetector(
                    onTap: _pickFromGallery,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.photo_library_outlined,
                          color: Colors.white, size: 26),
                    ),
                  ),

                  // Shutter button
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scaleXY(begin: 1.0, end: 1.05, duration: 1500.ms, curve: Curves.easeInOut),
                  ),

                  // Help button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.help_outline,
                        color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanFrame() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.78,
        height: MediaQuery.of(context).size.height * 0.55,
        child: CustomPaint(painter: _ScanFramePainter()),
      ),
    );
  }

  Widget _overlayButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildCropFilterChip(String name, String emoji) {
    final isSelected = _selectedCropFilter == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCropFilter = name;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B5E20) : Colors.black54,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? Colors.greenAccent : Colors.white38),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Scan Frame Painter ──────────────────────────────────────────────────────

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 32.0;
    const r = 20.0; // corner radius

    final w = size.width;
    final h = size.height;

    // Top-left corner
    canvas.drawLine(Offset(0, r + cornerLen), Offset(0, r), paint);
    canvas.drawArc(Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14, 1.57, false, paint);
    canvas.drawLine(Offset(r, 0), Offset(r + cornerLen, 0), paint);

    // Top-right corner
    canvas.drawLine(Offset(w - r - cornerLen, 0), Offset(w - r, 0), paint);
    canvas.drawArc(
        Rect.fromLTWH(w - r * 2, 0, r * 2, r * 2), 4.71, 1.57, false, paint);
    canvas.drawLine(Offset(w, r), Offset(w, r + cornerLen), paint);

    // Bottom-left corner
    canvas.drawLine(
        Offset(0, h - r - cornerLen), Offset(0, h - r), paint);
    canvas.drawArc(Rect.fromLTWH(0, h - r * 2, r * 2, r * 2), 1.57, 1.57,
        false, paint);
    canvas.drawLine(Offset(r, h), Offset(r + cornerLen, h), paint);

    // Bottom-right corner
    canvas.drawLine(
        Offset(w - r - cornerLen, h), Offset(w - r, h), paint);
    canvas.drawArc(
        Rect.fromLTWH(w - r * 2, h - r * 2, r * 2, r * 2), 0, 1.57,
        false, paint);
    canvas.drawLine(Offset(w, h - r - cornerLen), Offset(w, h - r), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Captured Image Preview Sheet ────────────────────────────────────────────

class _CapturedImageSheet extends StatelessWidget {
  final XFile file;
  final Uint8List? imageBytes;
  final VoidCallback onRetake;
  final VoidCallback onAnalyze;

  const _CapturedImageSheet({
    required this.file,
    this.imageBytes,
    required this.onRetake,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: kIsWeb && imageBytes != null
                  ? Image.memory(
                      imageBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Image.file(
                      File(file.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAnalyze,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Analyse Crop',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onRetake,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Retake Photo',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
