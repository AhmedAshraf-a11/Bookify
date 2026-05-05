// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/router/app_router.dart';
// import '../../../../core/theme/app_colors.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _navigateToLogin();
//   }

//   void _navigateToLogin() async {
//     await Future.delayed(const Duration(seconds: 2));
//     if (mounted) {
//       context.go(AppRoutePaths.login);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       body: Center(
//         child: Container(
//           width: 100,
//           height: 100,
//           decoration: const BoxDecoration(
//             color: Color(0xFFE8E6E3),
//             shape: BoxShape.circle,
//           ),
//           child: Image.asset("assets/images/logo.png"),
//         ),
//       ),
//     );
//   }
// }
//////////////////////////////////////////////////////
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/app_auth_session.dart';
import '../../../../core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    // Simulate loading time while checking auth status
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Check if user is authenticated
      final token = appAuthSession.accessToken;
      if (token != null && token.isNotEmpty) {
        // User is authenticated, navigate to home
        context.go(AppRoutePaths.home);
      } else {
        // User is not authenticated, navigate to login
        context.go(AppRoutePaths.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF4A8C7D,
      ), // Same teal color as native splash
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Replace with your real book illustration from Figma
            const Icon(
              Icons.menu_book_rounded, // Temporary Flutter icon
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'Bookify',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Read. Track. Grow.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 60),
            // Loading indicator
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 8,
                  height: 8,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 8,
                  height: 8,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 8,
                  height: 8,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Loading...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
