import 'package:equatable/equatable.dart';

import '../../services/app_settings.dart';
import '../../services/landed_cost.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.ready = false,
    this.autoSyncEnabled = true,
    this.alertsEnabled = true,
    this.lastFullSyncAt,
    this.zeroFeeCents = LandedCost.defaultZeroFeeCents,
    this.directShippingCents = LandedCost.defaultDirectShippingCents,
  });

  factory SettingsState.from(AppSettings s) {
    return SettingsState(
      ready: s.isReady,
      autoSyncEnabled: s.autoSyncEnabled,
      alertsEnabled: s.alertsEnabled,
      lastFullSyncAt: s.lastFullSyncAt,
      zeroFeeCents: s.zeroFeeCents,
      directShippingCents: s.directShippingCents,
    );
  }

  final bool ready;
  final bool autoSyncEnabled;
  final bool alertsEnabled;
  final DateTime? lastFullSyncAt;
  final int zeroFeeCents;
  final int directShippingCents;

  @override
  List<Object?> get props => [
        ready,
        autoSyncEnabled,
        alertsEnabled,
        lastFullSyncAt,
        zeroFeeCents,
        directShippingCents,
      ];
}
