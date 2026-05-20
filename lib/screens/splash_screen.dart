import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:wattwais/services/auth_service.dart";
import "package:wattwais/core/routes/screen_routes.dart";
import "package:wattwais/core/theme/app_theme.dart";



class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen> {

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        debugPrint("No existing user. Signing in anonymously...");
        
        await AuthService().signInAnonymously();
      } else {
        debugPrint("Existing user found: ${currentUser.uid}");
      }
    
      //display logo
      await Future.delayed( const Duration(seconds: 3));

      if (!mounted) {
        debugPrint("logo screen not mounted");
        return;
      } else {
        context.go(Routes.dashboard);
      }
    } catch (e) {
      debugPrint("(logo screen) initialization failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: .42),
                    blurRadius: 46,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: AppColors.ink,
                size: 76,
              ),
            ),
            const SizedBox(height: 54),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 46,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  letterSpacing: -5,
                ),
                children: [
                  TextSpan(text: 'Wattw'),
                  TextSpan(
                    text: 'AI',
                    style: TextStyle(color: AppColors.cyan),
                  ),
                  TextSpan(text: 's'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Start managing your electricity wAIsly.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
