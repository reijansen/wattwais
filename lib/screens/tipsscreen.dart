import 'package:flutter/material.dart';
import 'package:wattwais/core/theme/app_theme.dart';
import 'package:wattwais/services/prediction_store_service.dart';
import 'package:wattwais/widgets/app_chrome.dart';
import 'package:wattwais/widgets/bottom_nav.dart';
import '../widgets/screenscaffold.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key, this.latestPrediction, this.aiInsights});

  final Map<String, dynamic>? latestPrediction;
  final Map<String, dynamic>? aiInsights;

  @override
  Widget build(BuildContext context) {
    if (latestPrediction != null) {
      return _buildScaffold(context, latestPrediction);
    }

    return StreamBuilder<Map<String, dynamic>?>(
      stream: PredictionStoreService.streamLatestPrediction(),
      builder: (context, snapshot) {
        return _buildScaffold(context, snapshot.data);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, Map<String, dynamic>? record) {
    final prediction = record?['prediction_result'] as Map<String, dynamic>?;
    final estimatedBill = (prediction?['estimated_bill'] as num?)?.toDouble();
    final estimatedKwh = (prediction?['estimated_monthly_kwh'] as num?)
        ?.toDouble();
    final exceedsBudget = prediction?['exceeds_budget'] as bool?;

    final appliances = (record?['appliances'] as List?)?.cast<dynamic>() ?? [];
    final applianceTips = _buildApplianceTips(
      appliances: appliances,
      exceedsBudget: exceedsBudget == true,
    );
    final aiTips = _buildAiTips(aiInsights?['tips_list'] as List?);
    final tipsToRender = aiTips.isNotEmpty ? aiTips : applianceTips;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: ScreenScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Tips', style: context.titleLarge),
            ),
            const SizedBox(height: 8),
            const Text(
              'Smarter savings this week',
              style: TextStyle(color: AppColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 22),
            WattCard(
              color: AppColors.navyPanel,
              borderColor: AppColors.border,
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconBubble(icon: Icons.auto_graph_rounded),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Latest Prediction',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          prediction == null
                              ? 'Run Predict Bill to see your latest estimate and recommendation.'
                              : 'Estimated bill: PHP ${estimatedBill?.toStringAsFixed(2) ?? '0.00'}\nEstimated usage: ${estimatedKwh?.toStringAsFixed(2) ?? '0.00'} kWh\nStatus: ${exceedsBudget == true ? 'Exceeds budget' : 'Within budget'}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 15,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (tipsToRender.isEmpty)
              const WattCard(
                padding: EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBubble(icon: Icons.lightbulb_outline_rounded),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Add appliances for tips',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Go to Predict Bill and add your appliances to get personalized savings tips here.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 15,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              for (final tip in tipsToRender) ...[
                _TipCard(icon: tip.icon, title: tip.title, body: tip.body),
                const SizedBox(height: 14),
              ],
          ],
        ),
      ),
      bottomNavigationBar: const WattBottomNav(currentIndex: 2),
    );
  }
}

List<_TipDefinition> _buildAiTips(List? tips) {
  if (tips == null || tips.isEmpty) return const [];
  final parsed = <_TipDefinition>[];

  for (final entry in tips) {
    final map = entry is Map ? entry : null;
    if (map == null) continue;
    final title = _extractApplianceTitle(
      (map['title'] ?? '').toString().trim(),
    );
    final recommendation = (map['recommendation'] ?? '').toString().trim();
    final impact = (map['estimated_impact'] ?? '').toString().trim();
    if (title.isEmpty || recommendation.isEmpty) continue;

    final body = impact.isEmpty ? recommendation : '$recommendation\nImpact: $impact';
    parsed.add(
      _TipDefinition(
        icon: Icons.auto_awesome_rounded,
        title: title,
        body: body,
      ),
    );
  }

  return parsed;
}

String _extractApplianceTitle(String rawTitle) {
  if (rawTitle.isEmpty) return rawTitle;
  final colonIndex = rawTitle.indexOf(':');
  final base = colonIndex >= 0 ? rawTitle.substring(0, colonIndex) : rawTitle;
  final parenIndex = base.indexOf('(');
  final cleaned = parenIndex >= 0 ? base.substring(0, parenIndex) : base;
  return cleaned.trim();
}

class _TipDefinition {
  const _TipDefinition({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return WattCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBubble(icon: icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<_TipDefinition> _buildApplianceTips({
  required List<dynamic> appliances,
  required bool exceedsBudget,
}) {
  final tips = <_TipDefinition>[];

  for (final appliance in appliances) {
    final map = appliance is Map ? appliance : null;
    final rawName = (map?['name'] ?? '').toString().trim();
    final name = rawName.isEmpty ? 'Appliance' : rawName;
    final lower = name.toLowerCase();

    final watts = (map?['watts'] as num?)?.toInt();
    final hours = (map?['hours_per_day'] as num?)?.toInt();
    final qty = (map?['quantity'] as num?)?.toInt();

    String usageHint() {
      final parts = <String>[];
      if (watts != null && watts > 0) parts.add('${watts}W');
      if (hours != null && hours > 0) parts.add('${hours}h/day');
      if (qty != null && qty > 1) parts.add('×$qty');
      if (parts.isEmpty) return '';
      return ' (${parts.join(' · ')})';
    }

    if (lower.contains('air') && lower.contains('condition')) {
      tips.add(
        _TipDefinition(
          icon: Icons.ac_unit_rounded,
          title: name,
          body: exceedsBudget
              ? 'Raise the setpoint by 1–2°C and use a fan to stay comfortable. Clean filters help a lot.'
              : 'Keep doors/windows sealed and clean the filter monthly to maintain efficiency.',
        ),
      );
      continue;
    }

    if (lower.contains('refrigerator') || lower.contains('fridge')) {
      tips.add(
        _TipDefinition(
          icon: Icons.kitchen,
          title: name,
          body:
              'Avoid frequent door opening, don’t overfill, and let hot food cool before storing. Good airflow helps it run efficiently.',
        ),
      );
      continue;
    }

    if (lower == 'tv' || lower.contains('television')) {
      tips.add(
        _TipDefinition(
          icon: Icons.tv_rounded,
          title: name,
          body:
              'Reduce brightness/backlight, enable eco mode, and turn off completely instead of leaving it on standby.',
        ),
      );
      continue;
    }

    if (lower.contains('fan')) {
      tips.add(
        _TipDefinition(
          icon: Icons.toys,
          title: name,
          body:
              'Clean the blades regularly and use the lowest comfortable speed. Pair with a slightly higher AC temperature to save more.',
        ),
      );
      continue;
    }

    if (lower.contains('rice') && lower.contains('cooker')) {
      tips.add(
        _TipDefinition(
          icon: Icons.rice_bowl_rounded,
          title: name,
          body:
              'Use “keep warm” only when needed. Turning it off after meals can reduce unnecessary draw.',
        ),
      );
      continue;
    }

    if (lower.contains('kettle')) {
      tips.add(
        _TipDefinition(
          icon: Icons.local_cafe_rounded,
          title: name,
          body:
              'Boiling extra water wastes energy. Fill just enough for your cup(s), and descale occasionally for better performance.',
        ),
      );
      continue;
    }

    if (lower.contains('dehumid')) {
      tips.add(
        _TipDefinition(
          icon: Icons.water_drop_outlined,
          title: name,
          body:
              'Aim for ~50–60% humidity, keep doors/windows closed, and clean filters to keep it efficient.',
        ),
      );
      continue;
    }

    if (lower.contains('laptop') || lower.contains('phone')) {
      tips.add(
        _TipDefinition(
          icon: Icons.power_rounded,
          title: name,
          body:
              'Unplug chargers when not in use. Reduce screen brightness and enable power saver to lower consumption.',
        ),
      );
      continue;
    }

    tips.add(
      _TipDefinition(
        icon: Icons.lightbulb_outline_rounded,
        title: name,
        body: exceedsBudget
            ? 'Try reducing usage time where possible and avoid standby power when not needed.'
            : 'Use only when needed and turn it off fully to avoid standby power draw.',
      ),
    );
  }

  return tips;
}
