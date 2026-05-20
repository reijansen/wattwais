import 'package:flutter/material.dart';
import 'package:wattwais/core/theme/app_theme.dart';
import 'package:wattwais/widgets/app_chrome.dart';
import '../widgets/screenscaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onPredict,
    required this.bill,
    required this.usage,
    required this.budgetUsage,
    required this.latestPrediction,
    required this.aiInsights,
    required this.name,
    required this.onEditName,
    required this.onTapNotifications,
  });

  final VoidCallback onPredict;
  final double bill;
  final double usage;
  final double budgetUsage;
  final Map<String, dynamic>? latestPrediction;
  final Map<String, dynamic>? aiInsights;
  final String name;
  final VoidCallback onEditName;
  final VoidCallback onTapNotifications;

  @override
  Widget build(BuildContext context) {
    final insights = _buildHomeInsights(
      latestPrediction: latestPrediction,
      aiInsights: aiInsights,
      fallbackBill: bill,
      fallbackUsage: usage,
      fallbackBudgetUsage: budgetUsage,
    );

    return ScreenScaffold(
      background: AppColors.midnight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double currentWidth = constraints.maxWidth;
          final double spacing = currentWidth < 360 ? 10.0 : 14.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(
                name: name,
                onTapName: onEditName,
                onTapNotifications: onTapNotifications,
              ),
              const SizedBox(height: 22),
              BillHeroCard(
                bill: insights.bill,
                usage: insights.usage,
                budgetusage: insights.budgetUsage,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      icon: Icons.trending_up_rounded,
                      value:
                          '${insights.dailyAverageKwh.toStringAsFixed(1)} kWh',
                      label: 'Daily avg',
                      delta: insights.dailyAverageDelta,
                    ),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: MetricCard(
                      icon: Icons.bolt_rounded,
                      value: '${insights.usage.toStringAsFixed(1)} kWh',
                      label: 'Monthly estimate',
                      delta: insights.budgetDelta,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),
              ApplianceUsageCard(insights: insights),
              SizedBox(height: spacing),
              AiInsightCard(insight: insights.aiInsight),
              const SizedBox(height: 52),
              SizedBox(
                width: double.infinity,
                child: PrimaryPillButton(
                  label: 'Predict next bill  ->',
                  onPressed: onPredict,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.name,
    required this.onTapName,
    required this.onTapNotifications,
  });

  final String name;
  final VoidCallback onTapName;
  final VoidCallback onTapNotifications;

  @override
  Widget build(BuildContext context) {
    final String firstLetter = _firstLetter(name);

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFE6DFD2), Color(0xFFB7C0CC)],
            ),
          ),
          child: Center(
            child: Text(
              firstLetter,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Good evening',
                  style: TextStyle(
                    color: Color(0xFFC9CEE1),
                    fontSize: 15,
                    fontFamily: 'Helvetica Neue',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onTapName,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFFDDE1F0),
                      fontSize: 28,
                      fontFamily: 'Helvetica Neue',
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Stack(
          clipBehavior: Clip.none,
          children: [
            InkWell(
              onTap: onTapNotifications,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF252B56),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ),
            Positioned(
              top: 14,
              right: 13,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BillHeroCard extends StatelessWidget {
  const BillHeroCard({
    super.key,
    required this.bill,
    required this.usage,
    required this.budgetusage,
  });

  final double bill;
  final double usage;
  final double budgetusage;

  @override
  Widget build(BuildContext context) {
    final billWhole = bill.toStringAsFixed(2).split('.')[0];
    final billDecimal = bill.toStringAsFixed(2).split('.')[1];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your bill for this month',
            style: TextStyle(
              color: Color(0xFF073A68),
              fontSize: 14,
              fontFamily: 'Helvetica Neue',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 26),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.midnight,
                  fontSize: 56,
                  fontFamily: 'Helvetica Neue',
                  fontWeight: FontWeight.w900,
                  height: .9,
                  letterSpacing: 0,
                ),
                children: [
                  TextSpan(text: 'PHP $billWhole'),
                  TextSpan(
                    text: '.$billDecimal',
                    style: const TextStyle(color: AppColors.blueDark),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${usage.toStringAsFixed(0)} kWh',
              style: const TextStyle(
                color: Color(0xFF083D6D),
                fontSize: 13,
                fontFamily: 'Helvetica Neue',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: budgetusage > 0 ? (usage / budgetusage) : 0.0,
              color: AppColors.midnight,
              backgroundColor: AppColors.blueDark,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '0 kWh',
                style: TextStyle(
                  color: Color(0xFF11517D),
                  fontFamily: 'Helvetica Neue',
                ),
              ),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text('Budget: ${budgetusage.toStringAsFixed(0)} kWh'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.delta,
  });

  final IconData icon;
  final String value;
  final String label;
  final String delta;

  @override
  Widget build(BuildContext context) {
    return WattCard(
      color: AppColors.navyPanel,
      borderColor: AppColors.border,
      padding: const EdgeInsets.all(18),
      child: SizedBox(
        height: 104,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.muted, size: 27),
                const Spacer(),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      delta,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontSize: 12,
                        fontFamily: 'Helvetica Neue',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontFamily: 'Helvetica Neue',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontFamily: 'Helvetica Neue',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApplianceUsageCard extends StatelessWidget {
  const ApplianceUsageCard({super.key, required this.insights});

  final HomeInsights insights;

  @override
  Widget build(BuildContext context) {
    return WattCard(
      color: AppColors.navyPanel,
      borderColor: AppColors.border,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      radius: 24,
      child: Row(
        children: [
          const IconBubble(icon: Icons.lightbulb_outline_rounded),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Most Used Appliance',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      fontFamily: 'Helvetica Neue',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    insights.topApplianceName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Helvetica Neue',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${insights.topApplianceKwh.toStringAsFixed(0)} kWh • PHP ${insights.topApplianceCost.toStringAsFixed(0)} this month',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontFamily: 'Helvetica Neue',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${insights.topAppliancePercent.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Helvetica Neue',
                  ),
                ),
              ),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'of usage',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontFamily: 'Helvetica Neue',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key, required this.insight});

  final String insight;

  @override
  Widget build(BuildContext context) {
    return WattCard(
      color: AppColors.navyPanel,
      borderColor: AppColors.border,
      radius: 24,
      padding: const EdgeInsets.all(22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconBubble(icon: Icons.smart_toy_outlined),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Insight',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  insight,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    height: 1.35,
                    fontFamily: 'Helvetica Neue',
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

String _firstLetter(String name) {
  final String trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return trimmed.substring(0, 1).toUpperCase();
}

class HomeInsights {
  const HomeInsights({
    required this.bill,
    required this.usage,
    required this.budgetUsage,
    required this.dailyAverageKwh,
    required this.dailyAverageDelta,
    required this.budgetDelta,
    required this.topApplianceName,
    required this.topApplianceKwh,
    required this.topApplianceCost,
    required this.topAppliancePercent,
    required this.aiInsight,
  });

  final double bill;
  final double usage;
  final double budgetUsage;
  final double dailyAverageKwh;
  final String dailyAverageDelta;
  final String budgetDelta;
  final String topApplianceName;
  final double topApplianceKwh;
  final double topApplianceCost;
  final double topAppliancePercent;
  final String aiInsight;
}

HomeInsights _buildHomeInsights({
  required Map<String, dynamic>? latestPrediction,
  required Map<String, dynamic>? aiInsights,
  required double fallbackBill,
  required double fallbackUsage,
  required double fallbackBudgetUsage,
}) {
  final prediction =
      latestPrediction?['prediction_result'] as Map<String, dynamic>?;

  final double estimatedBill =
      (prediction?['estimated_bill'] as num?)?.toDouble() ?? fallbackBill;
  final double estimatedMonthlyKwh =
      (prediction?['estimated_monthly_kwh'] as num?)?.toDouble() ??
      fallbackUsage;
  final double baselineMonthlyKwh =
      (prediction?['historical_monthly_kwh'] as num?)?.toDouble() ??
      fallbackBudgetUsage;

  final double dailyAverageKwh = estimatedMonthlyKwh / 30;
  final double baselineDailyKwh = baselineMonthlyKwh / 30;
  final double dailyDeltaPercent = baselineDailyKwh <= 0
      ? 0
      : ((dailyAverageKwh - baselineDailyKwh) / baselineDailyKwh) * 100;

  final double budgetDeltaPercent = baselineMonthlyKwh <= 0
      ? 0
      : ((estimatedMonthlyKwh - baselineMonthlyKwh) / baselineMonthlyKwh) * 100;

  final List<dynamic> appliances =
      (latestPrediction?['appliances'] as List?)?.cast<dynamic>() ?? [];

  String topName = 'No appliance yet';
  double topKwh = 0;
  double topCost = 0;
  double topPercent = 0;
  double currentTopMonthlyKwh = -1;

  for (final dynamic item in appliances) {
    final map = item is Map ? item : null;
    if (map == null) continue;

    final String name = (map['name'] ?? '').toString().trim();
    final double watts = (map['watts'] as num?)?.toDouble() ?? 0;
    final double quantity = (map['quantity'] as num?)?.toDouble() ?? 1;
    final double hoursPerDay = (map['hours_per_day'] as num?)?.toDouble() ?? 0;
    final double daysPerWeek = (map['days_per_week'] as num?)?.toDouble() ?? 7;

    final double monthlyKwh =
        watts * quantity * hoursPerDay * (daysPerWeek / 7.0) * 30.0 / 1000.0;
    if (monthlyKwh <= currentTopMonthlyKwh) continue;
    currentTopMonthlyKwh = monthlyKwh;

    final double usageBase = estimatedMonthlyKwh > 0 ? estimatedMonthlyKwh : 1;
    final double share = (monthlyKwh / usageBase) * 100;
    final double boundedShare = share.clamp(0, 100).toDouble();
    final double estimatedCost = estimatedBill * (boundedShare / 100.0);

    topName = name.isEmpty ? 'Appliance' : name;
    topKwh = monthlyKwh;
    topCost = estimatedCost;
    topPercent = boundedShare;
  }

  final String homeInsightFromApi =
      ((aiInsights?['home_insight'] as Map?)?['message'] ?? '')
          .toString()
          .trim();
  final String predictionRecommendation = (prediction?['recommendation'] ?? '')
      .toString()
      .trim();
  final String aiInsight = homeInsightFromApi.isNotEmpty
      ? homeInsightFromApi
      : predictionRecommendation.isNotEmpty
      ? predictionRecommendation
      : _fallbackInsight(topName, topPercent, budgetDeltaPercent);

  return HomeInsights(
    bill: estimatedBill,
    usage: estimatedMonthlyKwh,
    budgetUsage: baselineMonthlyKwh,
    dailyAverageKwh: dailyAverageKwh,
    dailyAverageDelta: _formatPercentDelta(dailyDeltaPercent),
    budgetDelta: _formatPercentDelta(budgetDeltaPercent),
    topApplianceName: topName,
    topApplianceKwh: topKwh,
    topApplianceCost: topCost,
    topAppliancePercent: topPercent,
    aiInsight: aiInsight,
  );
}

String _formatPercentDelta(double percent) {
  if (percent.isNaN || percent.isInfinite) {
    return '0%';
  }
  final String sign = percent >= 0 ? '+' : '';
  return '$sign${percent.toStringAsFixed(0)}%';
}

String _fallbackInsight(
  String topApplianceName,
  double topShare,
  double budgetDelta,
) {
  if (topShare <= 0 || topApplianceName == 'No appliance yet') {
    return 'Add your appliances and run a prediction to get personalized savings recommendations.';
  }

  if (budgetDelta > 0) {
    return '$topApplianceName is driving ${topShare.toStringAsFixed(0)}% of usage. Try trimming daily runtime or using eco settings to stay within budget.';
  }

  return '$topApplianceName accounts for ${topShare.toStringAsFixed(0)}% of usage. Keep this appliance optimized to maintain your current efficiency.';
}
