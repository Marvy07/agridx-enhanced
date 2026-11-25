import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design/design.dart';
import '../../shared/widgets/widgets.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _search = '';
  String _filter = 'All';

  static const _filters = ['All', 'Cereals', 'Legumes', 'Vegetables', 'Fruits', 'Cash Crops'];

  static final _crops = [
    _Crop('maize', 'Maize', 'Zea mays', 'Cereals', AppImages.cropMaize, '12 diseases'),
    _Crop('tomato', 'Tomato', 'Solanum lycopersicum', 'Vegetables', AppImages.cropTomato, '8 diseases'),
    _Crop('cassava', 'Cassava', 'Manihot esculenta', 'Cereals', AppImages.cropCassava, '6 diseases'),
    _Crop('rice', 'Rice', 'Oryza sativa', 'Cereals', AppImages.cropRice, '10 diseases'),
    _Crop('banana', 'Banana', 'Musa', 'Fruits', AppImages.cropBanana, '5 diseases'),
    _Crop('coffee', 'Coffee', 'Coffea arabica', 'Cash Crops', AppImages.cropCoffee, '7 diseases'),
    _Crop('cocoa', 'Cocoa', 'Theobroma cacao', 'Cash Crops', AppImages.cropCocoa, '9 diseases'),
    _Crop('mango', 'Mango', 'Mangifera indica', 'Fruits', AppImages.cropMango, '4 diseases'),
    _Crop('soybean', 'Soybean', 'Glycine max', 'Legumes', AppImages.cropSoybean, '6 diseases'),
    _Crop('wheat', 'Wheat', 'Triticum aestivum', 'Cereals', AppImages.cropWheat, '11 diseases'),
  ];

  List<_Crop> get _visible {
    return _crops.where((c) {
      final matchSearch = _search.isEmpty || c.name.toLowerCase().contains(_search.toLowerCase());
      final matchFilter = _filter == 'All' || c.category == _filter;
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Crop Library')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding, 0, AppSpacing.screenPadding, AppSpacing.md),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'Search crops...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _filters[i];
                final active = f == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                      border: active ? null : Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      f,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: active ? Colors.white : AppColors.textSecondary,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _visible.isEmpty
                ? AppEmptyState(
                    icon: Icons.local_florist_outlined,
                    title: 'No crops found',
                    message: 'Try a different search term or filter.',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: _visible.length,
                    itemBuilder: (context, i) {
                      final c = _visible[i];
                      return AppPhotoCard(
                        imageUrl: c.imageUrl,
                        title: c.name,
                        subtitle: c.sub,
                        height: double.infinity,
                        onTap: () => context.go('/library/${c.id}'),
                        chip: AppChip(label: c.category),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Crop {
  const _Crop(this.id, this.name, this.sci, this.category, this.imageUrl, this.sub);
  final String id, name, sci, category, imageUrl, sub;
}
