import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization_provider.dart';
import 'pesticide_data.dart';

class PesticideGuideScreen extends ConsumerStatefulWidget {
  const PesticideGuideScreen({super.key});

  @override
  ConsumerState<PesticideGuideScreen> createState() => _PesticideGuideScreenState();
}

class _PesticideGuideScreenState extends ConsumerState<PesticideGuideScreen> {
  String _searchQuery = '';

  List<PesticideDetails> get _filteredPesticides {
    if (_searchQuery.isEmpty) return availablePesticides;
    final query = _searchQuery.toLowerCase();
    return availablePesticides.where((p) {
      return p.name.toLowerCase().contains(query) ||
             p.targetPests.toLowerCase().contains(query) ||
             p.activeIngredient.toLowerCase().contains(query);
    }).toList();
  }

  void _showPesticideDetails(PesticideDetails pesticide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PesticideDetailSheet(pesticide: pesticide),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(localizationProvider.notifier).strings;
    final pesticides = _filteredPesticides;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          strings['pesticide_guide_title'] ?? 'Pesticide Guide',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: strings['search_pesticides'] ?? 'Search pesticides or pests...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: pesticides.isEmpty
                ? Center(
                    child: Text(
                      'No pesticides found for "$_searchQuery"',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: pesticides.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = pesticides[index];
                      return _buildPesticideCard(p);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPesticideCard(PesticideDetails pesticide) {
    Color typeColor;
    if (pesticide.type.toLowerCase().contains('insecticide')) {
      typeColor = Colors.orange[700]!;
    } else if (pesticide.type.toLowerCase().contains('fungicide')) {
      typeColor = Colors.blue[700]!;
    } else if (pesticide.type.toLowerCase().contains('herbicide')) {
      typeColor = Colors.red[700]!;
    } else {
      typeColor = Colors.green[700]!;
    }

    return GestureDetector(
      onTap: () => _showPesticideDetails(pesticide),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pesticide.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pesticide.type,
                    style: TextStyle(color: typeColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pesticide.targetPests,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.science_outlined, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    pesticide.activeIngredient,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PesticideDetailSheet extends ConsumerWidget {
  final PesticideDetails pesticide;

  const _PesticideDetailSheet({required this.pesticide});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(localizationProvider.notifier).strings;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      pesticide.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pesticide.type,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    
                    _buildSection(
                      strings['active_ingredient'] ?? 'Active Ingredient',
                      pesticide.activeIngredient,
                      Icons.science,
                      Colors.blue,
                    ),
                    _buildSection(
                      strings['target_pests'] ?? 'Target Pests & Diseases',
                      pesticide.targetPests,
                      Icons.pest_control,
                      Colors.orange,
                    ),
                    _buildSection(
                      strings['dosage'] ?? 'Recommended Dosage',
                      pesticide.dosage,
                      Icons.water_drop,
                      Colors.cyan,
                    ),
                    _buildSection(
                      strings['application_method'] ?? 'Application Method',
                      pesticide.applicationMethod,
                      Icons.agriculture,
                      Colors.green,
                    ),
                    
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shield_outlined, color: Colors.orange[800], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                strings['safety_precautions'] ?? 'Safety Precautions',
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pesticide.safetyPrecautions,
                            style: TextStyle(color: Colors.orange[900], height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.red[800], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                strings['warning'] ?? 'Warning',
                                style: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pesticide.warning,
                            style: TextStyle(color: Colors.red[900], height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, String content, IconData icon, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color[700], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
