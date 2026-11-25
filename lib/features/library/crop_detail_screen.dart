import 'package:flutter/material.dart';
import 'crops_data.dart';
import 'fertilizer_calculator_screen.dart';

class CropDetailScreen extends StatelessWidget {
  final CropDetails crop;

  const CropDetailScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(crop.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.ios_share, size: 18),
              label: const Text('Share'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1565C0),
                backgroundColor: const Color(0xFFE3F2FD),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header — real photo with emoji fallback
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 240,
                width: double.infinity,
                child: crop.imageUrl.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            crop.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: crop.color.withOpacity(0.18),
                              child: Center(child: Text(crop.emoji, style: const TextStyle(fontSize: 80))),
                            ),
                            loadingBuilder: (_, child, prog) {
                              if (prog == null) return child;
                              return Container(
                                color: crop.color.withOpacity(0.12),
                                child: Center(child: CircularProgressIndicator(color: crop.color, strokeWidth: 2)),
                              );
                            },
                          ),
                          // Gradient overlay for text legibility
                          Positioned(
                            bottom: 0, left: 0, right: 0,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16, left: 20,
                            child: Text(
                              crop.name,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, shadows: [Shadow(blurRadius: 8, color: Colors.black45)]),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: crop.color.withOpacity(0.18),
                        child: Center(child: Text(crop.emoji, style: const TextStyle(fontSize: 80))),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            _buildListenButton(),
            const SizedBox(height: 16),

            // GROWING CONDITIONS
            const Text('Growing conditions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildGridSection([
              _GridItemData(icon: Icons.thermostat, title: 'Temperature', value: crop.growingTemp),
              _GridItemData(icon: Icons.wb_sunny_outlined, title: 'Exposition', value: crop.exposition),
              _GridItemData(icon: Icons.water_drop_outlined, title: 'Rainfall', value: crop.rainfall),
              _GridItemData(icon: Icons.opacity, title: 'Relative humidity', value: crop.humidity),
              _GridItemData(icon: Icons.water, title: 'Watering', value: crop.watering),
            ]),
            const SizedBox(height: 32),

            _buildListenButton(),
            const SizedBox(height: 16),

            // CULTIVATION
            const Text('Cultivation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildGridSection([
              _GridItemData(icon: Icons.timer_outlined, title: 'Life cycle', value: crop.lifecycle),
              _GridItemData(icon: Icons.fitness_center_outlined, title: 'Labour', value: crop.labour),
              _GridItemData(icon: Icons.grass_outlined, title: 'Planting method', value: crop.plantingMethod),
            ]),
            const SizedBox(height: 32),

            _buildListenButton(),
            const SizedBox(height: 16),

            // SOIL PARAMETERS
            const Text('Soil parameters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildGridSection([
              _GridItemData(icon: Icons.landscape_outlined, title: 'Soil', value: crop.soilType),
              _GridItemData(icon: Icons.science_outlined, title: 'pH', value: crop.pH),
            ]),
            const SizedBox(height: 24),

            // Diagram Illustration (Placeholder using Icons)
            SizedBox(
              height: 120,
              child: Stack(
                children: [
                   Center(
                    child: Icon(Icons.grid_on, size: 100, color: Colors.blue[100]),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Row to row', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        Text(crop.rowSpacing, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Plant to plant', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        Text(crop.plantSpacing, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline, color: Colors.black87),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These are general information for the crop. Adjust the plant density and spacing to your variety needs.',
                      style: TextStyle(color: Colors.black87, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Fertilizer Ref
             Row(
              children: [
                Expanded(child: _buildFertilizerStat('N:', crop.n)),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(child: _buildFertilizerStat('P:', crop.p)),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(child: _buildFertilizerStat('K:', crop.k)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FertilizerCalculatorScreen(initialCrop: crop),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('See in fertilizer calculator',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),

            _buildListenButton(),
            const SizedBox(height: 16),

            // COMPANIONS
            const Text('Crop companions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildCompanionRow(Icons.handshake_outlined, Colors.green, 'Good companions', crop.goodCompanions.join(', ')),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
             _buildCompanionRow(Icons.gpp_bad_outlined, Colors.red[300]!, 'Bad companions', crop.badCompanions.join(', ')),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Plant good companion crops alongside your main crop to help it grow better or keep pests and diseases away.\n\nAvoid planting bad companion crops near your main crop because they can harm its growth or attract pests and diseases.',
                      style: TextStyle(color: Colors.black87, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildListenButton() {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.volume_up, color: Color(0xFF1565C0)),
      label: const Text('Listen', style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold, fontSize: 16)),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildGridSection(List<_GridItemData> items) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // Determine border decorations for the internal grid lines
          final isRightCol = index % 2 != 0;
          final isBottomRow = index >= items.length - 2; // Approximation

          return Container(
            decoration: BoxDecoration(
              border: Border(
                right: isRightCol ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
                bottom: isBottomRow ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAF6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: const Color(0xFF1565C0), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.title, style: TextStyle(fontSize: 12, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(item.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFertilizerStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildCompanionRow(IconData icon, Color iconColor, String title, String list) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              const SizedBox(height: 4),
              Text(list, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}

class _GridItemData {
  final IconData icon;
  final String title;
  final String value;

  _GridItemData({required this.icon, required this.title, required this.value});
}
