import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'crops_data.dart';

class CropSelectorScreen extends ConsumerStatefulWidget {
  const CropSelectorScreen({super.key});

  @override
  ConsumerState<CropSelectorScreen> createState() => _CropSelectorScreenState();
}

class _CropSelectorScreenState extends ConsumerState<CropSelectorScreen> {
  List<String> _selectedCropNames = [];
  final int _maxAllowed = 8;

  @override
  void initState() {
    super.initState();
    _loadSelectedCrops();
  }

  void _loadSelectedCrops() {
    final box = Hive.box('user_preferences');
    final storedCrops = box.get('selected_crops', defaultValue: <String>[]);
    if (storedCrops is List) {
      setState(() {
        _selectedCropNames = List<String>.from(storedCrops);
      });
    }
  }

  void _saveSelectedCrops() async {
    final box = Hive.box('user_preferences');
    await box.put('selected_crops', _selectedCropNames);
    if (mounted) {
      Navigator.pop(context, true); // Return true indicating a save occurred
    }
  }

  void _toggleCropSelection(String cropName) {
    setState(() {
      if (_selectedCropNames.contains(cropName)) {
        _selectedCropNames.remove(cropName);
      } else {
        if (_selectedCropNames.length < _maxAllowed) {
          _selectedCropNames.add(cropName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can select a maximum of 8 crops.')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localizationProvider);
    final strings = ref.watch(localizationProvider.notifier).strings;
    // Determine which crops are selected objects to display at the top
    final selectedCropObjects = availableCrops
        .where((c) => _selectedCropNames.contains(c.name))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select crops',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Select up to 8 crops you are interested in',
                    style: TextStyle(color: Colors.grey[700], fontSize: 15),
                  ),
                ),
                Text(
                  '${_selectedCropNames.length}/$_maxAllowed',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          if (_selectedCropNames.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: selectedCropObjects.length,
                itemBuilder: (context, index) {
                  final crop = selectedCropObjects[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[100],
                              ),
                              alignment: Alignment.center,
                              child: Text(crop.emoji, style: const TextStyle(fontSize: 32)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              crop.name,
                              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: GestureDetector(
                            onTap: () => _toggleCropSelection(crop.name),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1565C0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
          ],

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: availableCrops.length,
              itemBuilder: (context, index) {
                final crop = availableCrops[index];
                final isSelected = _selectedCropNames.contains(crop.name);
                return GestureDetector(
                  onTap: () => _toggleCropSelection(crop.name),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[50], // Very light background
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey[300]!,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(crop.emoji, style: const TextStyle(fontSize: 40)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        crop.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _saveSelectedCrops,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
