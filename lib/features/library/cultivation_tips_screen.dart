import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization_provider.dart';
import 'tip_detail_screen.dart';

class CultivationTip {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final String readTime;
  final IconData icon;
  final Color color;
  final List<String> sections;

  CultivationTip({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.readTime,
    required this.icon,
    required this.color,
    required this.sections,
  });
}

class CultivationTipsScreen extends ConsumerStatefulWidget {
  const CultivationTipsScreen({super.key});

  @override
  ConsumerState<CultivationTipsScreen> createState() => _CultivationTipsScreenState();
}

class _CultivationTipsScreenState extends ConsumerState<CultivationTipsScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  
  final List<String> _categories = ['All', 'Planting', 'Irrigation', 'Fertilizing', 'Harvesting', 'Pest Control'];

  final List<CultivationTip> _tips = [
    CultivationTip(
      id: '1',
      title: 'Best time to plant maize in Ghana',
      subtitle: 'Optimal planting windows for maximum yield',
      description: 'The major season starts in April/May in the south and June/July in the north.',
      category: 'Planting',
      readTime: '5 min read',
      icon: Icons.calendar_today,
      color: Colors.green,
      sections: [
        'Introduction: Maize is a staple crop in Ghana, and timing is critical for success.',
        'Major Season: In the southern regions, the best time is between April and May after the first rains.',
        'Minor Season: A second planting can occur in September for shorter duration varieties.',
        'Northern Regions: Due to the single rainy season, June to July is the ideal window.',
        'Tips: Ensure the soil is consistently moist before sowing. Use improved seed varieties for better resistance.'
      ],
    ),
    CultivationTip(
      id: '2',
      title: 'Irrigation schedule for tomatoes',
      subtitle: 'Water management strategies for healthy fruit',
      description: 'Tomatoes need consistent moisture. Avoid overhead watering to prevent blight.',
      category: 'Irrigation',
      readTime: '4 min read',
      icon: Icons.water_drop,
      color: Colors.blue,
      sections: [
        'Consistency: Irregular watering causes blossom end rot and fruit cracking.',
        'Morning Watering: Always water in the early morning to allow leaves to dry.',
        'Drip Irrigation: The most efficient method for tomatoes, delivering water to the roots.',
        'Mulching: Use straw or plastic mulch to retain soil moisture and reduce weeds.',
        'Growth Stages: Increase water during flowering and fruit setting stages.'
      ],
    ),
    CultivationTip(
      id: '3',
      title: 'Organic fertilizer preparation',
      subtitle: 'Making nutrient-rich compost at home',
      description: 'Learn how to turn farm waste into "black gold" for your soil.',
      category: 'Fertilizing',
      readTime: '6 min read',
      icon: Icons.eco,
      color: Colors.brown,
      sections: [
        'Compost Pile Basics: Mix green (nitrogen) and brown (carbon) materials.',
        'Moisture and Air: Keep the pile damp and turn it every 2 weeks for aeration.',
        'Avoid: Do not add meat, dairy, or diseased plant material.',
        'Application: Mix finished compost into the top 10cm of soil before planting.',
        'Liquid Gold: Learn to make compost tea for a quick nutrient boost.'
      ],
    ),
    CultivationTip(
      id: '4',
      title: 'Companion planting guide',
      subtitle: 'Natural pest control through crop diversity',
      description: 'Planting marigolds with tomatoes or beans with maize helps deter pests.',
      category: 'Pest Control',
      readTime: '5 min read',
      icon: Icons.handshake,
      color: Colors.orange,
      sections: [
        'The Three Sisters: The classic combination of Maize, Beans, and Squash.',
        'Natural Repellents: Planting onions or garlic near carrots protects them from flies.',
        'Attracting Beneficials: Sunflowers and marigolds attract pollinators and predatory insects.',
        'Dynamic Accumulators: Comfrey and clover bring nutrients from deep in the soil.',
        'Trap Cropping: Planting mustard near cabbage to attract moths away from the main crop.'
      ],
    ),
    CultivationTip(
      id: '5',
      title: 'Post harvest storage tips',
      subtitle: 'Reducing losses after the harvest',
      description: 'Proper drying and ventilation are key to long-term storage of grains.',
      category: 'Harvesting',
      readTime: '4 min read',
      icon: Icons.inventory,
      color: Colors.amber,
      sections: [
        'Moisture Content: Ensure grains are dried below 13% moisture before bagging.',
        'Airtight Storage: Use PICS bags to prevent insect infestation without chemicals.',
        'Ventilation: Keep storage areas cool, dry, and well-ventilated for tubers like yams.',
        'Cleanliness: Scrupulously clean storage facilities before bringing in a new harvest.',
        'Regular Inspection: Check stored produce every week for signs of damp or pests.'
      ],
    ),
    CultivationTip(
      id: '6',
      title: 'Integrated pest management',
      subtitle: 'Balanced approach to crop protection',
      description: 'Combine biological, cultural, and mechanical controls to manage pests.',
      category: 'Pest Control',
      readTime: '7 min read',
      icon: Icons.gpp_good,
      color: Colors.teal,
      sections: [
        'Monitoring: Regularly scout fields to identify pests early.',
        'Mechanical Control: Hand-picking pests or using traps for small infestations.',
        'Cultural Control: Crop rotation and choosing resistant varieties.',
        'Biological Control: Encouraging natural enemies like ladybirds and spiders.',
        'Chemical as Last Resort: Use targeted, low-toxicity pesticides only when necessary.'
      ],
    ),
    CultivationTip(
      id: '7',
      title: 'Soil preparation techniques',
      subtitle: 'Foundation for a successful farm',
      description: 'Minimum tillage and proper harrowing improve soil structure and health.',
      category: 'Planting',
      readTime: '5 min read',
      icon: Icons.landscape,
      color: Colors.deepOrange,
      sections: [
        'Testing: Always test your soil pH and nutrient levels before the season.',
        'Minimum Tillage: Avoid over-plowing to preserve soil microorganisms.',
        'Organic Matter: Incorporate manure or compost several weeks before planting.',
        'Erosion Control: Create ridges or contours on sloped land.',
        'Weed Management: Clear the field thoroughly but avoid burning residue.'
      ],
    ),
    CultivationTip(
      id: '8',
      title: 'Seed selection guide',
      subtitle: 'Choosing the right start for your crop',
      description: 'Select seeds based on maturity time, disease resistance, and market demand.',
      category: 'Planting',
      readTime: '4 min read',
      icon: Icons.grain,
      color: Colors.lightGreen,
      sections: [
        'Source: Buy certified seeds from reputable dealers to ensure high germination.',
        'Site Specificity: Choose varieties adapted to your specific ecological zone.',
        'Resistance: Prioritize seeds with resistance to local pests (e.g., Striga-resistant maize).',
        'Market Needs: Plant varieties that are preferred by local buyers or processing units.',
        'Seed Treatment: Ensure seeds are treated against soil-borne diseases.'
      ],
    ),
    CultivationTip(
      id: '9',
      title: 'Crop rotation benefits',
      subtitle: 'Maintaining soil health year after year',
      description: 'Alternate legumes with cereals to naturally replenish nitrogen levels.',
      category: 'Planting',
      readTime: '5 min read',
      icon: Icons.loop,
      color: Colors.indigo,
      sections: [
        'Nutrient Balancing: Different crops use different nutrients, preventing depletion.',
        'Pest Cycle Interruption: Rotating crops breaks the life cycle of soil-borne pests.',
        'Disease Management: Reduces the buildup of pathogens specific to one crop family.',
        'Weed Control: Different growth habits help suppress varied weed species.',
        'Legume Effect: Including beans or peas adds nitrogen back to the soil.'
      ],
    ),
    CultivationTip(
      id: '10',
      title: 'Rainwater harvesting for farms',
      subtitle: 'Securing water during the dry season',
      description: 'Capture and store rain to ensure your farm survives during droughts.',
      category: 'Irrigation',
      readTime: '6 min read',
      icon: Icons.umbrella,
      color: Colors.cyan,
      sections: [
        'Roof Catchment: Collect water from farm buildings into tanks or barrels.',
        'Surface Runoff: Creating small ponds or earth dams to trap field runoff.',
        'Silt Traps: Use gravel filters to keep sediment out of your storage structures.',
        'Groundwater Recharge: Digging pits to help rain soak into the aquifer.',
        'Micro-catchments: Contouring soil around individual trees or plants.'
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    ref.watch(localizationProvider);
    final strings = ref.watch(localizationProvider.notifier).strings;
    final filteredTips = _tips.where((tip) {
      final matchesCategory = _selectedCategory == 'All' || tip.category == _selectedCategory;
      final matchesSearch = tip.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                           tip.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(strings['lib_cultivation_tips'] ?? 'Cultivation Tips', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expert farming guides for African crops',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildCategoryFilter(),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: filteredTips.length,
              itemBuilder: (context, index) {
                return _buildTipCard(context, filteredTips[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: const InputDecoration(
          hintText: 'Search for tips...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (val) {
                setState(() => _selectedCategory = category);
              },
              backgroundColor: Colors.grey[50],
              selectedColor: const Color(0xFF43A047).withOpacity(0.2),
              checkmarkColor: const Color(0xFF43A047),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF43A047) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: isSelected ? const Color(0xFF43A047) : Colors.grey[200]!),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, CultivationTip tip) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TipDetailScreen(tip: tip)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border(
            left: BorderSide(color: tip.color, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tip.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(tip.icon, color: tip.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Read more',
                          style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tip.readTime,
                            style: TextStyle(color: Colors.grey[700], fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
