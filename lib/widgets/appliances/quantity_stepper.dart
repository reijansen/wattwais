import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wattwais/core/theme/app_theme.dart';

import 'round_icon_button.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(
          AppSpacing.pillRadius,
        ),
        border: Border.all(
          color: AppColors.mutedBorder,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          RoundIconButton(
            icon: Icons.remove_rounded,
            onTap: () => onChanged(
              math.max(1, value - 1),
            ),
          ),
          // Set to min axis alignment to explicitly clear any vertical bounds limits
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Qty',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
          RoundIconButton(
            icon: Icons.add_rounded,
            color: AppColors.cyan,
            foreground: AppColors.ink,
            onTap: () => onChanged(
              math.min(12, value + 1),
            ),
          ),
        ],
      ),
    );
  }
}