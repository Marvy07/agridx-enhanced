import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization_provider.dart';
import '../../core/navigation_provider.dart';
import '../library/crops_data.dart';
import '../library/crop_selector_screen.dart';
import '../library/crop_list_screen.dart';
import '../library/fertilizer_calculator_screen.dart';
import '../library/pesticide_guide_screen.dart';
import '../library/pest_disease_alert_screen.dart';
import '../library/crop_calendar_screen.dart';
import '../library/cultivation_tips_screen.dart';
import '../library/pests_diseases_screen.dart';
import '../notifications/notification_screen.dart';
import '../../core/connectivity_provider.dart';
import '../scan/crop_scan_screen.dart';
import '../../shared/services/weather_service.dart';
import '../../core/theme_provider.dart';
import 'package:weather/weather.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<Color?> _buttonColorAnimation;

  late List<CropDetails> _selectedCrops;
  late CropDetails _activeCrop;

  @override
  void initState() {
    super.initState();
    
    // Default fallback crops
    _selectedCrops = availableCrops.where((c) => 
      ['Maize', 'Tomato', 'Cassava', 'Rice', 'Pepper', 'Banana'].contains(c.name)
    ).toList();
    
    // In case the names don't match, just take the first 6
    if (_selectedCrops.isEmpty) {
      _selectedCrops = availableCrops.take(6).toList();
    }
    
    _activeCrop = _selectedCrops.first;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(themeColorProvider.notifier).state = _activeCrop.color;
      }
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _backgroundColorAnimation = ColorTween(
      begin: _activeCrop.color.withOpacity(0.15),
      end: _activeCrop.color.withOpacity(0.15),
    ).animate(_controller);

    _buttonColorAnimation = ColorTween(
      begin: _activeCrop.color,
      end: _activeCrop.color,
    ).animate(_controller);

    _loadSelectedCrops();
  }

  Future<void> _loadSelectedCrops() async {
    final box = Hive.box('user_preferences');
    final storedCropNames = box.get('selected_crops', defaultValue: <String>[]);
    
    if (storedCropNames != null && storedCropNames is List && storedCropNames.isNotEmpty) {
      List<CropDetails> loadedCrops = [];
      for (dynamic name in storedCropNames) {
        if (name is String) {
          try {
            final crop = availableCrops.firstWhere((c) => c.name == name);
            loadedCrops.add(crop);
          } catch (e) {
            // Ignore if crop not found
          }
        }
      }

      if (loadedCrops.isNotEmpty) {
        if (mounted) {
          setState(() {
            _selectedCrops = loadedCrops;
            _activeCrop = _selectedCrops.first;
            ref.read(themeColorProvider.notifier).state = _activeCrop.color;
            
            _backgroundColorAnimation = ColorTween(
              begin: _activeCrop.color.withOpacity(0.15),
              end: _activeCrop.color.withOpacity(0.15),
            ).animate(_controller);

            _buttonColorAnimation = ColorTween(
              begin: _activeCrop.color,
              end: _activeCrop.color,
            ).animate(_controller);
          });
        }
      }
    }
  }

  void _onCropSelected(CropDetails crop) {
    setState(() {
      _backgroundColorAnimation = ColorTween(
        begin: _backgroundColorAnimation.value,
        end: crop.color.withOpacity(0.15),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _buttonColorAnimation = ColorTween(
        begin: _buttonColorAnimation.value,
        end: crop.color,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      _activeCrop = crop;
      ref.read(themeColorProvider.notifier).state = crop.color;
    });
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'AgriDx',
              style: TextStyle(
                color: Color(0xFF1B5E20),
                fontSize: 26,
                letterSpacing: -0.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              _buildConnectivityToggle(ref),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop Selector (Neutral area)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      // Show up to 6 crops max on the home screen
                      ..._selectedCrops.take(6).map((crop) => _buildCropCircle(crop)),
                      _buildAddButton(),
                    ],
                  ),
                ),

                // THEMED PERIMETER (Weather + Scan Card)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _backgroundColorAnimation.value,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
                    child: Consumer(
                      builder: (context, ref, child) {
    ref.watch(localizationProvider);
                        final weatherAsync = ref.watch(currentWeatherProvider);
                        final weatherService = ref.read(weatherServiceProvider);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Weather & Conditions Row
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      ref.read(navigationProvider.notifier).state = 2; // Weather index
                                    },
                                    child: _buildInfoCard(
                                      showArrow: true,
                                      child: weatherAsync.when(
                                        data: (weather) => Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ref.watch(localizationProvider.notifier).strings['today']!,
                                              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${weather?.temperature?.celsius?.toStringAsFixed(0) ?? "--"}°C',
                                              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, height: 1.1),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                _buildWeatherIcon(weather?.weatherConditionCode, size: 22),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    weather?.weatherMain ?? 'Clear',
                                                    style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w600),
                                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                        error: (err, _) => const Text('Error'),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      ref.read(navigationProvider.notifier).state = 2; // Weather index
                                    },
                                    child: _buildInfoCard(
                                      showArrow: true,
                                      child: weatherAsync.when(
                                        data: (weather) {
                                          final condition = weatherService.getSprayingCondition(weather);
                                          final isExcellent = condition.contains('Excellent');
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ref.watch(localizationProvider.notifier).strings['spraying_cond']!,
                                                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5),
                                              ),
                                              const SizedBox(height: 12),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: (isExcellent ? Colors.green : Colors.orange).withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: (isExcellent ? Colors.green : Colors.orange).withOpacity(0.3)),
                                                ),
                                                child: Text(
                                                  condition.replaceFirst('Condition: ', ''),
                                                  style: TextStyle(
                                                    color: isExcellent ? Colors.green[700] : Colors.orange[800],
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(height: 14),
                                              Row(
                                                children: [
                                                  Icon(Icons.schedule, size: 16, color: Colors.grey[400]),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    ref.watch(localizationProvider.notifier).strings['all_day']!,
                                                    style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                        error: (err, _) => const Text('Error'),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Scan Card
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: _activeCrop.color.withOpacity(0.12),
                                    blurRadius: 32,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(child: _buildStep(Icons.center_focus_weak, ref.watch(localizationProvider.notifier).strings['take_pic']!, _activeCrop.color)),
                                      Icon(Icons.keyboard_double_arrow_right_rounded, color: Colors.grey[300]),
                                      Expanded(child: _buildStep(Icons.document_scanner_outlined, ref.watch(localizationProvider.notifier).strings['see_diagnosis']!, _activeCrop.color)),
                                      Icon(Icons.keyboard_double_arrow_right_rounded, color: Colors.grey[300]),
                                      Expanded(child: _buildStep(Icons.medical_services_outlined, ref.watch(localizationProvider.notifier).strings['get_treatment']!, _activeCrop.color)),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_buttonColorAnimation.value ?? _activeCrop.color).withOpacity(0.35),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CropScanScreen(initialCropName: _activeCrop.name),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _buttonColorAnimation.value,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        ref.watch(localizationProvider.notifier).strings['scan_crop']!,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // TOOLS SECTION (Neutral area)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.watch(localizationProvider.notifier).strings['tools']!,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildToolCard(
                              ref.watch(localizationProvider.notifier).strings['fertilizer_calc']!,
                              Icons.inventory_2_outlined,
                              onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const FertilizerCalculatorScreen())),
                            ),
                            _buildToolCard(
                              ref.watch(localizationProvider.notifier).strings['pesticide_guide']!, 
                              Icons.science_outlined, 
                              isNew: true,
                              onTap: () => Navigator.push(context, 
                                MaterialPageRoute(builder: (_) => const PesticideGuideScreen())
                              ),
                            ),
                            _buildToolCard(
                              ref.watch(localizationProvider.notifier).strings['crop_calendar']!,
                              Icons.calendar_today_outlined,
                              isNew: true,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CropCalendarScreen()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // LIBRARY SECTION (Plantix-style staggered grid)
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.watch(localizationProvider.notifier).strings['library']!,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT COLUMN 
                          Expanded(
                            child: Column(
                              children: [
                                _buildLibraryCard(
                                  context,
                                  title: ref.watch(localizationProvider.notifier).strings['crops']!,
                                  icon: '🪴',
                                  height: 180,
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => const CropListScreen(),
                                    ));
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildLibraryCard(
                                  context,
                                  title: ref.watch(localizationProvider.notifier).strings['cultivation_tips']!,
                                  icon: '🌱',
                                  height: 150,
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CultivationTipsScreen()));
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // RIGHT COLUMN
                          Expanded(
                            child: Column(
                              children: [
                                _buildLibraryCard(
                                  context,
                                  title: ref.watch(localizationProvider.notifier).strings['pests_diseases']!,
                                  icon: '🐛',
                                  height: 150,
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => const PestsDiseasesScreen(),
                                    ));
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildLibraryCard(
                                  context,
                                  title: ref.watch(localizationProvider.notifier).strings['pests_diseases_alert']!,
                                  icon: '⚠️',
                                  height: 180,
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (_) => const PestDiseaseAlertScreen(),
                                    ));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCropCircle(CropDetails crop) {
    final isSelected = _activeCrop.name == crop.name;
    return GestureDetector(
      onTap: () => _onCropSelected(crop),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: crop.color.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
                border: Border.all(
                  color: isSelected ? crop.color : Colors.transparent,
                  width: isSelected ? 3 : 0,
                ),
              ),
              child: Center(
                child: Text(
                  crop.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 8),
             Text(
              crop.name,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.black : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CropSelectorScreen()),
        );
        if (result == true) {
          _loadSelectedCrops();
        }
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: Colors.transparent),
            ),
            child: const Center(
              child: Icon(Icons.add, color: Colors.blue, size: 28),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'More',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required Widget child, bool showArrow = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), // Softer, more spread shadow
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          child,
          if (showArrow)
            Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
            ),
        ],
      ),
    ).animate().fade(duration: 500.ms, delay: 100.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildStep(IconData icon, String label, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: accentColor),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600, height: 1.2),
        ),
      ],
    );
  }

  Widget _buildToolCard(String title, IconData icon,
      {bool isNew = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 130,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFFBFBFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06), // Softer, floating shadow
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _activeCrop.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: _activeCrop.color, size: 26),
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (isNew)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms, delay: 100.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildLibraryCard(
    BuildContext context, {
    required String title,
    required String icon,
    required double height,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _activeCrop.color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _activeCrop.color.withOpacity(0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _activeCrop.color.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _activeCrop.color.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(icon, style: const TextStyle(fontSize: 26)),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B263B),
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildConnectivityToggle(WidgetRef ref) {
    final status = ref.watch(connectivityProvider);
    final isOnline = status == ConnectivityStatus.online;

    return Center(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        child: Tooltip(
          message: isOnline ? 'You are online' : 'You are offline',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 104,
            height: 34,
            decoration: BoxDecoration(
              color: isOnline ? const Color(0xFF2E7D32) : const Color(0xFF37474F),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isOnline ? const Color(0xFF2E7D32) : const Color(0xFF37474F)).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background labels
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: isOnline ? 10 : 38,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: 1.0,
                      child: Text(
                        isOnline ? 'Online' : 'Offline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                // Sliding Knob
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: isOnline ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isOnline ? Icons.wifi : Icons.wifi_off,
                            key: ValueKey(isOnline),
                            size: 14,
                            color: isOnline ? const Color(0xFF2E7D32) : const Color(0xFF37474F),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherIcon(int? code, {double size = 24}) {
    if (code == null) return Icon(Icons.wb_sunny, color: Colors.orange[400], size: size);
    
    if (code >= 200 && code < 300) return Icon(Icons.thunderstorm, color: Colors.blueGrey, size: size);
    if (code >= 300 && code < 600) return Icon(Icons.beach_access, color: Colors.blue, size: size);
    if (code >= 600 && code < 700) return Icon(Icons.ac_unit, color: Colors.lightBlue, size: size);
    if (code >= 700 && code < 800) return Icon(Icons.cloud, color: Colors.grey, size: size);
    if (code == 800) return Icon(Icons.wb_sunny, color: Colors.orange[400], size: size);
    return Icon(Icons.cloud_queue, color: Colors.grey, size: size);
  }
}
