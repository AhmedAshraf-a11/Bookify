import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

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
          color: AppColors.primary,
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
          selectedItemColor: AppColors.surface,
          unselectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: _NavIcon(
                assetPath: 'assets/icons/home.svg',
                defaultIcon: Icons.home_outlined,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                assetPath: 'assets/icons/library.svg',
                defaultIcon: Icons.library_books_outlined,
              ),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                assetPath: 'assets/icons/add.svg',
                defaultIcon: Icons.add_box_outlined,
              ),
              label: 'Add Book',
            ),
            BottomNavigationBarItem(
              icon: _NavIcon(
                assetPath: 'assets/icons/profile.svg',
                defaultIcon: Icons.person_outline,
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
  const _NavIcon({required this.assetPath, required this.defaultIcon});

  final String assetPath;
  final IconData defaultIcon;

  @override
  Widget build(BuildContext context) {
    final bool isSelected =
        IconTheme.of(context).color == AppColors.surface;
    final Color color = isSelected ? AppColors.surface : Colors.white;

    return SvgPicture.asset(
      assetPath,
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      // Fallback to Icon if SVG fails (useful during refactoring if assets are missing)
      placeholderBuilder: (context) => Icon(defaultIcon, color: color, size: 22),
    );
  }
}
