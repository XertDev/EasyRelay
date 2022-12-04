part of 'relay_bloc.dart';

@immutable
abstract class RelayEvent {
  const RelayEvent();
}

class RelaySwitched extends RelayEvent {
  const RelaySwitched();
}

class RelayInit extends RelayEvent {
  const RelayInit();
}

class RelaySettingsUpdated extends RelayEvent {
  final RelaySettings relaySettings;

  const RelaySettingsUpdated({required this.relaySettings});
}