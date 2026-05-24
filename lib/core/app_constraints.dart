import 'package:flutter/material.dart';

class AppConstraints extends StatelessWidget {
  final Widget child;
  const AppConstraints({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 393),
        child: child,
      ),
    );
  }
}
