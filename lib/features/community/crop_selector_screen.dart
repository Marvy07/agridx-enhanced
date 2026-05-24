import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/crop_filters_provider.dart';

class CropSelectorScreen extends ConsumerWidget {
  const CropSelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(cropFiltersProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Update Filters', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Select which crops you want to see in your community filter row.',
              style: TextStyle(color: Colors.grey[700], fontSize: 15),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                return CheckboxListTile(
                  title: Text('${filter.emoji} ${filter.name}'),
                  value: filter.isVisible,
                  onChanged: (val) {
                    ref.read(cropFiltersProvider.notifier).toggleVisibility(filter.name);
                  },
                  activeColor: const Color(0xFF1565C0),
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Save & Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
