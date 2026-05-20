import "package:flutter/material.dart";
class UsageMonth {
  const UsageMonth(this.label, this.kwh);

  final String label;
  final double kwh;
}

const usageHistory = <UsageMonth>[
  UsageMonth('Jan', 245),
  UsageMonth('Feb', 228),
  UsageMonth('Mar', 262),
  UsageMonth('Apr', 238),
  UsageMonth('May', 215),
  UsageMonth('Jun', 226),
  UsageMonth('Jul', 197),
];

class Appliance {
  const Appliance({
    required this.name,
    required this.icon,
    required this.watts,
    required this.hoursPerDay,
    required this.quantity,
  });

  final String name;
  final IconData icon;
  final int watts;
  final int hoursPerDay;
  final int quantity;

  Appliance copyWith({int? watts, int? hoursPerDay, int? quantity}) {
    return Appliance(
      name: name,
      icon: icon,
      watts: watts ?? this.watts,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      quantity: quantity ?? this.quantity,
    );
  }

  int get monthlyKwh => ((watts * hoursPerDay * quantity * 30) / 1000).round();
}

final defaultAppliances = <Appliance>[
  const Appliance(
    name: 'Air Conditioner',
    icon: Icons.ac_unit_rounded,
    watts: 1500,
    hoursPerDay: 8,
    quantity: 1,
  ),
  const Appliance(
    name: 'Refrigerator',
    icon: Icons.kitchen_rounded,
    watts: 200,
    hoursPerDay: 24,
    quantity: 1,
  ),
  const Appliance(
    name: 'Ceiling Fan',
    icon: Icons.toys_rounded,
    watts: 75,
    hoursPerDay: 12,
    quantity: 3,
  ),
  const Appliance(
    name: 'Smart TV',
    icon: Icons.tv_rounded,
    watts: 120,
    hoursPerDay: 5,
    quantity: 1,
  ),
];

