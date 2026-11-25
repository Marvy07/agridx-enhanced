import 'package:flutter/material.dart';

class AnimalListScreen extends StatelessWidget {
  const AnimalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animals')),
      body: const Center(child: Text('Animals coming soon')),
    );
  }
}
