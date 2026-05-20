import 'package:flutter/material.dart';
import 'package:wattwais/core/theme/app_theme.dart';
import '../../models/appliance_template.dart';

class ApplianceChip extends StatelessWidget {
  const ApplianceChip({
    super.key,
    required this.appliance,
    required this.selected,
    required this.onTap,
  });

  final ApplianceTemplate appliance;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Add ${appliance.name}',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 102,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: selected 
                ? const Color(0xFF102338) 
                : const Color(0xFF10171D),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.blue : AppColors.mutedBorder,
              width: 1.4,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                appliance.icon,
                color: AppColors.cyan,
                size: 29,
              ),
              const SizedBox(height: 12),
              // Protects layout from overflow on extra narrow item states
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  appliance.name,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}