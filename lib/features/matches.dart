import 'package:flutter/material.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => MatchesState();
}

class MatchesState extends State<MatchesScreen> {
  // Mock user data
  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Sarah Johnson',
      'age': 24,
      'major': 'Computer Science',
      'bio':
          'Passionate software developer looking for exciting opportunities in tech. Love hiking and photography!',
      'image': 'assets/profile1.jpg',
    },
    {
      'name': 'Alex Rodriguez',
      'age': 22,
      'major': 'Electrical Engineering',
      'bio':
          'Final year EE student specializing in embedded systems. Avid rock climber and coffee enthusiast.',
      'image': 'assets/profile2.jpg',
    },
    {
      'name': 'Maya Patel',
      'age': 23,
      'major': 'Business Analytics',
      'bio':
          'Data-driven problem solver seeking analyst roles. Enjoy reading and traveling to new places.',
      'image': 'assets/profile3.jpg',
    },
  ];

  int _currentUserIndex = 0;
  bool _outOfCandidates = false;

  void _nextUser() {
    setState(() {
      if (_currentUserIndex < _users.length - 1) {
        _currentUserIndex++;
      } else {
        _outOfCandidates = true; // Show out of candidates message
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        //Header
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Image.asset('brand_white.png'),
        ),
        body: Align(
          child: SafeArea(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  // User Profile Card or Out of Candidates Message
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _outOfCandidates
                          ? _buildOutOfCandidatesMessage()
                          : _buildProfileCard(_users[_currentUserIndex]),
                    ),
                  ),

                  // Action Buttons - Hide when out of candidates
                  if (!_outOfCandidates)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Dislike Button
                          IconButton(
                            onPressed: _nextUser,
                            icon: Image.asset('matches_skip_button.png',
                                width: 50),
                          ),

                          // Info Button
                          IconButton(
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (context) {
                                  final user = _users[_currentUserIndex];
                                  return AlertDialog(
                                    title: Text('${user['name']}\'s Profile'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Major: ${user['major']}'),
                                          const SizedBox(height: 8),
                                          Text('Age: ${user['age']}'),
                                          const SizedBox(height: 8),
                                          Text('Bio: ${user['bio']}'),
                                          const SizedBox(height: 16),
                                          const Text(
                                              'Skills: Flutter, Dart, UI/UX Design'),
                                          const SizedBox(height: 8),
                                          const Text(
                                              'Interests: Hiking, Photography, Tech'),
                                          const SizedBox(height: 8),
                                          const Text(
                                              'Portfolio: github.com/username'),
                                          const SizedBox(height: 8),
                                          const Text(
                                              'Resume: Available upon request'),
                                          const SizedBox(height: 8),
                                          const Text(
                                              'Job Preferences: Full-time, Remote-friendly'),
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
                              'matches_info_button.png',
                              width: 50,
                            ),
                          ),

                          // Like Button
                          IconButton(
                            onPressed: _nextUser,
                            icon: Image.asset('matches_accept_button.png',
                                width: 50),
                          ),

                          // Super Like Button
                          IconButton(
                            onPressed: _nextUser,
                            icon: Image.asset('matches_star_button.png',
                                width: 50),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        /// bottom navigation bar place-holder png
        bottomNavigationBar: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Image.asset('NavBar.png'),
        ),
      );

  Widget _buildProfileCard(Map<String, dynamic> user) {
    return Card(
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
                  '${user['name']}, ${user['age']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user['major'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 80,
                  child: Text(
                    user['bio'],
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
  }

  Widget _buildOutOfCandidatesMessage() {
    return Card(
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
}
