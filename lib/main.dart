import 'package:easy_relay/relay_service.dart';
import 'package:easy_relay/repository/setting_repository.dart';
import 'package:easy_relay/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/relay/relay_bloc.dart';
import 'main_menu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final relayService = RelayService();
  final settingsRepository = SettingsRepository(
      plugin: await SharedPreferences.getInstance(),
  );
  runApp(
      MyApp(relayService: relayService, settingsRepository: settingsRepository,)
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
        required this.relayService,
        required this.settingsRepository,
        super.key
  });

  final RelayService relayService;
  final SettingsRepository settingsRepository;
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RelayBloc(
          relayService: relayService,
          settingRepository: settingsRepository,
      )..add(const RelayInit()),
      child: MaterialApp(
        title: 'Proxy for Dummies',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white10,
          appBarTheme: const AppBarTheme(
            color: Colors.black26,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.black87,
            ),
          ),
        ),
        routes: {
          "/": (context) => const MainMenu(),
          "/settings": (context) => Settings(),
        },
      ),
    );
  }
}
