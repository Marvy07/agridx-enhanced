import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/localization_provider.dart';
import 'crops_data.dart';
import 'services/my_farm_service.dart';
import 'crop_selector_screen.dart'; // To select crops

class CropCalendarScreen extends ConsumerStatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  ConsumerState<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends ConsumerState<CropCalendarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMonth = DateTime.now().month;
  String _selectedRegion = 'West Africa';

  final List<String> _regions = ['West Africa', 'East Africa', 'Southern Africa'];
  final List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localizationProvider);
    final strings = ref.watch(localizationProvider.notifier).strings;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          strings['crop_calendar']?.replaceAll('\n', ' ') ?? 'Crop Calendar',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1B5E20),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1B5E20),
          tabs: const [
            Tab(text: 'General Guide'),
            Tab(text: 'My Farm'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralGuideTab(),
          _buildMyFarmTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1 ? FloatingActionButton(
        onPressed: _showAddCropToFarm,
        backgroundColor: const Color(0xFF1B5E20),
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  Widget _buildGeneralGuideTab() {
    // Filter crops that are good to plant in the selected month for the selected region
    final suitableCrops = availableCrops.where((crop) {
      final seasons = crop.plantingSeasons[_selectedRegion];
      if (seasons == null) return false;
      return seasons.contains(_selectedMonth);
    }).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRegion,
                    isDense: true,
                    items: _regions.map((String region) {
                      return DropdownMenuItem<String>(
                        value: region,
                        child: Text(region, style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRegion = val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 60,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 12,
            itemBuilder: (context, index) {
              final monthNum = index + 1;
              final isSelected = monthNum == _selectedMonth;
              return GestureDetector(
                onTap: () => setState(() => _selectedMonth = monthNum),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1B5E20) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      _months[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: suitableCrops.isEmpty
            ? Center(child: Text('No recommended crops for $_selectedRegion in ${_months[_selectedMonth-1]}.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: suitableCrops.length,
                itemBuilder: (context, index) {
                  final crop = suitableCrops[index];
                  return _buildGeneralCropCard(crop);
                },
              ),
        ),
      ],
    );
  }

  Widget _buildGeneralCropCard(CropDetails crop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: crop.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(crop.emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  'Harvest in ~${crop.growthDurationDays} days',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.thermostat, size: 14, color: Colors.orange[700]),
                    const SizedBox(width: 4),
                    Text(crop.growingTemp, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.water_drop, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(crop.watering, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyFarmTab() {
    final myFarmCrops = ref.watch(myFarmProvider);

    if (myFarmCrops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.agriculture, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No crops planted yet.', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text('Tap the + button to track a new crop.', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myFarmCrops.length,
      itemBuilder: (context, index) {
        final crop = myFarmCrops[index];
        return _buildTrackedCropCard(crop);
      },
    );
  }

  Widget _buildTrackedCropCard(TrackedCrop crop) {
    final harvestDate = crop.plantedDate.add(Duration(days: crop.growthDurationDays));
    final daysLeft = harvestDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[100]!),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(crop.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(crop.cropName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(
                      'Planted: ${DateFormat.yMMMd().format(crop.plantedDate)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDeleteCrop(crop.id),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Stage: ${crop.currentStage}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
              Text(daysLeft > 0 ? '$daysLeft days left' : 'Ready to Harvest!', 
                style: TextStyle(fontWeight: FontWeight.bold, color: daysLeft > 0 ? Colors.orange[800] : Colors.green[700])),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: crop.progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1B5E20)),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStageDot('Planting', crop.progressPercentage >= 0.0),
              _buildStageDot('Growing', crop.progressPercentage >= 0.1),
              _buildStageDot('Harvest', crop.progressPercentage >= 0.9),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageDot(String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1B5E20) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: isActive ? const Color(0xFF1B5E20) : Colors.grey[500], fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  void _showAddCropToFarm() async {
    final selectedCrop = await Navigator.push<CropDetails>(
      context,
      MaterialPageRoute(builder: (_) => const _MiniCropSelector()),
    );

    if (selectedCrop != null && mounted) {
      final newTrackedCrop = TrackedCrop(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        cropName: selectedCrop.name,
        plantedDate: DateTime.now(), // By default planted today
        growthDurationDays: selectedCrop.growthDurationDays,
        emoji: selectedCrop.emoji,
        region: _selectedRegion,
      );
      ref.read(myFarmProvider.notifier).addCrop(newTrackedCrop);
    }
  }

  void _confirmDeleteCrop(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Crop?'),
        content: const Text('Are you sure you want to stop tracking this crop?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(myFarmProvider.notifier).removeCrop(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MiniCropSelector extends StatefulWidget {
  const _MiniCropSelector();
  @override
  State<_MiniCropSelector> createState() => _MiniCropSelectorState();
}

class _MiniCropSelectorState extends State<_MiniCropSelector> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? availableCrops
        : availableCrops.where((c) => c.name.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Crop to Plant', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search crops...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10
              ),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final crop = filtered[i];
                return GestureDetector(
                  onTap: () => Navigator.pop(context, crop),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(crop.emoji, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(crop.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
