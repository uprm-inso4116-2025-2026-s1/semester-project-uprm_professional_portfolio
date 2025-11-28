import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uprm_professional_portfolio/features/matches.dart';
import '../../lib/features/matches.dart';

void main() {
  final mockUser = {
    'id': 's1',
    'name': 'John Doe',
    'description': 'Software Developer',
    'job_roles': ['Software Engineer'],
    'graduationYear': '2024',
    'skills': ['Flutter', 'Dart'],
    'willing_to_relocate': true,
    'github_url': 'https://github.com/johndoe'
  };

  group('Profile Card Specific Tests', () {
    testWidgets('Card has correct elevation and border radius',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MatchesState()._buildProfileCard(mockUser),
        ),
      ));

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 8);
      expect((card.shape as RoundedRectangleBorder).borderRadius,
          BorderRadius.circular(20));
    });

    testWidgets('Stack children are properly arranged',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MatchesState()._buildProfileCard(mockUser),
        ),
      ));

      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('Gradient overlay is applied', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MatchesState()._buildProfileCard(mockUser),
        ),
      ));

      final containers = find.byType(Container);
      expect(containers, findsAtLeast(2));
    });

    testWidgets('User info is positioned at bottom',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MatchesState()._buildProfileCard(mockUser),
        ),
      ));

      final positioned = tester.widget<Positioned>(find.byType(Positioned));
      expect(positioned.left, 20);
      expect(positioned.bottom, 30);
    });
  });
}
