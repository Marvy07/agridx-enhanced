import 'package:flutter/material.dart';
import 'crop_selector_screen.dart';
import 'cultivation_tips_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2x2 Grid Menu
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Taller cards for better label fit
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Scroll managed by body
              children: [
                _buildMenuCard(
                  context,
                  title: 'Crops',
                  icon: Icons.grass,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CropSelectorScreen()));
                  },
                ),
                _buildMenuCard(
                  context,
                  title: 'Pests & Diseases',
                  icon: Icons.bug_report,
                ),
                _buildMenuCard(
                  context,
                  title: 'Cultivation Tips',
                  icon: Icons.eco,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CultivationTipsScreen()));
                  },
                ),
                _buildMenuCard(
                  context,
                  title: 'Pests & Disease Alert',
                  icon: Icons.warning_amber_rounded,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Top Videos Section
            Row(
              children: const [
                Text('TOP VIDEOS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                SizedBox(width: 8),
                Text('🔥', style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildVideoCard('How to prune your tomatoes correctly'),
                  _buildVideoCard('Identifying early signs of Fall Armyworm'),
                  _buildVideoCard('Best fertilizers for maximum yield'),
                ],
              ),
            ),
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE7F6), // Light purple
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: const Color(0xFF5E35B1)), // Deep purple icon
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4527A0),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(String title) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.black12, // Placeholder for actual image
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1592982537447-6f296c0080ae?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=60'), // Placeholder ag image
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          // Play button
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF43A047), // Green play button
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
            ),
          ),
          // Title
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
