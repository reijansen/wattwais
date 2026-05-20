class PredictionResult {
  final double predictedHourlyKwh;
  final double modelMonthlyKwh;
  final double applianceMonthlyKwh;
  final double historicalMonthlyKwh;
  final double estimatedMonthlyKwh;
  final double estimatedBill;
  final double effectiveRate;
  final double historicalMonthlyBill;

  final bool? exceedsBudget;

  final List<dynamic> applianceBreakdown;

  final String recommendation;

  PredictionResult({
    required this.predictedHourlyKwh,
    required this.modelMonthlyKwh,
    required this.applianceMonthlyKwh,
    required this.historicalMonthlyKwh,
    required this.estimatedMonthlyKwh,
    required this.estimatedBill,
    required this.effectiveRate,
    required this.historicalMonthlyBill,
    required this.exceedsBudget,
    required this.applianceBreakdown,
    required this.recommendation,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      predictedHourlyKwh:
          (json['predicted_hourly_kwh'] as num?)?.toDouble() ?? 0.0,

      modelMonthlyKwh:
          (json['model_monthly_kwh'] as num?)?.toDouble() ?? 0.0,

      applianceMonthlyKwh:
          (json['appliance_monthly_kwh'] as num?)?.toDouble() ?? 0.0,

      historicalMonthlyKwh:
          (json['historical_monthly_kwh'] as num?)?.toDouble() ?? 0.0,

      estimatedMonthlyKwh:
          (json['estimated_monthly_kwh'] as num?)?.toDouble() ?? 0.0,

      estimatedBill:
          (json['estimated_bill'] as num?)?.toDouble() ?? 0.0,

      effectiveRate:
          (json['effective_rate'] as num?)?.toDouble() ?? 0.0,

      historicalMonthlyBill:
          (json['historical_monthly_bill'] as num?)?.toDouble() ?? 0.0,

      exceedsBudget: json['exceeds_budget'] as bool?,

      applianceBreakdown:
          json['appliance_breakdown'] as List<dynamic>? ?? [],

      recommendation:
          json['recommendation']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'predicted_hourly_kwh': predictedHourlyKwh,
      'model_monthly_kwh': modelMonthlyKwh,
      'appliance_monthly_kwh': applianceMonthlyKwh,
      'historical_monthly_kwh': historicalMonthlyKwh,
      'estimated_monthly_kwh': estimatedMonthlyKwh,
      'estimated_bill': estimatedBill,
      'effective_rate': effectiveRate,
      'historical_monthly_bill': historicalMonthlyBill,
      'exceeds_budget': exceedsBudget,
      'appliance_breakdown': applianceBreakdown,
      'recommendation': recommendation,
    };
  }
}