import 'package:flutter/material.dart';

class ApplianceModel {
  final String id;
  final String name;
  final IconData icon;
  final int watts;
  final int quantity;
  final int hoursPerDay;
  final int daysPerWeek;

  const ApplianceModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.watts,
    required this.quantity,
    required this.hoursPerDay,
    required this.daysPerWeek,
  });

  //copy wiht
  ApplianceModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    int? watts,
    int? quantity,
    int? hoursPerDay,
    int? daysPerWeek,
  }) {
    return ApplianceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      watts: watts ?? this.watts,
      quantity: quantity ?? this.quantity,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
    );
  }

  //from firestore
  factory ApplianceModel.fromMap(String id, Map<String, dynamic> map) {
    return ApplianceModel(
      id: id,
      name: map['name'] ?? '',
      icon: IconData(
        map['icon_codepoint'] ?? Icons.devices.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      watts: (map['watts'] ?? 0) as int,
      quantity: (map['quantity'] ?? 1) as int,
      hoursPerDay: (map['hours_per_day'] ?? 1) as int,
      daysPerWeek: (map['days_per_week'] ?? 7) as int,
    );
  }

  // to firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon_codepoint': icon.codePoint,
      'watts': watts,
      'quantity': quantity,
      'hours_per_day': hoursPerDay,
      'days_per_week': daysPerWeek,
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }
}