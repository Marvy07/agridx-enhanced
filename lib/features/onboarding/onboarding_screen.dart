import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../navigation/main_nav_wrapper.dart';
import '../../main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _data = [
    OnboardingData(
      icon: Icons.eco_outlined,
      title: 'Diagnose crop diseases instantly',
      subtitle: 'Take a photo of any crop leaf and get an AI diagnosis in seconds — even without internet.',
    ),
    OnboardingData(
      icons: [Icons.cloud_queue_outlined, Icons.wifi],
      title: 'Works offline — no internet needed',
      subtitle: 'Diagnose crop diseases even in remote areas without any internet connection.',
    ),
    OnboardingData(
      icons: [Icons.wb_sunny_outlined, Icons.thermostat_outlined],
      title: 'Get live weather & farming alerts',
      subtitle: 'Real-time weather forecasts and disease risk alerts tailored for your farm location.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _data.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.38,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF1E7), // Light peach/brown to match theme
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _data[index].icons != null
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: _data[index].icons!
                                          .map((icon) => Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Icon(icon, size: 80, color: const Color(0xFF1B5E20)), // Deep green
                                              ))
                                          .toList(),
                                    )
                                  : Icon(_data[index].icon, size: 140, color: const Color(0xFF1B5E20)),
                            ),
                          ),
                          const SizedBox(height: 50),
                          Text(
                            _data[index].title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1B263B), // Match headings
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              _data[index].subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54, // Match subtitles
                                fontWeight: FontWeight.w500,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _data.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index ? const Color(0xFF1B5E20) : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_currentPage == _data.length - 1) ...[
                    TextButton(
                      onPressed: () {
                        Hive.box('user_preferences').put('hasSeenOnboarding', true);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AuthWrapper()),
                        );
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.black45, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _data.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Hive.box('user_preferences').put('hasSeenOnboarding', true);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const AuthWrapper()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20), // Deep green
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _data.length - 1 ? 'Get Started' : 'Next',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  if (_currentPage != _data.length - 1) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Hive.box('user_preferences').put('hasSeenOnboarding', true);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AuthWrapper()),
                        );
                      },
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.black45, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final IconData? icon;
  final List<IconData>? icons;
  final String title;
  final String subtitle;

  OnboardingData({this.icon, this.icons, required this.title, required this.subtitle});
}
