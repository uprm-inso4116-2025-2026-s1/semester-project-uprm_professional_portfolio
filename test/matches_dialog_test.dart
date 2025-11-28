import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uprm_professional_portfolio/features/matches.dart';
import '../../lib/features/matches.dart';

void main() {
  final mockUser = {
    'id': 's1',
    'name': 'John Doe',
    'description': 'Software Developer with Flutter experience',
    'job_roles': ['Software Engineer', 'Mobile Developer'],
    'graduationYear': '2024',
    'skills': ['Flutter', 'Dart', 'Firebase'],
    'willing_to_relocate': true,
    'github_url': 'https://github.com/johndoe'
  };

  final mockUserWithNulls = {
    'id': 's2',
    'name': 'Jane Smith',
    'description': 'Recent graduate',
    'job_roles': ['Frontend Developer'],
    'graduationYear': '2023',
    'skills': [],
    'willing_to_relocate': false,
    'github_url': null
  };

  group('Profile Dialog Tests', () {
    testWidgets('Dialog closes when Close button is pressed',
        (WidgetTester tester) async {
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
                        content: const Text('Profile content'),
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

      // Open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text('John Doe\'s Profile'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('John Doe\'s Profile'), findsNothing);
    });

    testWidgets('Dialog handles null GitHub URL correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      final user = mockUserWithNulls;
                      return AlertDialog(
                        title: Text('${user['name']}\'s Profile'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Major: ${user['job_roles'].join()}'),
                              const SizedBox(height: 8),
                              Text(
                                  'Graduation year: ${user['graduationYear']}'),
                              const SizedBox(height: 8),
                              Text('Bio: ${user['description']}'),
                              const SizedBox(height: 8),
                              Text('Skills: ${user['skills'].join(', ')}'),
                              const SizedBox(height: 8),
                              Text(
                                  'Willing to relocate: ${user['willing_to_relocate']}'),
                              const SizedBox(height: 8),
                              if ('${user['github_url']}' == 'null')
                                const Text('Portfolio: no link provided'),
                              if ('${user['github_url']}' != 'null')
                                Text('${user['github_url']}'),
                              const SizedBox(height: 8),
                              const Text('Resume: Available upon request'),
                              const SizedBox(height: 8),
                              Text(
                                  'Job Preferences: ${user['job_roles'].join(', ')}'),
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

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Portfolio: no link provided'), findsOneWidget);
    });

    testWidgets('Dialog is scrollable for long content',
        (WidgetTester tester) async {
      final userWithLongContent = Map<String, dynamic>.from(mockUser);
      userWithLongContent['description'] = 'A'.repeat(500);
      userWithLongContent['skills'] = [
        'Skill1',
        'Skill2',
        'Skill3',
        'Skill4',
        'Skill5',
        'Skill6',
        'Skill7',
        'Skill8',
        'Skill9',
        'Skill10'
      ];

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
                        title:
                            Text('${userWithLongContent['name']}\'s Profile'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Bio: ${userWithLongContent['description']}'),
                              Text(
                                  'Skills: ${userWithLongContent['skills'].join(', ')}'),
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

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
