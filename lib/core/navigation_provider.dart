import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the selected index of the main bottom navigation bar.
/// 0: Home (Your crops)
/// 1: Community
/// 2: Weather
/// 3: Profile (You)
final navigationProvider = StateProvider<int>((ref) => 0);
