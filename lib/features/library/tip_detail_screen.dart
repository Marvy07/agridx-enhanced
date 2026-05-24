import 'package:flutter/material.dart';
import 'cultivation_tips_screen.dart';

class TipDetailScreen extends StatelessWidget {
  final CultivationTip tip;

  const TipDetailScreen({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: tip.color.withOpacity(0.1),
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border, color: Colors.black)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.share, color: Colors.black)),
            ],
            expandedHeight: 120, // Reduced from mockup to focus on content
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                tip.category,
                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              background: Container(color: tip.color.withOpacity(0.05)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tip.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(tip.icon, color: tip.color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip.title,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip.readTime,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Content Sections
                  ...tip.sections.map((section) {
                    final split = section.split(':');
                    final title = split.length > 1 ? split[0] : '';
                    final content = split.length > 1 ? split.sublist(1).join(':') : section;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                title,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                              ),
                            ),
                          Text(
                            content.trim(),
                            style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 32),
                  
                  // Illustration Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: tip.color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tip.color.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Icon(tip.icon, size: 64, color: tip.color),
                        const SizedBox(height: 16),
                        Text(
                          tip.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: tip.color, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
