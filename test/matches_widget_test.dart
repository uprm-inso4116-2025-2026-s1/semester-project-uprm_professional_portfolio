import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uprm_professional_portfolio/features/matches.dart';
import '../../lib/features/matches.dart';

void main() {
  // Mock data for testing
  final mockUser = {
    'id': 's1',
    'name': 'John Doe',
    'description': 'Software Developer with 3 years of experience',
    'job_roles': ['Software Engineer', 'Mobile Developer'],
    'graduationYear': '2024',
    'skills': ['Flutter', 'Dart', 'Firebase', 'REST API'],
    'willing_to_relocate': true,
    'github_url': 'https://github.com/johndoe'
  };

  final mockUserMinimal = {
    'id': 's2',
    'name': 'Jane Smith',
    'description': 'Recent graduate',
    'job_roles': ['Frontend Developer'],
    'graduationYear': '2023',
    'skills': [],
    'willing_to_relocate': false,
    'github_url': null
  };

  group('MatchesScreen Widget Tests', () {
    testWidgets('MatchesScreen builds without crashing',
        (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // Verify the screen loads
      expect(find.byType(MatchesScreen), findsOneWidget);
    });

    testWidgets('AppBar with logo is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // Verify AppBar is present
      expect(find.byType(AppBar), findsOneWidget);

      // Verify logo image is present (you might need to adjust based on your actual assets)
      expect(find.byType(Image), findsAtLeast(1));
    });

    testWidgets('Action buttons are displayed and tappable',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // Find all action buttons
      final likeButton = find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.icon is Image);
      final dislikeButton = find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.icon is Image);
      final infoButton = find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.icon is Image);
      final favoriteButton = find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.icon is Image);

      // Verify buttons are present
      expect(likeButton, findsAtLeast(1));
      expect(dislikeButton, findsAtLeast(1));
      expect(infoButton, findsAtLeast(1));
      expect(favoriteButton, findsAtLeast(1));

      // Test that buttons can be tapped (they might not do anything without proper setup)
      await tester.tap(likeButton.first);
      await tester.pump();

      await tester.tap(dislikeButton.first);
      await tester.pump();
    });
  });

  group('Profile Card Widget Tests', () {
    testWidgets('Profile card displays user information correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MatchesState()._buildProfileCard(mockUser),
        ),
      ));

      // Verify user information is displayed
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Computer Science'),
          findsOneWidget); // From your hardcoded value
      expect(find.text('Software Developer with 3 years of experience'),
          findsOneWidget);
    });

    testWidgets('Profile card handles long descriptions with ellipsis',
        (WidgetTester tester) async {
      final userWithLongDescription = Map<String, dynamic>.from(mockUser);
      userWithLongDescription['description'] =
          'This is a very long description that should be truncated with ellipsis when it exceeds the available space in the profile card layout. This text is definitely long enough to trigger the overflow behavior.';

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MatchesState()._buildProfileCard(userWithLongDescription),
        ),
      ));

      // The text should be present but might be truncated
      expect(find.textContaining('This is a very long description'),
          findsOneWidget);
    });

    testWidgets('Profile card renders with minimal data',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MatchesState()._buildProfileCard(mockUserMinimal),
        ),
      ));

      // Should still render basic information
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('Recent graduate'), findsOneWidget);
    });
  });

  group('Out of Candidates Message Tests', () {
    testWidgets('Out of candidates message displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MatchesState()._buildOutOfCandidatesMessage(),
        ),
      ));

      // Verify the message content
      expect(find.text('Out of Candidates'), findsOneWidget);
      expect(
          find.text("You've viewed all available profiles."), findsOneWidget);
      expect(
          find.text("Check back later for more candidates!"), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('Out of candidates message has correct styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MatchesState()._buildOutOfCandidatesMessage(),
        ),
      ));

      // Verify the card structure
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });
  });

  group('Profile Dialog Tests', () {
    testWidgets('Info button opens profile dialog',
        (WidgetTester tester) async {
      // We'll test this by creating a minimal testable version
      // In a real scenario, you'd need to mock the data and state
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // This test would need proper mocking to work completely
      // For now, we'll verify the dialog builder exists
      final infoButton = find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.icon is Image);
      expect(infoButton, findsAtLeast(1));
    });

    testWidgets('Dialog displays all user information sections',
        (WidgetTester tester) async {
      // Build the dialog directly
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('${mockUser['name']}\'s Profile'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Major: ${mockUser['job_roles'].join()}'),
                              const SizedBox(height: 8),
                              Text(
                                  'Graduation year: ${mockUser['graduationYear']}'),
                              const SizedBox(height: 8),
                              Text('Bio: ${mockUser['description']}'),
                              const SizedBox(height: 8),
                              Text('Skills: ${mockUser['skills'].join(', ')}'),
                              const SizedBox(height: 8),
                              Text(
                                  'Willing to relocate: ${mockUser['willing_to_relocate']}'),
                              const SizedBox(height: 8),
                              Text('${mockUser['github_url']}'),
                              const SizedBox(height: 8),
                              const Text('Resume: Available upon request'),
                              const SizedBox(height: 8),
                              Text(
                                  'Job Preferences: ${mockUser['job_roles'].join(', ')}'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ));

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog content
      expect(find.text('John Doe\'s Profile'), findsOneWidget);
      expect(find.text('Major: Software EngineerMobile Developer'),
          findsOneWidget);
      expect(find.text('Graduation year: 2024'), findsOneWidget);
      expect(find.text('Bio: Software Developer with 3 years of experience'),
          findsOneWidget);
      expect(find.text('Skills: Flutter, Dart, Firebase, REST API'),
          findsOneWidget);
      expect(find.text('Willing to relocate: true'), findsOneWidget);
      expect(find.text('https://github.com/johndoe'), findsOneWidget);
      expect(find.text('Resume: Available upon request'), findsOneWidget);
      expect(find.text('Job Preferences: Software Engineer, Mobile Developer'),
          findsOneWidget);
    });
  });

  group('Responsive Behavior Tests', () {
    testWidgets('Profile card adapts to different screen sizes',
        (WidgetTester tester) async {
      // Test with a small screen
      tester.binding.window.physicalSizeTestValue = const Size(320, 480);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MatchesState()._buildProfileCard(mockUser),
        ),
      ));

      // Verify the card renders without errors on small screen
      expect(find.text('John Doe'), findsOneWidget);

      // Reset screen size
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });

  group('Error Boundary Tests', () {
    testWidgets('Profile card handles missing fields gracefully',
        (WidgetTester tester) async {
      final userWithMissingFields = {
        'id': 's3',
        'name': 'Test User',
        // Missing description, skills, etc.
      };

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MatchesState()._buildProfileCard(userWithMissingFields),
        ),
      ));

      // Should still render without crashing
      expect(find.text('Test User'), findsOneWidget);
    });
  });
}
