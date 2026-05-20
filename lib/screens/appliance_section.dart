import 'package:flutter/material.dart';

import '../../data/appliance_templates.dart';
import '../../models/appliance_model.dart';
import '../../models/appliance_template.dart';

import '../../widgets/appliances/appliance_chip.dart';
import '../../widgets/appliances/appliance_inventory_card.dart';

class ApplianceSection extends StatelessWidget {
  const ApplianceSection({
    super.key,
    required this.appliances,
    required this.onAddTemplate,
    required this.onAddManual,
    required this.onDelete,
    required this.onChanged,
  });

  final List<ApplianceModel> appliances;
  final ValueChanged<ApplianceTemplate> onAddTemplate;
  final VoidCallback onAddManual;
  final ValueChanged<String> onDelete;
  final ValueChanged<ApplianceModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Read responsive configuration values based on screen profile
        final bool isCompactScreen = constraints.maxWidth < 360;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and add button layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Appliances',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Button scales down text padding if layout gets highly compressed
                FilledButton.icon(
                  onPressed: onAddManual,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                  style: FilledButton.styleFrom(
                    padding: isCompactScreen
                        ? const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          )
                        : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // List of appliance templates
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: applianceTemplates.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final template = applianceTemplates[index];
                  final selected = appliances.any(
                    (a) => a.name == template.name,
                  );

                  return ApplianceChip(
                    appliance: template,
                    selected: selected,
                    onTap: () {
                      if (!selected) {
                        onAddTemplate(template);
                        return;
                      }

                      final existing = appliances.where(
                        (a) => a.name == template.name,
                      );
                      if (existing.isEmpty) return;
                      onDelete(existing.first.id);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            // Inventory list tracking container
            if (appliances.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No saved appliances yet.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              )
            else
              ...appliances.map(
                (model) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ApplianceInventoryCard(
                    appliance: model,
                    onChanged: onChanged,
                    onDelete: () => onDelete(model.id),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
