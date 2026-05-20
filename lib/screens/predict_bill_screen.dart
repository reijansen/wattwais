import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wattwais/core/routes/screen_routes.dart';

import '../models/appliance_model.dart';
import '../models/bill_entry.dart';
import '../models/appliance_template.dart';
import '../models/appliance_input.dart';
import '../models/prediction_result.dart';

import '../services/appliance_service.dart';
import '../services/bill_service.dart';
import '../services/prediction_api_service.dart';
import '../services/prediction_store_service.dart';

import '../widgets/bill_card.dart';
import '../widgets/bottom_nav.dart';
import '../utils/bill_utils.dart';
import '../data/appliance_templates.dart';

import 'appliance_section.dart';

class PredictBillScreen extends StatefulWidget {
  const PredictBillScreen({super.key});

  @override
  State<PredictBillScreen> createState() => _PredictBillScreenState();
}

class _PredictBillScreenState extends State<PredictBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _applianceFormKey = GlobalKey<FormState>();

  final _budgetController = TextEditingController();
  final _baseRateController = TextEditingController();

  Timer? _budgetSaveDebounce;
  Timer? _baseRateSaveDebounce;
  bool _budgetDirty = false;
  bool _baseRateDirty = false;
  bool _suspendSettingsListeners = false;

  final _newApplianceNameController = TextEditingController();
  final _newApplianceWattsController = TextEditingController();
  final _newApplianceQuantityController = TextEditingController(text: '1');
  final _newApplianceHoursController = TextEditingController(text: '1');
  final _newApplianceDaysController = TextEditingController(text: '7');

  List<ApplianceModel> _appliances = [];
  List<BillEntry> _bills = [];

  String _predictionTarget = 'current_month';

  bool _isPredicting = false;
  bool _showBackendWarning = false;

  @override
  void initState() {
    super.initState();
    _budgetController.addListener(_onBudgetChanged);
    _baseRateController.addListener(_onBaseRateChanged);
    _initialize();
  }

  void _onBudgetChanged() {
    if (_suspendSettingsListeners) return;
    _budgetDirty = true;

    _budgetSaveDebounce?.cancel();
    final parsed = double.tryParse(
      _budgetController.text.replaceAll(',', '').trim(),
    );
    if (parsed == null) return;

    _budgetSaveDebounce = Timer(
      const Duration(milliseconds: 600),
      () => BillService.saveBudget(parsed),
    );
  }

  void _onBaseRateChanged() {
    if (_suspendSettingsListeners) return;
    _baseRateDirty = true;

    _baseRateSaveDebounce?.cancel();
    final parsed = double.tryParse(
      _baseRateController.text.replaceAll(',', '').trim(),
    );
    if (parsed == null) return;

    _baseRateSaveDebounce = Timer(
      const Duration(milliseconds: 600),
      () => BillService.saveBaseRate(parsed),
    );
  }

  Future<void> _initialize() async {
    for (final bill in _bills) {
      bill.dispose();
    }

    _bills = BillService.generateRequiredMonths(_predictionTarget);

    await _loadAppliances();
    await BillService.loadBills(_bills);

    final budget = await BillService.loadBudget();
    if (budget != null) {
      if (!_budgetDirty) {
        _suspendSettingsListeners = true;
        _budgetController.text = budget;
        _suspendSettingsListeners = false;
      }
    }

    final baseRate = await BillService.loadBaseRate();
    if (baseRate != null) {
      if (!_baseRateDirty) {
        _suspendSettingsListeners = true;
        _baseRateController.text = baseRate;
        _suspendSettingsListeners = false;
      }
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _showAddApplianceDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        ApplianceTemplate? selectedTemplate;
        return AlertDialog(
          title: const Text('Add Appliance'),
          content: Form(
            key: _applianceFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatefulBuilder(
                    builder: (context, setLocalState) {
                      return DropdownButtonFormField<ApplianceTemplate?>(
                        initialValue: selectedTemplate,
                        decoration: const InputDecoration(
                          labelText: 'Choose from list',
                        ),
                        items: [
                          const DropdownMenuItem<ApplianceTemplate?>(
                            value: null,
                            child: Text('Custom'),
                          ),
                          ...applianceTemplates.map(
                            (template) => DropdownMenuItem<ApplianceTemplate?>(
                              value: template,
                              child: Text(template.name),
                            ),
                          ),
                        ],
                        onChanged: (template) {
                          setLocalState(() {
                            selectedTemplate = template;
                          });
                          if (template == null) return;
                          _newApplianceNameController.text = template.name;
                          _newApplianceWattsController.text = template
                              .defaultWatts
                              .toString();
                          _newApplianceQuantityController.text = template
                              .defaultQuantity
                              .toString();
                          _newApplianceHoursController.text = template
                              .defaultHoursPerDay
                              .toString();
                          _newApplianceDaysController.text = template
                              .defaultDaysPerWeek
                              .toString();
                        },
                      );
                    },
                  ),
                  TextFormField(
                    controller: _newApplianceNameController,
                    decoration: const InputDecoration(
                      labelText: 'Appliance Name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter appliance name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newApplianceWattsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Watts'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _newApplianceQuantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Qty'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _newApplianceHoursController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Hrs/day',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _newApplianceDaysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Days/week'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await _addManualAppliance();
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadAppliances() async {
    final appliances = await ApplianceService.loadAppliances();
    if (!mounted) return;
    setState(() {
      _appliances = appliances;
    });
  }

  Future<void> _addApplianceFromDefault(ApplianceTemplate template) async {
    final alreadyExists = _appliances.any(
      (a) => a.name.toLowerCase() == template.name.toLowerCase(),
    );

    if (alreadyExists) return;

    final newAppliance = ApplianceModel(
      id: '',
      name: template.name,
      icon: template.icon,
      watts: template.defaultWatts,
      quantity: template.defaultQuantity,
      hoursPerDay: template.defaultHoursPerDay,
      daysPerWeek: template.defaultDaysPerWeek,
    );

    final id = await ApplianceService.saveAppliance(newAppliance);
    if (!mounted) return;
    setState(() {
      _appliances = [newAppliance.copyWith(id: id ?? ''), ..._appliances];
    });
  }

  Future<void> _addManualAppliance() async {
    if (!_applianceFormKey.currentState!.validate()) return;

    final newAppliance = ApplianceModel(
      id: '',
      name: _newApplianceNameController.text.trim(),
      icon: Icons.devices,
      watts: int.tryParse(_newApplianceWattsController.text) ?? 0,
      quantity: int.tryParse(_newApplianceQuantityController.text) ?? 1,
      hoursPerDay: int.tryParse(_newApplianceHoursController.text) ?? 1,
      daysPerWeek: int.tryParse(_newApplianceDaysController.text) ?? 7,
    );

    final id = await ApplianceService.saveAppliance(newAppliance);
    if (!mounted) return;
    setState(() {
      _appliances = [newAppliance.copyWith(id: id ?? ''), ..._appliances];
    });
    _clearManualApplianceForm();
  }

  void _clearManualApplianceForm() {
    _newApplianceNameController.clear();
    _newApplianceWattsController.clear();
    _newApplianceQuantityController.text = '1';
    _newApplianceHoursController.text = '1';
    _newApplianceDaysController.text = '7';
  }

  Future<void> _updateAppliance(ApplianceModel appliance) async {
    setState(() {
      _appliances = [
        for (final item in _appliances)
          if (item.id == appliance.id) appliance else item,
      ];
    });
    await ApplianceService.saveAppliance(appliance);
  }

  Future<void> _deleteAppliance(String id) async {
    setState(() {
      _appliances = _appliances.where((item) => item.id != id).toList();
    });
    await ApplianceService.deleteAppliance(id);
  }

  Future<void> _predictBill() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        _isPredicting = true;
      });

      final monthlyBudget = double.tryParse(_budgetController.text.trim());
      if (monthlyBudget == null || monthlyBudget < 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid budget amount.')),
        );
        return;
      }

      final baseRate = double.tryParse(_baseRateController.text.trim());
      if (baseRate == null || baseRate < 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid base rate.')),
        );
        return;
      }

      for (final bill in _bills) {
        final billAmount = double.tryParse(bill.billController.text.trim());
        if (billAmount == null || billAmount < 0) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please enter a valid bill amount for ${formatMonth(bill.monthId)}.',
              ),
            ),
          );
          return;
        }

        final kwhText = bill.kwhController.text.trim();
        final kwh = double.tryParse(kwhText);
        if (kwhText.isEmpty || kwh == null || kwh < 0) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please enter kWh used for ${formatMonth(bill.monthId)}.',
              ),
            ),
          );
          return;
        }
      }

      final bills = await BillService.saveBills(_bills);
      final appliances = _appliances;

      await BillService.saveBudget(monthlyBudget);
      await BillService.saveBaseRate(baseRate);

      final missingKwh = bills.any((b) => b.kwhUsed == null);
      if (missingKwh) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter kWh used for all 6 months to run prediction.',
            ),
          ),
        );
        return;
      }

      final sixMonthTotalBill = bills.fold<double>(
        0.0,
        (sum, b) => sum + b.billAmount,
      );
      final sixMonthTotalKwh = bills.fold<double>(
        0.0,
        (sum, b) => sum + (b.kwhUsed ?? 0.0),
      );

      PredictionResult? result;
      String? predictionErrorMessage;
      try {
        final api = PredictionApiService();
        result = await api.predictBill(
          appliances: appliances.map(ApplianceInput.fromModel).toList(),
          baseRate: baseRate,
          sixMonthTotalBill: sixMonthTotalBill,
          sixMonthTotalKwh: sixMonthTotalKwh,
          monthlyBudget: monthlyBudget,
        );
        _showBackendWarning = false;
      } on TimeoutException {
        _showBackendWarning = true;
        predictionErrorMessage =
            'Prediction request timed out. Backend may be waking up, please try again in a few seconds.';
      } catch (e) {
        debugPrint('Prediction API error: $e');
        _showBackendWarning = true;
        predictionErrorMessage = 'Prediction failed. Please try again.';
      }

      await PredictionStoreService.savePrediction(
        predictionTarget: _predictionTarget,
        appliances: appliances,
        budget: monthlyBudget,
        baseRate: baseRate,
        bills: bills,
        predictionResult: result,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result == null
                ? predictionErrorMessage ?? 'Inputs saved. Prediction failed.'
                : 'Prediction computed and saved',
          ),
        ),
      );

      if (result != null && mounted) {
        context.go(Routes.tipsscreen);
      }
    } catch (e) {
      debugPrint('$e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Prediction failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isPredicting = false;
        });
      }
    }
  }

  Future<void> _onPredictionTargetChanged(String? value) async {
    if (value == null || value == _predictionTarget) return;
    _predictionTarget = value;
    await _initialize();
  }

  @override
  void dispose() {
    _budgetSaveDebounce?.cancel();
    _baseRateSaveDebounce?.cancel();
    _budgetController.dispose();
    _baseRateController.dispose();
    _newApplianceNameController.dispose();
    _newApplianceWattsController.dispose();
    _newApplianceQuantityController.dispose();
    _newApplianceHoursController.dispose();
    _newApplianceDaysController.dispose();

    for (final bill in _bills) {
      bill.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Predict Bill')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_showBackendWarning) ...[
                Card(
                  color: Colors.amber.shade100,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Backend unreachable. Check your internet connection and API base URL.',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Prediction Target',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              RadioGroup<String>(
                groupValue: _predictionTarget,
                onChanged: _onPredictionTargetChanged,
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'current_month',
                      title: const Text('Current Month'),
                    ),
                    RadioListTile<String>(
                      value: 'next_month',
                      title: const Text('Next Month'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              for (final bill in _bills) ...[
                BillCard(key: ValueKey(bill.monthId), entry: bill),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 24),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget Amount',
                  prefixText: '₱ ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _baseRateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Base Rate (₱/kWh)',
                  hintText: '12.5',
                  prefixText: '₱ ',
                  suffixText: '/kWh',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ApplianceSection(
                appliances: _appliances,
                onAddTemplate: _addApplianceFromDefault,
                onAddManual: _showAddApplianceDialog,
                onDelete: _deleteAppliance,
                onChanged: _updateAppliance,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isPredicting ? null : _predictBill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1792E8),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFF1792E8,
                    ).withValues(alpha: 0.45),
                    disabledForegroundColor: Colors.white.withValues(
                      alpha: 0.8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: _isPredicting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Predict Bill'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const WattBottomNav(currentIndex: 0),
    );
  }
}
