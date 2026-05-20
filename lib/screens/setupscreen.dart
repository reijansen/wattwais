import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wattwais/core/theme/app_theme.dart';
import 'package:wattwais/models/wattwais_models.dart';
import 'package:wattwais/widgets/app_chrome.dart';
//import 'package:wattwais/screens/dashboard.dart';
//import '../widgets/bottom_nav.dart';
import '../widgets/screenscaffold.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({
    super.key,
    required this.appliances,
    required this.isPredicting,
    required this.onBack,
    required this.onAdd,
    required this.onChange,
    required this.onDelete,
    required this.onPredict,
  });

  final List<Appliance> appliances;
  final bool isPredicting;
  final VoidCallback onBack;
  final ValueChanged<Appliance> onAdd;
  final void Function(int index, Appliance appliance) onChange;
  final ValueChanged<int> onDelete;
  final void Function({required double bill, required double rate}) onPredict;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late final _billController = TextEditingController();
  late final _rateController = TextEditingController();

  @override
  void dispose() {
    _billController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _handlePredict() {
    final bill = double.tryParse(_billController.text.replaceAll(',', '')) ?? 0;
    final rate = double.tryParse(_rateController.text.replaceAll(',', '')) ?? 0;
    widget.onPredict(bill: bill, rate: rate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          ScreenScaffold(
            withBottomPadding: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Adaptable Header Row Profile
                Row(
                  children: [
                    IconButton.filled(
                      onPressed: widget.onBack,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF161D25),
                        fixedSize: const Size(54, 54),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 28),
                    ),
                    const Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Setup',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 54), // Dynamically balanced with back button width profile
                  ],
                ),
                const SizedBox(height: 22),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Tell us about your home', style: context.titleLarge),
                ),
                const SizedBox(height: 12),
                const Text(
                  "We'll predict your next bill with AI.",
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                ),
                const SizedBox(height: 24),
                _SetupInputs(
                  billController: _billController,
                  rateController: _rateController,
                ),
                const SizedBox(height: 22),
                Text('ADD APPLIANCE', style: context.sectionLabel),
                const SizedBox(height: 14),
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: defaultAppliances.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final item = defaultAppliances[index];
                      return ApplianceChip(
                        appliance: item,
                        selected: widget.appliances.any(
                          (entry) => entry.name == item.name,
                        ),
                        onTap: () => widget.onAdd(item),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'INVENTORY · ${widget.appliances.length}',
                  style: context.sectionLabel,
                ),
                const SizedBox(height: 16),
                if (widget.appliances.isEmpty)
                  const EmptyInventoryCard()
                else
                  ...widget.appliances.indexed.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ApplianceInventoryCard(
                        appliance: entry.$2,
                        onChanged: (value) => widget.onChange(entry.$1, value),
                        onDelete: () => widget.onDelete(entry.$1),
                      ),
                    ),
                  ),
                const SizedBox(height: 112), // Prevents fab overlap during long list views
              ],
            ),
          ),
          Positioned(
            left: AppSpacing.page,
            right: AppSpacing.page,
            bottom: 34,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: widget.isPredicting
                  ? const _PredictingBar()
                  : SizedBox(
                      width: double.infinity,
                      child: PrimaryPillButton(
                        label: 'Predict my bill',
                        icon: Icons.auto_fix_high_rounded,
                        onPressed: _handlePredict,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupInputs extends StatelessWidget {
  const _SetupInputs({
    required this.billController,
    required this.rateController,
  });

  final TextEditingController billController;
  final TextEditingController rateController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Falls back to stacking vertical forms on extremely compressed micro viewports
        if (constraints.maxWidth < 280) {
          return Column(
            children: [
              _FormInput(
                label: 'LAST BILL (₱)',
                hint: '2400',
                prefix: '₱ ',
                controller: billController,
              ),
              const SizedBox(height: 14),
              _FormInput(
                label: 'RATE / KWH',
                hint: '8.00',
                prefix: '₱ ',
                controller: rateController,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _FormInput(
                label: 'LAST BILL (₱)',
                hint: '2400',
                prefix: '₱ ',
                controller: billController,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _FormInput(
                label: 'RATE / KWH',
                hint: '8.00',
                prefix: '₱ ',
                controller: rateController,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FormInput extends StatelessWidget {
  const _FormInput({
    required this.label,
    required this.hint,
    required this.controller,
    this.prefix,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
      borderSide: const BorderSide(color: AppColors.mutedBorder, width: 1.3),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, style: context.sectionLabel.copyWith(fontSize: 13)),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.dim,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
            prefixText: prefix,
            prefixStyle: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 18,
            ),
            filled: true,
            fillColor: const Color(0xFF0F151B),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
              borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class ApplianceChip extends StatelessWidget {
  const ApplianceChip({
    super.key,
    required this.appliance,
    required this.selected,
    required this.onTap,
  });

  final Appliance appliance;
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF102338) : const Color(0xFF10171D),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.blue : AppColors.mutedBorder,
              width: 1.4,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(appliance.icon, color: AppColors.cyan, size: 29),
              const SizedBox(height: 12),
              Text(
                appliance.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApplianceInventoryCard extends StatelessWidget {
  const ApplianceInventoryCard({
    super.key,
    required this.appliance,
    required this.onChanged,
    required this.onDelete,
  });

  final Appliance appliance;
  final ValueChanged<Appliance> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return WattCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconBubble(icon: appliance.icon, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        appliance.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${appliance.watts}W · ${appliance.hoursPerDay}h/day · ×${appliance.quantity}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final double cellWidth = constraints.maxWidth;
              // Wraps adjustment buttons down dynamically on ultra-thin layouts
              if (cellWidth < 260) {
                return Column(
                  children: [
                    _QuantityStepper(
                      value: appliance.quantity,
                      onChanged: (value) =>
                          onChanged(appliance.copyWith(quantity: value)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _ValuePill(label: 'Watts', value: '${appliance.watts}')),
                        const SizedBox(width: 10),
                        Expanded(child: _ValuePill(label: 'Hrs/day', value: '${appliance.hoursPerDay}')),
                      ],
                    )
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 13,
                    child: _QuantityStepper(
                      value: appliance.quantity,
                      onChanged: (value) =>
                          onChanged(appliance.copyWith(quantity: value)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 10,
                    child: _ValuePill(label: 'Watts', value: '${appliance.watts}'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 10,
                    child: _ValuePill(
                      label: 'Hrs/day',
                      value: '${appliance.hoursPerDay}',
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

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        border: Border.all(color: AppColors.mutedBorder, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _RoundIconButton(
            icon: Icons.remove_rounded,
            onTap: () => onChanged(math.max(1, value - 1)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Qty',
                style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.0),
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
          _RoundIconButton(
            icon: Icons.add_rounded,
            color: AppColors.cyan,
            foreground: AppColors.ink,
            onTap: () => onChanged(math.min(12, value + 1)),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF151D25),
    this.foreground = AppColors.text,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: foreground, size: 20),
      ),
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        border: Border.all(color: AppColors.mutedBorder, width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyInventoryCard extends StatelessWidget {
  const EmptyInventoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const WattCard(
      child: Row(
        children: [
          IconBubble(icon: Icons.add_home_work_outlined),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Choose appliances above to build an accurate home profile.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 16,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictingBar extends StatelessWidget {
  const _PredictingBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('predicting'),
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.ink,
            ),
          ),
          SizedBox(width: 14),
          SkeletonLine(width: 138, height: 20, radius: 10),
        ],
      ),
    );
  }
}
