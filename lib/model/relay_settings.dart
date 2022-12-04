import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'json_map.dart';

@immutable
class RelaySettings extends Equatable {
  final InternetAddress targetAddress;
  final int targetPort;
  final int listenPort;

  const RelaySettings({required this.targetAddress, required this.targetPort, required this.listenPort});

  static RelaySettings fromJson(JsonMap json) => RelaySettings(
      targetAddress: InternetAddress.tryParse(json["targetAddress"])!,
      targetPort: json["targetPort"],
      listenPort: json["listenPort"],
  );

  JsonMap toJson() => <String, dynamic> {
    "targetAddress": targetAddress.address,
    "targetPort": targetPort,
    "listenPort": listenPort
  };

  @override
  List<Object> get props => [targetAddress, targetPort, listenPort];
}