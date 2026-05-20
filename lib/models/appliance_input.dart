import "package:wattwais/models/appliance_model.dart";

//appliance input for prediction API payloads.
class ApplianceInput {
  final String name;
  final int quantity;
  final double watts;
  final double hoursPerDay;
  final int daysPerWeek;

  ApplianceInput({
    required this.name,
    required this.quantity,
    required this.watts,
    required this.hoursPerDay,
    required this.daysPerWeek,
  });

  factory ApplianceInput.fromModel(ApplianceModel model) {
    return ApplianceInput(
      name: model.name,
      quantity: model.quantity,
      watts: model.watts.toDouble(),
      hoursPerDay: model.hoursPerDay.toDouble(),
      daysPerWeek: model.daysPerWeek,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'watts': watts,
      'hours_per_day': hoursPerDay,
      'days_per_week': daysPerWeek,
    };
  }
}