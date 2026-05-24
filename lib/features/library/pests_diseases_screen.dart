import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization_provider.dart';

class PestsDiseasesScreen extends ConsumerWidget {
  const PestsDiseasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localizationProvider);
    final strings = ref.watch(localizationProvider.notifier).strings;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(strings['lib_pests_diseases'] ?? 'Pests & Diseases', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Common Threats',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B263B),
              ),
            ),
          ),
          _buildPestCard(
            strings: strings,
            title: 'Fall Armyworm',
            category: 'Pest - Maize & Cereals',
            symptoms: 'Ragged holes in leaves, sawdust-like frass near the whorl. Often found feeding deep inside the plant whorl.',
            treatment: 'Apply neem oil or approved insecticides early in the morning or late evening. Intercrop with legumes to repel pests.',
            icon: '🐛',
          ),
          const SizedBox(height: 16),
          _buildPestCard(
            strings: strings,
            title: 'Cassava Mosaic Disease (CMD)',
            category: 'Disease - Cassava',
            symptoms: 'Yellow/green mottling on leaves, severely stunted growth, and twisted or distorted leaflets.',
            treatment: 'Plant disease-resistant varieties. Uproot and burn infected plants immediately to prevent spread. Control whiteflies.',
            icon: '🍂',
          ),
          const SizedBox(height: 16),
          _buildPestCard(
            strings: strings,
            title: 'Tomato Late Blight',
            category: 'Disease - Tomato & Potato',
            symptoms: 'Dark, water-soaked spots on leaves. White fungal growth on undersides during wet weather. Fruits turn brown and rot.',
            treatment: 'Apply copper-based fungicides proactively. Ensure proper plant spacing for air circulation. Avoid overhead watering.',
            icon: '🍅',
          ),
          const SizedBox(height: 16),
          _buildPestCard(
            strings: strings,
            title: 'Aphids',
            category: 'Pest - General',
            symptoms: 'Curling, yellowing leaves. Sticky honeydew residue on plant surfaces, which often leads to black sooty mold.',
            treatment: 'Introduce natural predators like ladybugs. Use insecticidal soap sprays or neem oil. Avoid excessive nitrogen fertilizers.',
            icon: '🐜',
          ),
          const SizedBox(height: 16),
          _buildPestCard(
            strings: strings,
            title: 'Maize Lethal Necrosis (MLN)',
            category: 'Disease - Maize',
            symptoms: 'Severe mottling, dead spots on leaves, premature aging, and empty or malformed cobs. Plants die rapidly.',
            treatment: 'Practice crop rotation. Do not plant maize back-to-back in the same field. Use certified disease-free seeds.',
            icon: '🌽',
          ),
        ],
      ),
    );
  }

  Widget _buildPestCard({
    required Map<String, String> strings,
    required String title,
    required String category,
    required String symptoms,
    required String treatment,
    required String icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B263B))),
                    const SizedBox(height: 4),
                    Text(category, style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1, thickness: 1),
          ),
          Text(strings['lib_symptoms'] ?? 'Symptoms', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B263B))),
          const SizedBox(height: 6),
          Text(symptoms, style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.4)),
          const SizedBox(height: 16),
          Text(strings['lib_treatment'] ?? 'Treatment & Prevention', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B263B))),
          const SizedBox(height: 6),
          Text(treatment, style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}
