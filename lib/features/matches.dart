import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

//logic to show recruiter vs job seeker screen goes here a state for each
  @override
  State<MatchesScreen> createState() => MatchesState();
}

class MatchesState extends State<MatchesScreen> {
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
              // Background
              decoration: const BoxDecoration(color: Colors.grey),
              child: const Text("Matches Screen"),
            ),
          ),
        ),

        /// bottom navigation bar place-holder png, ALL work should be done above this,
        /// DON'T replace bottomNavigationBar with matchesScreen buttons
        bottomNavigationBar: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Image.asset('NavBar.png'),
        ),
      );
}
