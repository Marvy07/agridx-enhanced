import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization_provider.dart';

class PrivacySecurityScreen extends ConsumerWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localizationProvider);
    final strings = ref.watch(localizationProvider.notifier).strings;

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
          strings['privacy_security']!,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildPrivacyItem(context, 'Privacy Policy', 'Your data is securely stored locally. We only collect diagnostic images if you explicitly opt-in.'),
          _buildPrivacyItem(context, 'Terms of Service', 'By using AgriDx, you agree to use the application for agricultural purposes only.'),
          _buildPrivacyItem(context, 'App Permissions', 'Camera: Required for scanning leaves.\nLocation: Required for localized weather alerts.'),
        ],
      ),
    );
  }

  Widget _buildPrivacyItem(BuildContext context, String title, String content) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
