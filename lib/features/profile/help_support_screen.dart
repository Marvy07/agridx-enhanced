import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization_provider.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

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
          strings['help_support']!,
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
          _buildHelpItem(context, Icons.question_answer, 'FAQs', '1. How to scan?\nTap the camera button and take a clear photo of the affected leaf.\n\n2. Do I need internet?\nNo, scanning works completely offline!'),
          _buildHelpItem(context, Icons.email, 'Contact Support', 'Email us at ndesoplacid8@gmail.com\n\nCall us: +237 671859142'),
          _buildHelpItem(context, Icons.book, 'User Guide', 'Welcome to AgriDx! Use the scanner to diagnose diseases. Check the weather tab for local alerts. Save your diagnoses to view them later.'),
        ],
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, IconData icon, String title, String content) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
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
