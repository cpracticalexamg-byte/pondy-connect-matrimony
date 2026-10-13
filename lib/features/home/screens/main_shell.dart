import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../../interests/screens/interests_screen.dart';
import '../../matches/screens/matches_screen.dart';
import '../../membership/screens/upgrade_screen.dart';
import '../providers/home_provider.dart';
import 'home_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  final int initialTab;

  const MainShell({super.key, this.initialTab = 0});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeDashboardProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onSwitchTab: _onTabSelected),
          const MatchesScreen(),
          const InterestsScreen(),
          const ChatListScreen(),
          const UpgradeScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabSelected,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: _currentIndex == 4 ? AppColors.successGreen : AppColors.saffronOrange,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                activeIcon: Icon(Icons.favorite),
                label: 'Matches',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined),
                    if (homeData.interestsReceivedCount > 0)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.saffronOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: const Icon(Icons.thumb_up_alt),
                label: 'Interests',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.chat_bubble_outline),
                    if (homeData.unreadNotificationsCount > 0)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: const Icon(Icons.chat_bubble),
                label: 'Messages',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.workspace_premium_outlined),
                activeIcon: Icon(
                  Icons.workspace_premium,
                  color: AppColors.successGreen,
                ),
                label: 'Upgrade',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
