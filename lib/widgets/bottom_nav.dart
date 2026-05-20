import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wattwais/core/routes/screen_routes.dart';
import 'package:wattwais/core/theme/app_theme.dart';

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF0C4C76)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: selected ? AppColors.cyan : AppColors.muted,
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.cyan : AppColors.muted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WattBottomNav extends StatelessWidget {
  const WattBottomNav({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  static const _items = [
    (Icons.home_outlined, 'Home', Routes.dashboard),
    (Icons.bar_chart_rounded, 'Stats', Routes.statscreen),
    (Icons.lightbulb_outline_rounded, 'Tips', Routes.tipsscreen),
    (Icons.tune_rounded, 'Adjust', Routes.adjustscreen),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        border: Border(
          top: BorderSide(
            color: AppColors.mutedBorder,
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        math.max(18, MediaQuery.paddingOf(context).bottom + 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final item in _items.indexed)
            _NavItem(
              icon: item.$2.$1,
              label: item.$2.$2,
              selected: item.$1 == currentIndex,
              onTap: () {
                context.go(item.$2.$3);
              },
            ),
        ],
      ),
    );
  }
}