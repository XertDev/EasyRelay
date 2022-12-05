package info.xert.easy_relay;

import android.annotation.TargetApi;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.IBinder;
import android.os.PowerManager;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

public class RelayService extends Service {
    final static int NOTIFICATION_ID = 1;
    final static String SERVICE_CHANNEL = "relay_service";
    final static String SERVICE_NAME = "Relay Service";

    private boolean isRunning = false;
    private NotificationCompat.Builder builder;
    private NotificationManager notificationManager;

    private String targetAddress;
    private int targetPort;
    private int listenPort;

    private RelayServer relayServer;

    private PowerManager powerManager;
    private PowerManager.WakeLock wakeLock;
    private WifiManager wifiManager;
    private WifiManager.WifiLock wifiLock;

    void startListening() {
        relayServer = new RelayServer(targetAddress, targetPort, listenPort);
        relayServer.start();
    }

    @Override
    public void onCreate() {
        super.onCreate();
        startForeground();
        aquireLocks();
        isRunning = true;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        final int result = super.onStartCommand(intent, flags, startId);

        targetAddress = intent.getStringExtra("targetAddress");
        targetPort = intent.getIntExtra("targetPort", 10001);
        listenPort = intent.getIntExtra("listenPort", 10001);

        startListening();
        return result;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        relayServer.stopServer();
        releaseLocks();
        isRunning = false;
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private void createNotificationChannel(String channelId, String channelName) {
        NotificationChannel notificationChannel = new NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_HIGH
        );

        notificationChannel.setLightColor(Color.BLUE);
        notificationChannel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);

        notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.createNotificationChannel(notificationChannel);
    }

    @TargetApi(Build.VERSION_CODES.Q)
    private void aquireLocks() {
        powerManager = (PowerManager) getSystemService(Context.POWER_SERVICE);
        wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK | PowerManager.ON_AFTER_RELEASE, "easyRelay:keepConnectionLock");

        wakeLock.acquire(30*60*1000L /*30 minutes*/);

        wifiManager = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        wifiLock = wifiManager.createWifiLock(WifiManager.WIFI_MODE_FULL_LOW_LATENCY , "easyRelay:wifiKeepLock");
        wifiLock.acquire();
    }

    private void releaseLocks() {
        if (wifiLock != null && wifiLock.isHeld()) {
            wifiLock.release();
        }

        if (wakeLock != null && wakeLock.isHeld()) {
            wakeLock.release();
        }
    }

    private void startForeground() {
        final String channelId = (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) ? SERVICE_CHANNEL : "";
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel(SERVICE_CHANNEL, SERVICE_NAME);
        }

        builder = new NotificationCompat.Builder(this, channelId);
        builder.setOngoing(true)
                .setOnlyAlertOnce(true)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("Relay")
                .setContentText("Running")
                .setCategory(Notification.CATEGORY_SERVICE);

        startForeground(NOTIFICATION_ID, builder.build());
    }

    private void updateNotification(String text) {
        builder.setContentText(text);
        notificationManager.notify(NOTIFICATION_ID, builder.build());
    }
}
