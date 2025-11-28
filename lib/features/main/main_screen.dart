import 'package:flutter/material.dart';
import 'package:uprm_professional_portfolio/features/matches.dart';
import '../dashboard/dashboard_screen.dart';
import '../settings/settings_screen.dart';
import '../chat/conversations_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Ensure the initial index is within the available screens range
    _selectedIndex = (widget.initialIndex >= 0 &&
            widget.initialIndex < _screens.length)
        ? widget.initialIndex
        : 0;
  }

  final List<Widget> _screens = const [
    MatchesScreen(),
    DashboardScreen(),
    SettingsScreen(),
    ConversationsPage(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          width: 428,
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: ShapeDecoration(
            color: const Color(0xFF2B7D61),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(36),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                index: 10, // placeholder - to be implemented later
                icon: Icons.star_outline_rounded,
              ),
              _navItem(
                index: 0, // placeholder - to be implemented later
                icon: Icons.search_outlined,
              ),
              _navItem(
                index: 1,
                icon: Icons.home_outlined,
              ),
              _navItem(
                index: 3, // placeholder - to be implemented later
                icon: Icons.chat_bubble_outline,
              ),
              _navItem(
                index: 2,
                icon: Icons.person_outlined,
              ),
            ],
          ),
        ),
      );

  // --- NavBar Helper ---
  Widget _navItem({required int index, required IconData icon}) {
    final isActive = index >= 0 && index < _screens.length && _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        // Only navigate to implemented screens (within _screens range).
        if (index >= 0 && index < _screens.length) {
          setState(() => _selectedIndex = index);
        } else {
          // Inform user this tab isn't implemented yet instead of causing an assertion.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This tab is not implemented yet')),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF57FFC6) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive ? const Color(0xFF2B7D61) : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
