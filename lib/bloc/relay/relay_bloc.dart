import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easy_relay/relay_service.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../model/relay_settings.dart';
import '../../repository/setting_repository.dart';

part 'relay_event.dart';
part 'relay_state.dart';

class RelayBloc extends Bloc<RelayEvent, RelayState> {
  final RelayService relayService;
  final SettingsRepository settingRepository;

  RelayBloc({required this.relayService, required this.settingRepository}) : super(RelayInitial()) {
    on<RelayInit>(_onRelayInitiated);
    on<RelaySwitched>(_onRelaySwitched);
    on<RelaySettingsUpdated>(_onRelaySettingUpdated);
  }
  
  Future<void> _onRelayInitiated(RelayInit event, Emitter<RelayState> emit) async {
    if (state is RelayInitial) {
      final settings = await settingRepository.getRelaySettings();
      if (settings != null) {
        emit(RelayInactive(settings));
      }
    }
  }

  Future<void> _onRelaySwitched(RelaySwitched event, Emitter<RelayState> emit) async {
    if (state is RelayInactive) {
      final settings = (state as RelayInactive).settings;
      relayService.activate(settings);
      emit(RelayActive(settings));
    }
    else if (state is RelayActive) {
      relayService.deactivate();
      emit(RelayInactive((state as RelayActive).settings));
    }
  }


  Future<void> _onRelaySettingUpdated(RelaySettingsUpdated event, Emitter<RelayState> emit) async {
    if (state is RelayInactive) {
      await settingRepository.setRelaySettings(event.relaySettings);
      emit(RelayInactive(event.relaySettings));
    }
    else if (state is RelayActive) {
      relayService.deactivate();
      await settingRepository.setRelaySettings(event.relaySettings);
      emit(RelayInactive(event.relaySettings));
    }
    else if(state is RelayInitial) {
      await settingRepository.setRelaySettings(event.relaySettings);
      emit(RelayInactive(event.relaySettings));
    }
  }
}
