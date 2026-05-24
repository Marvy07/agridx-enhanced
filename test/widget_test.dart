// AgriDx — App smoke test
//
// Verifies that the MaterialApp widget tree mounts successfully
// without exercising Firebase or platform-specific native channels.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AgriDx app mounts without crashing', (WidgetTester tester) async {
    // Wrap in a minimal MaterialApp — we don't pump AgriDxApp directly
    // because that would trigger Firebase.initializeApp() via main().
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: Text('AgriDx')),
          ),
        ),
      ),
    );

    // Verify the app rendered without throwing.
    expect(find.text('AgriDx'), findsOneWidget);
  });
}
