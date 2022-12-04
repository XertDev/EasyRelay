import 'package:flutter/services.dart';

import 'model/relay_settings.dart';

class RelayService {
  static const platform = MethodChannel("relay_service");

  void activate(RelaySettings settings) {
    final result = platform.invokeMethod(
        "startRelay",
        <String, dynamic>{
          "targetAddress": settings.targetAddress.address,
          "targetPort": settings.targetPort,
          "listenPort": settings.listenPort
        }
    );
    result.catchError((error) {
      print("Failed to invoke method: '${error.message}");
    });
  }

  void deactivate() {
    final result = platform.invokeMethod("stopRelay");
    result.catchError((error) {
      print("Failed to invoke method: '${error.message}");
    });
  }
}