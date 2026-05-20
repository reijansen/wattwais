import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../models/appliance_input.dart';
import '../models/prediction_result.dart';

class PredictionApiService {
  const PredictionApiService({http.Client? client}) : _client = client;

  final http.Client? _client;

  http.Client get client => _client ?? http.Client();

  Future<PredictionResult> predictBill({
    required List<ApplianceInput> appliances,
    required double baseRate,
    required double sixMonthTotalBill,
    required double sixMonthTotalKwh,
    required double monthlyBudget,
  }) async {
    final url = Uri.parse('${AppConfig.predictionApiBaseUrl}/predict');

    final body = {
      'appliances': appliances.map((item) => item.toJson()).toList(),
      'base_rate': baseRate,
      'six_month_total_bill': sixMonthTotalBill,
      'six_month_total_kwh': sixMonthTotalKwh,
      'monthly_budget': monthlyBudget,
    };

    final response = await client
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(AppConfig.predictionApiTimeout);

    if (response.statusCode != 200) {
      throw Exception(
        'prediction failed (${response.statusCode}): ${response.body}',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return PredictionResult.fromJson(data);
  }

  Future<bool> checkBackendHealth() async {
    try {
      final url = Uri.parse('${AppConfig.predictionApiBaseUrl}/');
      final response = await client
          .get(url)
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
