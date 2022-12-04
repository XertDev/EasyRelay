part of 'relay_bloc.dart';

@immutable
abstract class RelayState extends Equatable {}

class RelayInitial extends RelayState {
  RelayInitial();

  @override
  List<Object?> get props => [];
}

abstract class RelayStateWithSettings extends RelayState {
  final RelaySettings settings;

  RelayStateWithSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class RelayActive extends RelayStateWithSettings {
  RelayActive(super.settings);
}

class RelayInactive extends RelayStateWithSettings {
  RelayInactive(super.settings);
}
