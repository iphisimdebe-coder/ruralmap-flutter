import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ruralmap/main.dart';
import 'package:ruralmap/providers/auth_provider.dart';
import 'package:ruralmap/screens/admin_screen.dart';
import 'package:ruralmap/wizard_steps/site_type_step.dart';
import 'package:ruralmap/models/site.dart';

void main() {
  group('App Navigation Tests', () {
    testWidgets('app shows dashboard and profile navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
          ],
          child: const MaterialApp(home: GeoRuraApp()),
        ),
      );
      await tester.pumpAndSettle();

      // Look for BottomNavigationBar items by icon or text
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      
      // Or if you use text labels
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('registration wizard opens on the first step', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SiteTypeStep(
              selectedType: SiteType.house,
              onTypeSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for the heading text that's actually in SiteTypeStep
      expect(find.text('Site Registration'), findsOneWidget);
      expect(find.text('Select the primary type of location you are registering.'), findsOneWidget);
      
      // Check that at least one SiteType card renders
      expect(find.text('House'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);
    });
  });

  group('Admin Screen Tests', () {
    testWidgets('admin screen renders tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AdminScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Admin Panel'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Data'), findsOneWidget);
    });
  });
}