import '../models/appliance_model.dart';

extension ApplianceEnergy
    on ApplianceModel {

  double get monthlyKwh {
    return
        (watts *
            quantity *
            hoursPerDay *
            (daysPerWeek / 7) *
            30) /
        1000;
  }
}