import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeColorProvider = StateProvider<Color>((ref) {
  return const Color(0xFF2E7D32); // Vibrant Green
});
