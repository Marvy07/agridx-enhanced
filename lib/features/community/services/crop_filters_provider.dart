import 'package:flutter_riverpod/flutter_riverpod.dart';

class CropFilter {
  final String name;
  final String emoji;
  final bool isVisible;

  CropFilter({required this.name, required this.emoji, this.isVisible = true});

  CropFilter copyWith({bool? isVisible}) {
    return CropFilter(
      name: name,
      emoji: emoji,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class CropFiltersNotifier extends StateNotifier<List<CropFilter>> {
  CropFiltersNotifier() : super([
    CropFilter(name: 'Apple', emoji: '🍎'),
    CropFilter(name: 'Blueberry', emoji: '🫐'),
    CropFilter(name: 'Cherry', emoji: '🍒'),
    CropFilter(name: 'Corn', emoji: '🌽'),
    CropFilter(name: 'Grape', emoji: '🍇'),
    CropFilter(name: 'Orange', emoji: '🍊'),
    CropFilter(name: 'Peach', emoji: '🍑'),
    CropFilter(name: 'Pepper', emoji: '🫑'),
    CropFilter(name: 'Potato', emoji: '🥔'),
    CropFilter(name: 'Raspberry', emoji: '🍓'),
    CropFilter(name: 'Soybean', emoji: '🌱'),
    CropFilter(name: 'Squash', emoji: '🎃'),
    CropFilter(name: 'Strawberry', emoji: '🍓'),
    CropFilter(name: 'Tomato', emoji: '🍅'),
  ]);

  void toggleVisibility(String name) {
    state = [
      for (final filter in state)
        if (filter.name == name) filter.copyWith(isVisible: !filter.isVisible) else filter,
    ];
  }
}

final cropFiltersProvider = StateNotifierProvider<CropFiltersNotifier, List<CropFilter>>((ref) {
  return CropFiltersNotifier();
});

final visibleCropFiltersProvider = Provider<List<CropFilter>>((ref) {
  return ref.watch(cropFiltersProvider).where((f) => f.isVisible).toList();
});
