import 'dart:async';
import 'dart:convert';

import 'package:easy_relay/model/relay_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const kSettingsKey = '__setting_key__';

  final SharedPreferences _plugin;

  SettingsRepository({
    required SharedPreferences plugin
  }) : _plugin = plugin;

  String? _getValue(String key) => _plugin.getString(key);
  Future<void> _setValue(String key, String value) =>
    _plugin.setString(key, value);

  Future<RelaySettings?> getRelaySettings() async {
    final settingsJson = _getValue(kSettingsKey);
    if (settingsJson != null) {
      final settingsMap = Map<String, dynamic>.from(
        json.decode(settingsJson)
      );

      return RelaySettings.fromJson(settingsMap);
    }
    return null;
  }

  Future<void> setRelaySettings(RelaySettings settings) async {
    return _setValue(kSettingsKey, json.encode(settings));
  }
}