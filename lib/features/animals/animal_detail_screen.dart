import 'package:flutter/material.dart';

class AnimalDetailScreen extends StatelessWidget {
  final String animalId;
  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animal Detail')),
      body: Center(child: Text('Animal $animalId coming soon')),
    );
  }
}
