
import 'package:uprm_professional_portfolio/models/swipe_process.dart';

List<Map<String,dynamic>> localRepository = [];

class SwipeProcessRepository {

  /// Record user's swipe action on a profile card
  void recordSwipeAction(SwipeProcess swipe){
    localRepository.add({
      'id': swipe.id,
      'initiatorId': swipe.initiatorId,
      'targetId': swipe.targetId,
      'SwipeType': swipe.direction,
      'timestamp': swipe.timestamp,
    });
  }
}