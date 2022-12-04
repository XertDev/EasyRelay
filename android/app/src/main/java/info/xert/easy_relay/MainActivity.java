package info.xert.easy_relay;

import android.content.Intent;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private final String CHANNEL = "relay_service";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);

        channel.setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "startRelay": {
                            final String targetAddress = call.argument("targetAddress");
                            final Integer targetPort = call.argument("targetPort");
                            final Integer listenPort = call.argument("listenPort");

                            final Intent intent = new Intent(this, RelayService.class);
                            intent.putExtra("targetAddress", targetAddress);
                            intent.putExtra("targetPort", targetPort);
                            intent.putExtra("listenPort", listenPort);
                            startService(intent);
                            result.success(null);
                            break;
                        }
                        case "stopRelay": {
                            stopService(new Intent(this, RelayService.class));
                            result.success(null);
                            break;
                        }
                        default:
                            result.notImplemented();
                    }
                }
        );
    }
}
