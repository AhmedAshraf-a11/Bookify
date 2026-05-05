import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class MainBottomNavShell extends StatelessWidget {
  const MainBottomNavShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF7C9A92),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
          selectedItemColor: const Color(0xFF1E1E1E),
          unselectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: _NavIcon(
                assetPath: 'assets/icons/home.svg',
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                assetPath: 'assets/icons/library.svg',
              ),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                assetPath: 'assets/icons/add.svg',
              ),
              label: 'Add Book',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                assetPath: 'assets/icons/profile.svg',
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final bool isSelected =
        IconTheme.of(context).color == const Color(0xFF1E1E1E);
    return SvgPicture.asset(
      assetPath,
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(
        isSelected ? const Color(0xFF1E1E1E) : Colors.white,
        BlendMode.srcIn,
      ),
    );
  }
}
