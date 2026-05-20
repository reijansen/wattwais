import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wattwais/core/config/app_config.dart';

class AiInsightsService {
  const AiInsightsService({http.Client? client}) : _client = client;

  final http.Client? _client;

  http.Client get client => _client ?? http.Client();

  Future<Map<String, dynamic>?> generateInsights({
    required String name,
    required Map<String, dynamic>? latestPrediction,
  }) async {
    if (latestPrediction == null) return null;

    final prediction =
        latestPrediction['prediction_result'] as Map<String, dynamic>?;
    if (prediction == null) return null;

    final usage =
        (prediction['estimated_monthly_kwh'] as num?)?.toDouble() ?? 0.0;
    final baseline =
        (prediction['historical_monthly_kwh'] as num?)?.toDouble() ?? 0.0;
    final bill = (prediction['estimated_bill'] as num?)?.toDouble() ?? 0.0;
    final exceedsBudget = prediction['exceeds_budget'] as bool?;
    final budgetUsage = (latestPrediction['budget'] as num?)?.toDouble();

    final appliances =
        (latestPrediction['appliances'] as List?)?.cast<dynamic>() ?? [];
    final top = _findTopAppliance(appliances, usage, bill);

    final payload = {
      'name': name.trim().isEmpty ? 'User' : name.trim(),
      'budget_kwh': budgetUsage,
      'estimated_monthly_kwh': usage,
      'historical_monthly_kwh': baseline,
      'estimated_bill': bill,
      'exceeds_budget': exceedsBudget,
      'top_appliance_name': top['name'],
      'top_appliance_percent': top['percent'],
      'top_appliance_kwh': top['kwh'],
      'top_appliance_cost': top['cost'],
      'appliances': appliances.map((item) {
        final map = item is Map ? item : const {};
        return {
          'name': (map['name'] ?? 'Appliance').toString(),
          'quantity': (map['quantity'] as num?)?.toInt() ?? 1,
          'watts': (map['watts'] as num?)?.toDouble() ?? 0.0,
          'hours_per_day': (map['hours_per_day'] as num?)?.toDouble() ?? 0.0,
          'days_per_week': (map['days_per_week'] as num?)?.toInt() ?? 7,
        };
      }).toList(),
    };

    final url = Uri.parse('${AppConfig.predictionApiBaseUrl}/ai/insights');
    final response = await client
        .post(
          url,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(AppConfig.predictionApiTimeout);

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);
    return data is Map<String, dynamic> ? data : null;
  }

  Map<String, dynamic> _findTopAppliance(
    List<dynamic> appliances,
    double totalUsage,
    double bill,
  ) {
    String topName = 'Appliance';
    double topKwh = 0;
    double topPercent = 0;
    double topCost = 0;
    double maxKwh = -1;

    for (final item in appliances) {
      final map = item is Map ? item : null;
      if (map == null) continue;
      final name = (map['name'] ?? '').toString().trim();
      final watts = (map['watts'] as num?)?.toDouble() ?? 0;
      final quantity = (map['quantity'] as num?)?.toDouble() ?? 1;
      final hoursPerDay = (map['hours_per_day'] as num?)?.toDouble() ?? 0;
      final daysPerWeek = (map['days_per_week'] as num?)?.toDouble() ?? 7;

      final monthlyKwh =
          watts * quantity * hoursPerDay * (daysPerWeek / 7.0) * 30.0 / 1000.0;
      if (monthlyKwh <= maxKwh) continue;
      maxKwh = monthlyKwh;

      final usageBase = totalUsage > 0 ? totalUsage : 1.0;
      final share = (monthlyKwh / usageBase) * 100;
      final boundedShare = share.clamp(0, 100).toDouble();
      final cost = bill * (boundedShare / 100);

      topName = name.isEmpty ? 'Appliance' : name;
      topKwh = monthlyKwh;
      topPercent = boundedShare;
      topCost = cost;
    }

    return {
      'name': topName,
      'kwh': topKwh,
      'percent': topPercent,
      'cost': topCost,
    };
  }
}
