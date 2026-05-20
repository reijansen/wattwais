import 'package:flutter/material.dart';

//reusable appliance template with default values.
//pre-populating appliances
class ApplianceTemplate {
  final String name;
  final IconData icon;
  final int defaultWatts;
  final int defaultQuantity;
  final int defaultHoursPerDay;
  final int defaultDaysPerWeek;

  const ApplianceTemplate({
    required this.name,
    required this.icon,
    required this.defaultWatts,
    this.defaultQuantity = 1,
    this.defaultHoursPerDay = 1,
    this.defaultDaysPerWeek = 7,
  });

  ApplianceTemplate copyWith({
    String? name,
    IconData? icon,
    int? defaultWatts,
    int? defaultQuantity,
    int? defaultHoursPerDay,
    int? defaultDaysPerWeek,
  }) {
    return ApplianceTemplate(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      defaultWatts: defaultWatts ?? this.defaultWatts,
      defaultQuantity: defaultQuantity ?? this.defaultQuantity,
      defaultHoursPerDay: defaultHoursPerDay ?? this.defaultHoursPerDay,
      defaultDaysPerWeek: defaultDaysPerWeek ?? this.defaultDaysPerWeek,
    );
  }


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApplianceTemplate && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
