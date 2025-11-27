import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

class SwipeProcess {
  final String id;
  final DateTime timestamp;

  // Core Business Data Fields
  final String initiatorId;
  final String targetId;
  final SwipeType direction;

  const SwipeProcess._private({
    required this.id,
    required this.timestamp,
    required this.initiatorId,
    required this.targetId,
    required this.direction,
  });
  factory SwipeProcess.create({
    required String initiatorId,
    required String targetId,
    required SwipeType direction,
  }) {
    // 1. Logic for ID generation
    final newId = uuid.v4();

    // 2. Logic for Timestamp assignment
    final creationTime = DateTime.now().toUtc(); // Always use UTC for time stamps

    // 3. Call the internal constructor with ALL required fields
    return SwipeProcess._private(
      id: newId,
      timestamp: creationTime,
      initiatorId: initiatorId,
      targetId: targetId,
      direction: direction,
    );
  }
}

enum SwipeType {
  like,    // Right Swipe
  dislike, // Left Swipe
  superLike,
}