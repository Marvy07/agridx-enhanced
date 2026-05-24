import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TrackedCrop {
  final String id;
  final String cropName;
  final DateTime plantedDate;
  final int growthDurationDays;
  final String emoji;
  final String region;

  TrackedCrop({
    required this.id,
    required this.cropName,
    required this.plantedDate,
    required this.growthDurationDays,
    required this.emoji,
    required this.region,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropName': cropName,
      'plantedDate': plantedDate.toIso8601String(),
      'growthDurationDays': growthDurationDays,
      'emoji': emoji,
      'region': region,
    };
  }

  factory TrackedCrop.fromMap(Map<dynamic, dynamic> map) {
    return TrackedCrop(
      id: map['id'] ?? '',
      cropName: map['cropName'] ?? '',
      plantedDate: DateTime.parse(map['plantedDate'] ?? DateTime.now().toIso8601String()),
      growthDurationDays: map['growthDurationDays'] ?? 90,
      emoji: map['emoji'] ?? '🌱',
      region: map['region'] ?? 'Unknown',
    );
  }

  int get daysSincePlanted {
    return DateTime.now().difference(plantedDate).inDays;
  }

  double get progressPercentage {
    final progress = daysSincePlanted / growthDurationDays;
    if (progress < 0) return 0.0;
    if (progress > 1.0) return 1.0;
    return progress;
  }

  String get currentStage {
    if (progressPercentage < 0.1) return 'Planting';
    if (progressPercentage < 0.9) return 'Growing';
    return 'Harvest';
  }
}

class MyFarmNotifier extends StateNotifier<List<TrackedCrop>> {
  MyFarmNotifier() : super([]) {
    _loadCrops();
  }

  Future<void> _loadCrops() async {
    final box = await Hive.openBox('my_farm_box');
    final rawData = box.values.toList();
    state = rawData.map((e) => TrackedCrop.fromMap(e as Map)).toList();
  }

  Future<void> addCrop(TrackedCrop crop) async {
    final box = await Hive.openBox('my_farm_box');
    await box.put(crop.id, crop.toMap());
    state = [...state, crop];
  }

  Future<void> removeCrop(String id) async {
    final box = await Hive.openBox('my_farm_box');
    await box.delete(id);
    state = state.where((c) => c.id != id).toList();
  }
}

final myFarmProvider = StateNotifierProvider<MyFarmNotifier, List<TrackedCrop>>((ref) {
  return MyFarmNotifier();
});
