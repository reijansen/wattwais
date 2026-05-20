import 'package:flutter/material.dart';
import 'package:wattwais/core/theme/app_theme.dart';
import '../../models/appliance_model.dart';
import 'package:wattwais/widgets/app_chrome.dart';

import 'package:wattwais/widgets/appliances/quantity_stepper.dart';
import 'package:wattwais/widgets/appliances/value_pill.dart';

class ApplianceInventoryCard extends StatelessWidget {
  const ApplianceInventoryCard({
    super.key,
    required this.appliance,
    required this.onChanged,
    required this.onDelete,
  });

  final ApplianceModel appliance;
  final ValueChanged<ApplianceModel> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return WattCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: Icon, Name, and Delete button
          Row(
            children: [
              IconBubble(icon: appliance.icon, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appliance.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${appliance.watts}W · '
                      '${appliance.hoursPerDay}h/day · '
                      '×${appliance.quantity}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove ${appliance.name}',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bottom section: Adaptable input elements
          LayoutBuilder(
            builder: (context, constraints) {
              const double spacing = 12.0;
              final double maxWidth = constraints.maxWidth;

              // Threshold to switch layout: if 4 items + spacing don't fit well, switch to 2x2 grid
              // Adjust 360 based on your design's minimum comfortable width per item
              final bool useGrid = maxWidth < 360;

              // Dynamic width calculation
              final double itemWidth = useGrid
                  ? (maxWidth - spacing) /
                        2 // 2 items per row
                  : (maxWidth - (spacing * 3)) / 4; // 4 items per row

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.start,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: QuantityStepper(
                      value: appliance.quantity,
                      onChanged: (value) {
                        onChanged(appliance.copyWith(quantity: value));
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: EditableValuePill(
                      label: 'Watts',
                      value: appliance.watts,
                      min: 1,
                      max: 20000,
                      onChanged: (value) {
                        onChanged(appliance.copyWith(watts: value));
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: EditableValuePill(
                      label: 'Hrs/day',
                      value: appliance.hoursPerDay,
                      min: 0,
                      max: 24,
                      onChanged: (value) {
                        onChanged(appliance.copyWith(hoursPerDay: value));
                      },
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: EditableValuePill(
                      label: 'days/wk',
                      value: appliance.daysPerWeek,
                      min: 1,
                      max: 7,
                      onChanged: (value) {
                        onChanged(appliance.copyWith(daysPerWeek: value));
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
