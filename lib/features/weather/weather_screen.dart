import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design/design.dart';
import '../../shared/services/weather_service.dart';
import '../../shared/widgets/widgets.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Weather')),
      body: weatherAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppEmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Weather unavailable',
          message: 'Could not load weather data. Check your API key.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(currentWeatherProvider),
        ),
        data: (weather) {
          if (weather == null) {
            return AppEmptyState(
              icon: Icons.cloud_outlined,
              title: 'No weather data',
              message: 'Enable location access to see local weather.',
            );
          }
          return _WeatherContent(weather: weather);
        },
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({required this.weather});
  final dynamic weather;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero weather card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      weather?.areaName ?? 'Your Location',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather?.temperature?.celsius?.toStringAsFixed(0) ?? '--'}°',
                      style: AppTextStyles.display1.copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weather?.weatherDescription ?? '',
                            style: AppTextStyles.h4.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Feels like ${weather?.tempFeelsLike?.celsius?.toStringAsFixed(0) ?? '--'}°C',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _WeatherStat(label: 'Humidity', value: '${weather?.humidity ?? '--'}%'),
                    _WeatherStat(label: 'Wind', value: '${weather?.windSpeed?.toStringAsFixed(0) ?? '--'} km/h'),
                    _WeatherStat(label: 'UV Index', value: '${weather?.uvIndex?.toStringAsFixed(0) ?? '--'}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionSpacing),
          Text('Farm Advisory', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          _FarmAdvisoryCard(weather: weather),
        ],
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  const _WeatherStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h4.copyWith(color: Colors.white)),
        Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white60)),
      ],
    );
  }
}

class _FarmAdvisoryCard extends StatelessWidget {
  const _FarmAdvisoryCard({required this.weather});
  final dynamic weather;

  @override
  Widget build(BuildContext context) {
    final temp = weather?.temperature?.celsius ?? 25.0;
    final humidity = weather?.humidity ?? 60;

    String advice;
    IconData icon;
    Color color;

    if (humidity > 80) {
      advice = 'High humidity increases disease risk. Monitor crops for fungal infections and consider preventive spraying.';
      icon = Icons.warning_amber_rounded;
      color = AppColors.warning;
    } else if (temp > 35) {
      advice = 'High temperature stress. Irrigate early morning or evening. Watch for heat stress symptoms.';
      icon = Icons.thermostat_rounded;
      color = AppColors.severityHigh;
    } else {
      advice = 'Conditions look good for farming. Continue regular crop monitoring.';
      icon = Icons.check_circle_outline_rounded;
      color = AppColors.success;
    }

    return AppSurfaceCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Advisory', style: AppTextStyles.h4),
                const SizedBox(height: 4),
                Text(advice, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
