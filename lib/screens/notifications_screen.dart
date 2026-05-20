import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wattwais/core/theme/app_theme.dart';
import 'package:wattwais/widgets/app_chrome.dart';
import 'package:wattwais/widgets/screenscaffold.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: ScreenScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton.filled(
                  onPressed: () => context.pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF161D25),
                    fixedSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const WattCard(
              color: AppColors.navyPanel,
              borderColor: AppColors.border,
              padding: EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBubble(icon: Icons.notifications_none_rounded),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'You will see updates about predictions, tips, and reminders here.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
