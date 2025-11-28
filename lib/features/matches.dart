import 'package:flutter/material.dart';
import 'package:uprm_professional_portfolio/services/swipe_process_repository.dart';

import '../mock/cosine_metrics.dart';
import '../mock/matches_local_repository.dart';
import '../models/swipe_process.dart';

// TODO Adjust Profile card size,grab current user info, use matching algorithm

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

//logic to show recruiter vs job seeker screen goes here a state for each
  @override
  State<MatchesScreen> createState() => MatchesState();
}

class MatchesState extends State<MatchesScreen> {
  // final LocalRepository dataManager = LocalRepository();
  /// create and initialize list of job seekers
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    // Call the class method to get the list and store it in the state variable
    // _items = dataManager.getSeekers();
    _items = getCandidateMatchesList('r3');
  }



  int _currentUserIndex = 0;
  bool _outOfCandidates = false;
  bool _Pressed = false;

  void userLiked() {
    // cannot get current user id without connection to db
    var targetId = _items[_currentUserIndex]['id'].toString();
    // r0 recruiter id for testing
    final newSwipe = SwipeProcess.create(
      initiatorId: 'r0',
      targetId: targetId,
      direction: SwipeType.like,
    );
    // store swipe locally
    SwipeProcessRepository().insertSwipe(newSwipe);
    _nextUser();
  }

  void userDisliked() {
    var targetId = _items[_currentUserIndex]['id'].toString();
    final newSwipe = SwipeProcess.create(
      initiatorId: 'r0',
      targetId: targetId,
      direction: SwipeType.dislike,
    );
    // store swipe temporarily
    SwipeProcessRepository().insertSwipe(newSwipe);
    _nextUser();
  }

  void _nextUser() {
    _Pressed = false;
    setState(() {
      if (_currentUserIndex < _items.length - 1) {
        _currentUserIndex++;
      } else {
        _outOfCandidates = true; // Show out of candidates message
      }
    });
  }

  void addToFavorites(){
    LocalRepository().insertFavorite(_items[_currentUserIndex]);
  }
  void removeFromFavorites(){
    LocalRepository().removeFavorite();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    //Header
    appBar: AppBar(
      centerTitle: true,
      backgroundColor: const Color(0xFF2B7D61),
      title: Image.asset(
        'assets/logo/professional_portfolio_logo.png',
        height: 40,
        fit: BoxFit.contain,
      ),
    ),
    body: Align(
      child: SafeArea(bottom: true,left: false,right: false,
        child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // User Profile Card or Out of Candidates Message
                SizedBox(
                  height: MediaQuery.sizeOf(context).height-MediaQuery.sizeOf(context).height/3,
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _outOfCandidates
                          ? _buildOutOfCandidatesMessage()
                          : _buildProfileCard(_items[_currentUserIndex]),
                    ),
                  ),
                ),

                // Action Buttons - Hide when out of candidates
            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: userLiked,
                    icon: Image.asset('assets/matches_accept_button.png',
                        width: 50),
                  ),
                  IconButton(
                    onPressed: userDisliked,
                    icon:
                    Image.asset('assets/matches_skip_button.png', width: 50),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) {
                          final user = _items[_currentUserIndex];
                          return AlertDialog(
                            title: Text('${user['name']}\'s Profile'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Major: ${user['job_roles'].join()}'),
                                  const SizedBox(height: 8),
                                  Text('Graduation year: ${user['graduationYear']}'),
                                  const SizedBox(height: 8),
                                  Text('Bio: ${user['description']}'),
                                  const SizedBox(height: 8),
                                  Text('Skills: ${user['skills'].join(', ')}'),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Willing to relocate: ${user['willing_to_relocate']}'),
                                  const SizedBox(height: 8),
                                  if ('${user['github_url']}' == 'null')
                                    const Text(
                                        'Portfolio: no link provided'),
                                  if ('${user['github_url']}' != 'null')
                                    Text('${user['github_url']}'),
                                  const SizedBox(height: 8),
                                  const Text(
                                      'Resume: Available upon request'),
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
                    icon: Image.asset(
                      'assets/matches_info_button.png',
                      width: 50,
                    ),
                  ),
                  IconButton(
                        onPressed: () {
                          addToFavorites();
                          setState(() {
                            _Pressed = !_Pressed;
                          });
                        },
                        icon: _Pressed? Image.asset('assets/matches_star_button_filled.png', width: 50): Image.asset('assets/matches_star_button.png', width: 50),
                      ),
                    ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    ),

    /// bottom navigation bar place-holder png, ALL work should be done above this,
    /// DON'T replace bottomNavigationBar with matchesScreen buttons
    // bottomNavigationBar: PreferredSize(
    //   preferredSize: const Size.fromHeight(20),
    //   child: Image.asset('NavBar.png'),
    // ),
  );

  Widget _buildProfileCard(Map<String, dynamic> user) => Card(
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Stack(
      children: [
        // Profile Image (placeholder with gradient)
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, Colors.purple],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.person,
              size: 150,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),

        // User Info
        Positioned(
          left: 20,
          bottom: 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user['name']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                // user['major']
                "Computer Science",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width - 80,
                child: Text(
                  '${user['description']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildOutOfCandidatesMessage() => Card(
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'Out of Candidates',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "You've viewed all available profiles.\nCheck back later for more candidates!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
