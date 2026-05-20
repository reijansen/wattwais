import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wattwais/core/theme/app_theme.dart';
import 'package:wattwais/services/bill_service.dart';
import 'package:wattwais/widgets/bottom_nav.dart';

class AdjustValuesScreen extends StatefulWidget {
  const AdjustValuesScreen({super.key});

  @override
  State<AdjustValuesScreen> createState() => _AdjustValuesScreenState();
}

class _AdjustValuesScreenState extends State<AdjustValuesScreen> {
  final _budgetController = TextEditingController();
  final _rateController = TextEditingController();

  double _budgetSliderValue = 100.0;
  final double _maxBudgetLimit = 20000.0;

  @override
  void initState() {
    super.initState();
    _loadSavedValues();
  }

  Future<void> _loadSavedValues() async {
    final savedBudget = await BillService.loadBudget();
    final savedRate = await BillService.loadBaseRate();

    if (!mounted) return;
    setState(() {
      final budget = double.tryParse((savedBudget ?? '').toString());
      if (budget != null) {
        _budgetSliderValue = budget.clamp(0.0, _maxBudgetLimit);
      }
      _budgetController.text = _budgetSliderValue.toStringAsFixed(0);

      final rate = double.tryParse((savedRate ?? '').toString());
      _rateController.text = (rate ?? 0.0).toString();
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    setState(() {
      _budgetSliderValue = value.clamp(0.0, _maxBudgetLimit);
      _budgetController.text = _budgetSliderValue.toStringAsFixed(0);
    });
  }

  void _onBudgetTextChanged(String text) {
    if (text.isEmpty) {
      setState(() {
        _budgetSliderValue = 0.0;
      });
      return;
    }

    final parsed = double.tryParse(text);
    if (parsed != null) {
      setState(() {
        _budgetSliderValue = parsed.clamp(0.0, _maxBudgetLimit);
      });
    }
  }

  Future<void> _saveConfigurations() async {
    final finalBudget =
        double.tryParse(_budgetController.text) ?? _budgetSliderValue;
    final finalBaseRate = double.tryParse(_rateController.text) ?? 0.0;

    await BillService.saveBudget(finalBudget);
    await BillService.saveBaseRate(finalBaseRate);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Budget parameters updated successfully!'),
        backgroundColor: AppColors.blue.withValues(alpha: 0.8),
      ),
    );

    if (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Tariff & Budget',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: AppColors.text,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.text,
          ),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double sidePadding = constraints.maxWidth > 600 ? 36.0 : 24.0;

            return SingleChildScrollView(
              padding: EdgeInsets.all(sidePadding),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            color: AppColors.cyan,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Adjust Thresholds',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Fine-tune your financial baseline to help the XGBoost prediction engine accurately forecast your upcoming bill spikes.',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      const SizedBox(height: 30),

                      const Row(
                        children: [
                          Icon(
                            Icons.attach_money_rounded,
                            color: AppColors.cyan,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Monthly Target Budget',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _budgetController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: _onBudgetTextChanged,
                        decoration: InputDecoration(
                          prefixText: '₱ ',
                          prefixStyle: const TextStyle(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: '0',
                          hintStyle: const TextStyle(color: AppColors.muted),
                          filled: true,
                          fillColor: AppColors.blue.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                          ),
                          child: Slider(
                            value: _budgetSliderValue,
                            min: 0,
                            max: _maxBudgetLimit,
                            activeColor: AppColors.cyan,
                            inactiveColor: AppColors.muted.withValues(
                              alpha: 0.15,
                            ),
                            onChanged: _onSliderChanged,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Row(
                        children: [
                          Icon(
                            Icons.electric_bolt_rounded,
                            color: AppColors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Base Electricity Rate',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Check your utility provider statement for your current flat cost per kilowatt-hour.',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _rateController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          prefixText: '₱ ',
                          suffixText: '/ kWh',
                          suffixStyle: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixStyle: const TextStyle(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: '0.00',
                          hintStyle: const TextStyle(color: AppColors.muted),
                          filled: true,
                          fillColor: AppColors.blue.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _saveConfigurations,
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 22,
                          ),
                          label: const Text(
                            'Apply Adjustments',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: AppColors.ink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const WattBottomNav(currentIndex: 3),
    );
  }
}
