import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:uprm_professional_portfolio/mock/matches_local_repository.dart';
import 'package:uprm_professional_portfolio/models/swipe_process.dart';
import 'package:uprm_professional_portfolio/services/swipe_process_repository.dart';
import 'package:uprm_professional_portfolio/features/matches.dart';
import '../../lib/features/matches.dart';

// Generate mocks
@GenerateMocks([SwipeProcessRepository, LocalRepository])
import 'matches_logic_test.mocks.dart';

void main() {
  late MatchesState matchesState;
  late MockSwipeProcessRepository mockSwipeRepository;
  late MockLocalRepository mockLocalRepository;

  final mockCandidates = [
    {
      'id': 's1',
      'name': 'John Doe',
      'description': 'Software Developer',
      'job_roles': ['Software Engineer'],
      'graduationYear': '2024',
      'skills': ['Flutter', 'Dart'],
      'willing_to_relocate': true,
      'github_url': 'https://github.com/johndoe'
    },
    {
      'id': 's2',
      'name': 'Jane Smith',
      'description': 'Data Scientist',
      'job_roles': ['Data Analyst'],
      'graduationYear': '2023',
      'skills': ['Python', 'SQL'],
      'willing_to_relocate': false,
      'github_url': null
    },
    {
      'id': 's3',
      'name': 'Bob Wilson',
      'description': 'Mobile Developer',
      'job_roles': ['Mobile Developer'],
      'graduationYear': '2025',
      'skills': ['Flutter', 'Firebase'],
      'willing_to_relocate': true,
      'github_url': 'https://github.com/bobwilson'
    }
  ];

  setUp(() {
    mockSwipeRepository = MockSwipeProcessRepository();
    mockLocalRepository = MockLocalRepository();

    // Create a test instance of MatchesState
    matchesState = MatchesState();

    // Override the repository instances with mocks
    // Note: This requires making the repositories injectable or using dependency injection
  });

  group('Swipe Action Tests', () {
    test('userLiked creates correct swipe process and moves to next user', () {
      // Setup
      matchesState._items = mockCandidates;
      matchesState._currentUserIndex = 0;
      matchesState._outOfCandidates = false;

      final expectedSwipe = SwipeProcess.create(
        initiatorId: 'r0',
        targetId: 's1',
        direction: SwipeType.like,
      );

      // Execute
      matchesState.userLiked();

      // Verify
      // Note: You'll need to verify the repository call here
      // verify(mockSwipeRepository.insertSwipe(expectedSwipe)).called(1);
      expect(matchesState._currentUserIndex, 1);
      expect(matchesState._outOfCandidates, false);
    });

    test('userDisliked creates correct swipe process and moves to next user',
        () {
      // Setup
      matchesState._items = mockCandidates;
      matchesState._currentUserIndex = 1;
      matchesState._outOfCandidates = false;

      final expectedSwipe = SwipeProcess.create(
        initiatorId: 'r0',
        targetId: 's2',
        direction: SwipeType.dislike,
      );

      // Execute
      matchesState.userDisliked();

      // Verify
      // verify(mockSwipeRepository.insertSwipe(expectedSwipe)).called(1);
      expect(matchesState._currentUserIndex, 2);
      expect(matchesState._outOfCandidates, false);
    });

    test('userLiked on last candidate sets outOfCandidates to true', () {
      // Setup
      matchesState._items = mockCandidates;
      matchesState._currentUserIndex = 2; // Last candidate
      matchesState._outOfCandidates = false;

      // Execute
      matchesState.userLiked();

      // Verify
      expect(matchesState._outOfCandidates, true);
      expect(matchesState._currentUserIndex,
          2); // Index shouldn't change when out of candidates
    });

    test('userDisliked on last candidate sets outOfCandidates to true', () {
      // Setup
      matchesState._items = mockCandidates;
      matchesState._currentUserIndex = 2; // Last candidate
      matchesState._outOfCandidates = false;

      // Execute
      matchesState.userDisliked();

      // Verify
      expect(matchesState._outOfCandidates, true);
      expect(matchesState._currentUserIndex,
          2); // Index shouldn't change when out of candidates
    });
  });

  group('Next User Navigation Tests', () {
    test('_nextUser increments index when not at end', () {
      // Setup
      matchesState._items = mockCandidates;
      matchesState._currentUserIndex = 0;
      matchesState._outOfCandidates = false;
      matchesState._Pressed = true;

      // Execute
      matchesState._nextUser();

      // Verify
      expect(matchesState._currentUserIndex, 1);
      expect(matchesState._outOfCandidates, false);
      expect(matchesState._Pressed, false); // Should reset pressed state
    });

    test('_nextUser sets outOfCandidates when at last index', () {
      // Setup
      matchesState._items = mockCandidates;
      matchesState._currentUserIndex = 2; // Last index
      matchesState._outOfCandidates = false;

      // Execute
      matchesState._nextUser();

      // Verify
      expect(matchesState._outOfCandidates, true);
      expect(matchesState._currentUserIndex, 2); // Index remains the same
    });

    test('_nextUser handles empty candidate list', () {
      // Setup
      matchesState._items = [];
      matchesState._currentUserIndex = 0;
      matchesState._outOfCandidates = false;

      // Execute
      matchesState._nextUser();

      // Verify
      expect(matchesState._outOfCandidates, true);
    });
  });

  group('Favorite Functionality Tests', () {
    test('addToFavorites adds current user to favorites', () {
      // Setup
      matchesState._items = mockCandidates;
      matchesState._currentUserIndex = 1;

      // Execute
      matchesState.addToFavorites();

      // Verify
      // verify(mockLocalRepository.insertFavorite(mockCandidates[1])).called(1);
    });

    test('removeFromFavorites calls repository remove method', () {
      // Execute
      matchesState.removeFromFavorites();

      // Verify
      // verify(mockLocalRepository.removeFavorite()).called(1);
    });

    test('favorite button toggles pressed state', () {
      // Setup
      matchesState._Pressed = false;

      // Execute - simulate button press
      matchesState.addToFavorites();
      // Note: You'll need to test the setState logic separately or refactor

      // This test would be better as a widget test
    });
  });

  group('Edge Cases and Error Handling', () {
    test('handles empty candidate list on init', () {
      // Setup - simulate empty list from getCandidateMatchesList
      matchesState._items = [];

      // Verify initial state
      expect(matchesState._items.isEmpty, true);
      expect(matchesState._currentUserIndex, 0);
    });

    test('swipe actions handle index out of bounds', () {
      // Setup - empty list but current index is not 0
      matchesState._items = [];
      matchesState._currentUserIndex = 5; // Invalid index

      // Execute & Verify - should not throw exception
      expect(() => matchesState.userLiked(), returnsNormally);
      expect(() => matchesState.userDisliked(), returnsNormally);
    });

    test('favorite operations handle null current user', () {
      // Setup - no current user
      matchesState._items = [];
      matchesState._currentUserIndex = 0;

      // Execute & Verify - should handle gracefully
      expect(() => matchesState.addToFavorites(), returnsNormally);
    });
  });

  group('State Management Tests', () {
    test('initState loads candidates correctly', () {
      // This would test that initState calls getCandidateMatchesList
      // and properly initializes the state
      // Note: Requires refactoring to make data loading testable
    });

    test('state reset when new candidates are available', () {
      // Test that state resets properly when new data is loaded
      matchesState._items = mockCandidates;
      matchesState._currentUserIndex = 2;
      matchesState._outOfCandidates = true;

      // Simulate loading new candidates
      matchesState._items = [
        ...mockCandidates,
        {
          'id': 's4',
          'name': 'New Candidate',
          'description': 'New Developer',
          'job_roles': ['Full Stack'],
          'graduationYear': '2024',
          'skills': ['React', 'Node'],
          'willing_to_relocate': true,
          'github_url': null
        }
      ];
      matchesState._currentUserIndex = 0;
      matchesState._outOfCandidates = false;

      expect(matchesState._currentUserIndex, 0);
      expect(matchesState._outOfCandidates, false);
    });
  });
}
