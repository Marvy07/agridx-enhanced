import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/gemini_service.dart';
import '../../core/connectivity_provider.dart';
import '../../core/offline_disease_database.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/services/diagnosis_history_service.dart';
import '../../shared/models/diagnosis_history_model.dart';

class DiagnosisResultScreen extends ConsumerStatefulWidget {
  final String diseaseName;
  final double confidence;
  final String cropName;
  final String imagePath;
  final Uint8List? imageBytes;
  final Map<String, dynamic>? initialData;
  final List<Map<String, dynamic>>? topPredictions;
  final String? severity;
  final bool isFromHistory;

  const DiagnosisResultScreen({
    super.key,
    required this.diseaseName,
    required this.confidence,
    required this.cropName,
    required this.imagePath,
    this.imageBytes,
    this.initialData,
    this.topPredictions,
    this.severity,
    this.isFromHistory = false,
  });

  @override
  ConsumerState<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends ConsumerState<DiagnosisResultScreen> {
  Map<String, dynamic>? _aiData;
  bool _isLoadingAi = false;
  String? _aiError;
  String? _diagnosisId;

  @override
  void initState() {
    super.initState();
    _aiData = widget.initialData;
    
    if (widget.isFromHistory && _aiData == null) {
      final offlineData = _getOfflineData();
      if (offlineData != null) {
        _aiData = {
          ...offlineData,
          'isOfflineReport': true,
        };
      }
    }

    if (!widget.isFromHistory) {
      _saveDiagnosisHistory();
    }
  }

  void _saveDiagnosisHistory() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final authUser = ref.read(authStateProvider).value;
        if (authUser != null) {
          final service = ref.read(diagnosisHistoryServiceProvider);
          final history = DiagnosisHistoryModel(
            id: '', 
            cropName: widget.cropName,
            diseaseName: widget.diseaseName,
            confidence: widget.confidence,
            severity: widget.severity ?? 'Unknown',
            isHealthy: _isHealthy,
            timestamp: DateTime.now(),
          );
          
          File? imgFile;
          if (widget.imagePath.isNotEmpty && !widget.imagePath.startsWith('http')) {
            imgFile = File(widget.imagePath);
            if (!await imgFile.exists()) imgFile = null;
          }

          _diagnosisId = await service.saveDiagnosis(authUser.uid, history, imageFile: imgFile);
        }
      } catch (e) {
        print('Failed to save diagnosis history: $e');
      }
    });
  }

  bool get _isOffline => _aiData == null;

  Color get _severityColor {
    switch (widget.severity) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      default: return const Color(0xFF2E7D32);
    }
  }

  bool get _isHealthy => widget.diseaseName.toLowerCase().contains('healthy');

  Map<String, dynamic>? _getOfflineData() {
    // 1. Try to use topPredictions first (exact raw label matching)
    if (widget.topPredictions != null && widget.topPredictions!.isNotEmpty) {
      final rawLabel = widget.topPredictions!.first['label'] as String?;
      if (rawLabel != null && offlinePathologyDatabase.containsKey(rawLabel)) {
        return offlinePathologyDatabase[rawLabel];
      }
    }

    // 2. If healthy, find the crop's healthy template
    final isHealthy = widget.diseaseName.toLowerCase().contains('healthy') ||
                      widget.diseaseName.toLowerCase().contains('no disease');
    
    final cropLower = widget.cropName.toLowerCase().replaceAll(' ', '_');
    
    if (isHealthy) {
      for (final key in offlinePathologyDatabase.keys) {
        if (key.toLowerCase().contains(cropLower) && key.toLowerCase().contains('healthy')) {
          return offlinePathologyDatabase[key];
        }
      }
      return {
        'description': 'This ${widget.cropName} leaf specimen displays exceptional cell turgor, ideal chlorophyll density, and a complete absence of active fungal, bacterial, viral, or insect pathologies.',
        'symptoms': [
          'Consistent, vibrant green color across the leaf surface.',
          'Crisp, firm leaf margins with no necrotic drying or spots.',
          'Smooth, intact leaf veins with standard vascular distribution.'
        ],
        'chemical_treatment': [
          {'product': 'No Chemical Fungicide/Insecticide Needed', 'dosage': 'Maintain standard fertilization based on soil tests.'}
        ],
        'organic_treatment': [
          'Apply aged organic compost around the drip line to enrich the root zone.',
          'Apply mulching (straw, woodchips) to maintain soil moisture and cool roots.'
        ],
        'prevention': [
          'Practice deep, infrequent watering at the base of the plant to keep leaves dry.',
          'Ensure proper spacing to allow maximum sunshine and air movement.',
          'Conduct bi-weekly visual inspections to catch any pests early.'
        ]
      };
    }

    // 3. Match by name
    String cleanDisease = widget.diseaseName.toLowerCase();
    if (cleanDisease.startsWith(cropLower)) {
      cleanDisease = cleanDisease.substring(cropLower.length).trim();
    }
    cleanDisease = cleanDisease.replaceAll(RegExp(r'[^a-z0-9]'), '');

    double bestScore = 0.0;
    String? bestKey;

    for (final key in offlinePathologyDatabase.keys) {
      final keyLower = key.toLowerCase();
      if (!keyLower.contains(cropLower)) continue;

      final keyDiseasePart = keyLower.split('___').last.replaceAll('_', '').replaceAll(RegExp(r'[^a-z0-9]'), '');
      
      int matches = 0;
      for (int i = 0; i < cleanDisease.length; i++) {
        if (keyDiseasePart.contains(cleanDisease[i])) {
          matches++;
        }
      }
      double score = matches / (keyDiseasePart.length + cleanDisease.length);
      if (score > bestScore) {
        bestScore = score;
        bestKey = key;
      }
    }

    if (bestKey != null && bestScore > 0.1) {
      return offlinePathologyDatabase[bestKey];
    }

    for (final key in offlinePathologyDatabase.keys) {
      if (key.toLowerCase().contains(cropLower)) {
        return offlinePathologyDatabase[key];
      }
    }

    return null;
  }

  Future<void> _fetchAiReport() async {
    setState(() { _isLoadingAi = true; _aiError = null; });
    
    // Check connectivity status
    final connState = ref.read(connectivityProvider);
    if (connState == ConnectivityStatus.offline) {
      // Offline mode!
      final offlineData = _getOfflineData();
      if (offlineData != null) {
        if (mounted) {
          setState(() {
            _aiData = {
              ...offlineData,
              'isOfflineReport': true,
            };
            _isLoadingAi = false;
          });
        }
        return;
      } else {
        if (mounted) {
          setState(() {
            _aiError = 'Offline pathology report not found for this crop/disease.';
            _isLoadingAi = false;
          });
        }
        return;
      }
    }

    try {
      final data = await ref.read(geminiServiceProvider).getDiagnosisDetails(
        widget.diseaseName, widget.confidence, widget.cropName,
      );
      if (mounted) setState(() { _aiData = data; });

      // After fetching the report, update the saved diagnosis in the background
      if (_diagnosisId != null && data != null) {
        final authUser = ref.read(authStateProvider).value;
        if (authUser != null) {
          await ref.read(diagnosisHistoryServiceProvider).updateDiagnosisReport(authUser.uid, _diagnosisId!, data);
        }
      }
    } catch (e) {
      if (mounted) {
        // Fall back to offline database for ANY error, to ensure high reliability!
        final offlineData = _getOfflineData();
        if (offlineData != null) {
          print('Gemini failed ($e). Falling back to offline database.');
          setState(() {
            _aiData = {
              ...offlineData,
              'isOfflineReport': true,
            };
          });
          // Try to update history in background with offline data
          if (_diagnosisId != null) {
            final authUser = ref.read(authStateProvider).value;
            if (authUser != null) {
              ref.read(diagnosisHistoryServiceProvider).updateDiagnosisReport(authUser.uid, _diagnosisId!, _aiData!);
            }
          }
          return;
        }

        String msg = e.toString();
        if (msg.contains('429') || msg.contains('quota') || msg.contains('RESOURCE_EXHAUSTED')) {
          _aiError = 'AI quota exceeded. Try again later or check your Gemini API plan.';
        } else if (msg.contains('Failed to fetch') || msg.contains('SocketException') || msg.contains('NetworkImage') || msg.contains('connect')) {
          _aiError = 'No internet connection. Connect to Wi-Fi or mobile data for AI reports.';
        } else {
          _aiError = 'Could not load AI report. Please try again.';
        }
        setState(() {});
      }
    } finally {
      if (mounted) setState(() { _isLoadingAi = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _aiData != null ? 3 : 1,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F5),
        body: NestedScrollView(
          headerSliverBuilder: (ctx, inner) => [_buildSliverHeader()],
          body: _aiData != null ? _buildTabBody() : _buildOfflineBody(),
        ),
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: _isHealthy ? const Color(0xFF1B5E20) : const Color(0xFF7B1B1B),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Diagnosis Result', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Crop image
            _buildCropImage(),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    (_isHealthy ? const Color(0xFF1B5E20) : const Color(0xFF7B1B1B)).withOpacity(0.85),
                  ],
                ),
              ),
            ),
            // Disease info overlay
            Positioned(
              left: 20,
              right: 20,
              bottom: 20 + (_aiData != null ? (_aiData?['isOfflineReport'] == true ? 80.0 : 48.0) : 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildBadge(
                        _isOffline ? '🤖 AI Model: Offline' : '☁️ AI Enhanced',
                        _isOffline ? Colors.green[700]! : Colors.blue[700]!,
                      ),
                      const SizedBox(width: 8),
                      if (widget.severity != null && !_isHealthy)
                        _buildBadge('⚠️ ${widget.severity} Severity', _severityColor),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.diseaseName,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  _buildConfidenceBar(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: _aiData != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(_aiData?['isOfflineReport'] == true ? 80 : 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_aiData?['isOfflineReport'] == true) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber[700]!.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber[300]!, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.offline_bolt, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            '🤖 Offline Database Report',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Treatment'),
                      Tab(text: 'Prevention'),
                    ],
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildCropImage() {
    if (widget.imageBytes != null) {
      return Image.memory(widget.imageBytes!, fit: BoxFit.cover);
    }
    if (widget.imagePath.isNotEmpty) {
      if (widget.imagePath.startsWith('http')) {
        return Image.network(widget.imagePath, fit: BoxFit.cover);
      } else if (!kIsWeb) {
        return Image.file(File(widget.imagePath), fit: BoxFit.cover);
      }
    }
    return Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 80, color: Colors.white54));
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildConfidenceBar() {
    final pct = widget.confidence.clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confidence: ${pct.toStringAsFixed(1)}%',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct / 100.0,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(
              pct > 80 ? Colors.greenAccent : pct > 55 ? Colors.orangeAccent : Colors.redAccent,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // OFFLINE BODY — shows TFLite results immediately, no Gemini needed
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildOfflineBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary card ──
          _buildSummaryCard(),
          const SizedBox(height: 20),

          // ── Top predictions ──
          if (widget.topPredictions != null && widget.topPredictions!.isNotEmpty) ...[
            _buildSectionHeader('Top Predictions'),
            const SizedBox(height: 10),
            ...widget.topPredictions!.asMap().entries.map((entry) {
              final i = entry.key;
              final pred = entry.value;
              final conf = (pred['confidenceValue'] as double? ?? 0.0) * 100;
              final label = pred['label'].toString().split('___').last.replaceAll('_', ' ');
              return _buildPredictionRow(label, conf, i == 0);
            }),
            const SizedBox(height: 24),
          ],

          // ── Healthy tip OR disease info ──
          if (_isHealthy)
            _buildHealthyCard()
          else ...[
            _buildSectionHeader('What this means'),
            const SizedBox(height: 10),
            Builder(builder: (context) {
              final connState = ref.watch(connectivityProvider);
              final isCurrentlyOffline = connState == ConnectivityStatus.offline;
              return _buildInfoBox(
                isCurrentlyOffline
                    ? '📡 You are offline. Tap below to instantly load expert pathology data for **${widget.diseaseName}** from the on-device database — no internet required.'
                    : 'The AI has detected **${widget.diseaseName}** in your crop with ${widget.confidence.toStringAsFixed(1)}% confidence.\n\nTap below for a full treatment plan, symptoms breakdown, and prevention tips.',
              );
            }),
          ],

          const SizedBox(height: 24),

          // ── AI Report button / error / loading ──
          if (_aiError != null) _buildErrorCard(),
          if (_isLoadingAi) _buildLoadingCard(),
          if (!_isLoadingAi && _aiError == null && !_isHealthy)
            _buildGenerateButton(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: (_isHealthy ? Colors.green : _severityColor).withOpacity(0.12),
                child: Icon(
                  _isHealthy ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: _isHealthy ? Colors.green : _severityColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.cropName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.diseaseName,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confidence: ${widget.confidence.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.confidence > 80 ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.severity != null && !_isHealthy) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip('Severity', widget.severity!, _severityColor),
                _buildStatChip('Confidence', '${widget.confidence.toStringAsFixed(0)}%',
                    widget.confidence > 80 ? Colors.green : Colors.orange),
                _buildStatChip('Source', 'On-device', Colors.blueGrey),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildPredictionRow(String label, double confidence, bool isTop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isTop ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isTop ? Colors.green[200]! : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            isTop ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: isTop ? Colors.green[700] : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isTop ? Colors.green[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${confidence.toStringAsFixed(1)}%',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isTop ? Colors.green[800] : Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthyCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green[50]!, Colors.green[100]!]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your crop looks healthy!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                SizedBox(height: 4),
                Text('No diseases detected. Keep up with regular monitoring and good farming practices.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF2E7D32))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF212121)));
  }

  Widget _buildInfoBox(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(child: Text(_aiError!, style: TextStyle(color: Colors.red[800], fontSize: 13))),
          TextButton(onPressed: _fetchAiReport, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    final connState = ref.watch(connectivityProvider);
    final isCurrentlyOffline = connState == ConnectivityStatus.offline;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCurrentlyOffline ? Colors.amber[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentlyOffline
            ? Border.all(color: Colors.amber[200]!)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isCurrentlyOffline ? Colors.amber[700] : const Color(0xFF1B5E20),
          ),
          const SizedBox(width: 16),
          Text(
            isCurrentlyOffline ? 'Loading offline database...' : 'Generating AI Report...',
            style: TextStyle(
              color: isCurrentlyOffline ? Colors.amber[800] : Colors.grey,
              fontWeight: isCurrentlyOffline ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    final connState = ref.watch(connectivityProvider);
    final isCurrentlyOffline = connState == ConnectivityStatus.offline;
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (isCurrentlyOffline)
              BoxShadow(
                color: Colors.amber.withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: const Color(0xFF1B5E20).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _fetchAiReport,
          icon: Icon(isCurrentlyOffline ? Icons.offline_bolt : Icons.auto_awesome),
          label: Text(
            isCurrentlyOffline
                ? 'Load Offline Pathology Report'
                : 'Generate Full AI Report',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentlyOffline ? Colors.amber[700] : const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // AI-ENHANCED BODY — shown after Gemini report loads
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildTabBody() {
    return TabBarView(
      children: [
        _buildOverviewTab(_aiData!),
        _buildTreatmentTab(_aiData!),
        _buildPreventionTab(_aiData!),
      ],
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 20),
          if (widget.topPredictions != null && widget.topPredictions!.isNotEmpty) ...[
            _buildSectionHeader('Top Predictions'),
            const SizedBox(height: 10),
            ...widget.topPredictions!.asMap().entries.map((entry) {
              final conf = (entry.value['confidenceValue'] as double? ?? 0.0) * 100;
              final label = entry.value['label'].toString().split('___').last.replaceAll('_', ' ');
              return _buildPredictionRow(label, conf, entry.key == 0);
            }),
            const SizedBox(height: 20),
          ],
          _buildSectionHeader('Description'),
          const SizedBox(height: 8),
          Text(data['description'] ?? '', style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
          const SizedBox(height: 20),
          _buildSectionHeader('Main Symptoms'),
          const SizedBox(height: 10),
          ...((data['symptoms'] as List?)?.map((s) => _buildBulletPoint(s.toString())) ?? []),
        ],
      ),
    );
  }

  Widget _buildTreatmentTab(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Chemical Treatment'),
          const SizedBox(height: 12),
          ...((data['chemical_treatment'] as List?)?.map((t) {
                if (t is Map) {
                  return _buildTreatmentCard(
                    title: t['product']?.toString() ?? t['name']?.toString() ?? 'Treatment',
                    subtitle: t['dosage'] != null ? 'Dosage: ${t['dosage']}' : '',
                    icon: Icons.science_outlined,
                  );
                } else {
                  return _buildBulletPoint(t.toString());
                }
              }) ?? []),
          const SizedBox(height: 24),
          _buildSectionHeader('Organic Options'),
          const SizedBox(height: 12),
          ...((data['organic_treatment'] as List?)?.map((m) {
                if (m is Map) {
                  return _buildTreatmentCard(
                    title: m['product']?.toString() ?? m['name']?.toString() ?? m['method']?.toString() ?? 'Treatment',
                    subtitle: m['dosage'] != null ? 'Dosage: ${m['dosage']}' : '',
                    icon: Icons.eco_outlined,
                  );
                } else {
                  return _buildBulletPoint(m.toString());
                }
              }) ?? []),
        ],
      ),
    );
  }

  Widget _buildPreventionTab(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Prevention Tips'),
          const SizedBox(height: 12),
          ...((data['prevention'] as List?)?.map((p) => _buildBulletPoint(p.toString())) ?? []),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF1B5E20)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Always consult with local agriculture extension officers for region-specific advice.',
                    style: TextStyle(color: Color(0xFF1B5E20), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard({required String title, required String subtitle, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1B5E20), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 20, color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4))),
        ],
      ),
    );
  }
}
