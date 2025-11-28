import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uprm_professional_portfolio/features/matches.dart';
import 'package:uprm_professional_portfolio/models/swipe_process.dart';
import 'package:uprm_professional_portfolio/services/swipe_process_repository.dart';
import 'package:uprm_professional_portfolio/mock/matches_local_repository.dart';

// Mock repositories
// Simple mock repositories without external mockito dependency
class MockSwipeProcessRepository implements SwipeProcessRepository {
  @override
  Future<void> insertSwipe(dynamic swipe) async {}

  // If SwipeProcessRepository has other methods used in tests, add no-op implementations here.
}

class MockLocalRepository implements LocalRepository {
  @override
  Future<void> insertFavorite(dynamic favorite) async {}

  @override
  Future<void> removeFavorite() async {}

  // If LocalRepository has other methods used in tests, add no-op implementations here.
}
void main() {
  late MockSwipeProcessRepository mockSwipeRepository;
  late MockLocalRepository mockLocalRepository;

  // Sample test data
  final sampleCandidates = [
    {
      'id': 's1',
      'name': 'John Doe',
      'description': 'Computer Science student with internship experience',
      'job_roles': ['Software Developer', 'Frontend Engineer'],
      'graduationYear': '2024',
      'skills': ['Flutter', 'Dart', 'JavaScript'],
      'willing_to_relocate': true,
      'github_url': 'https://github.com/johndoe'
    },
    {
      'id': 's2',
      'name': 'Jane Smith',
      'description': 'Data Science major looking for ML opportunities',
      'job_roles': ['Data Scientist', 'ML Engineer'],
      'graduationYear': '2025',
      'skills': ['Python', 'TensorFlow', 'SQL'],
      'willing_to_relocate': false,
      'github_url': null
    },
    {
  setUp(() {
    mockSwipeRepository = MockSwipeProcessRepository();
    mockLocalRepository = MockLocalRepository();

    // No external mocking framework required; our mock implementations are no-ops.
  });
  ];

  setUp(() {
    mockSwipeRepository = MockSwipeProcessRepository();
    mockLocalRepository = MockLocalRepository();

    // Mock the repository calls
    when(mockSwipeRepository.insertSwipe(any)).thenAnswer((_) async {});
    when(mockLocalRepository.insertFavorite(any)).thenAnswer((_) async {});
    when(mockLocalRepository.removeFavorite()).thenAnswer((_) async {});
  });

  group('Matches Screen Integration Tests', () {
    testWidgets('TC001: Display first candidate profile on screen load',
        (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // Verify the profile card is displayed with correct information
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Computer Science'), findsOneWidget);
      expect(find.text('Computer Science student with internship experience'),
          findsOneWidget);

      // Verify action buttons are present
      expect(find.byType(IconButton),
          findsNWidgets(4)); // Like, Dislike, Info, Favorite
    });

    testWidgets('TC002: Like action moves to next candidate',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // Verify first candidate is displayed
      expect(find.text('John Doe'), findsOneWidget);

      // Tap the like button
      await tester.tap(find.byWidgetPredicate((widget) =>
          widget is IconButton &&
          widget.icon is Image &&
          (widget.icon as Image).image is AssetImage &&
          (widget.icon as Image)
              .image
              .toString()
              .contains('matches_accept_button.png')));
      await tester.pumpAndSettle();

      // Verify next candidate is displayed
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('John Doe'), findsNothing);
    });

    testWidgets('TC003: Dislike action moves to next candidate',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // Verify first candidate is displayed
      expect(find.text('John Doe'), findsOneWidget);

      // Tap the dislike button
      await tester.tap(find.byWidgetPredicate((widget) =>
          widget is IconButton &&
          widget.icon is Image &&
          (widget.icon as Image).image is AssetImage &&
          (widget.icon as Image)
              .image
              .toString()
              .contains('matches_skip_button.png')));
      await tester.pumpAndSettle();

      // Verify next candidate is displayed
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('TC004: Info button displays detailed profile dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // Tap the info button
      await tester.tap(find.byWidgetPredicate((widget) =>
          widget is IconButton &&
          widget.icon is Image &&
          (widget.icon as Image).image is AssetImage &&
          (widget.icon as Image)
              .image
              .toString()
              .contains('matches_info_button.png')));
      await tester.pumpAndSettle();

      // Verify dialog is displayed with detailed information
      expect(find.text('John Doe\'s Profile'), findsOneWidget);
      expect(find.text('Major: Software DeveloperFrontend Engineer'),
          findsOneWidget);
      expect(find.text('Graduation year: 2024'), findsOneWidget);
      expect(
          find.text('Bio: Computer Science student with internship experience'),
          findsOneWidget);
      expect(find.text('Skills: Flutter, Dart, JavaScript'), findsOneWidget);
      expect(find.text('Willing to relocate: true'), findsOneWidget);
      expect(
          find.text('Portfolio: https://github.com/johndoe'), findsOneWidget);
      expect(find.text('Resume: Available upon request'), findsOneWidget);
      expect(
          find.text('Job Preferences: Software Developer, Frontend Engineer'),
          findsOneWidget);

      // Close the dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('John Doe\'s Profile'), findsNothing);
    });

    testWidgets('TC005: Favorite button toggles star state',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // Verify initial state (unfilled star)
      final favoriteButton = find
          .byWidgetPredicate(
              (widget) => widget is IconButton && widget.icon is Image)
          .at(3); // Fourth button is favorite

      // Tap to add to favorites
      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();

      // The UI should update to show filled star (state change)
      // Note: This tests the state change visually if we could verify the image change
      // In practice, you'd verify through other means like checking if the method was called

      // Tap again to remove from favorites
      await tester.tap(favoriteButton);
      await tester.pumpAndSettle();
    });

    testWidgets(
        'TC006: Navigate through all candidates shows out of candidates message',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // Like all candidates
      for (int i = 0; i < sampleCandidates.length; i++) {
        await tester.tap(find.byWidgetPredicate((widget) =>
            widget is IconButton &&
            widget.icon is Image &&
            (widget.icon as Image).image is AssetImage &&
            (widget.icon as Image)
                .image
                .toString()
                .contains('matches_accept_button.png')));
        await tester.pumpAndSettle();
      }

      // Verify out of candidates message is displayed
      expect(find.text('Out of Candidates'), findsOneWidget);
      expect(
          find.text(
              'You\'ve viewed all available profiles.\nCheck back later for more candidates!'),
          findsOneWidget);

      // Verify action buttons are no longer visible (hidden by the message)
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('TC007: Profile card displays correct user information',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // Verify all profile information is correctly displayed
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Computer Science'),
          findsOneWidget); // Hardcoded in the widget
      expect(find.text('Computer Science student with internship experience'),
          findsOneWidget);

      // Verify the card has proper styling
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('TC008: App bar displays correct branding',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // Verify app bar properties
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Image), findsOneWidget); // Logo image

      // Verify app bar color
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect((appBar.backgroundColor as Color).value,
          const Color(0xFF2B7D61).value);
    });

    testWidgets('TC009: Mixed actions sequence (like, dislike, favorite)',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // Perform sequence of actions
      // 1. View info for first candidate
      await tester.tap(find.byWidgetPredicate((widget) =>
          widget is IconButton &&
          widget.icon is Image &&
          (widget.icon as Image).image is AssetImage &&
          (widget.icon as Image)
              .image
              .toString()
              .contains('matches_info_button.png')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // 2. Add to favorites
      await tester.tap(find
          .byWidgetPredicate(
              (widget) => widget is IconButton && widget.icon is Image)
          .at(3));
      await tester.pumpAndSettle();

      // 3. Like first candidate
      await tester.tap(find.byWidgetPredicate((widget) =>
          widget is IconButton &&
          widget.icon is Image &&
          (widget.icon as Image).image is AssetImage &&
          (widget.icon as Image)
              .image
              .toString()
              .contains('matches_accept_button.png')));
      await tester.pumpAndSettle();

      // 4. Dislike second candidate
      expect(find.text('Jane Smith'), findsOneWidget);
      await tester.tap(find.byWidgetPredicate((widget) =>
          widget is IconButton &&
          widget.icon is Image &&
          (widget.icon as Image).image is AssetImage &&
          (widget.icon as Image)
              .image
              .toString()
              .contains('matches_skip_button.png')));
      await tester.pumpAndSettle();

      // Verify third candidate is displayed
      expect(find.text('Bob Wilson'), findsOneWidget);
    });

    testWidgets('TC010: Screen layout and responsive design',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MatchesScreen()));

      // Verify main layout structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);

      // Verify profile card takes appropriate space
      final profileCard = find.byType(Card).first;
      expect(profileCard, findsOneWidget);

      // Verify action buttons row is present
      expect(find.byType(Row), findsOneWidget);
    });
  });
}
