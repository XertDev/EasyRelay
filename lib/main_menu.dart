import 'package:easy_relay/model/relay_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'bloc/relay/relay_bloc.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  Future<void> showInfoDialog(RelaySettings settings, NetworkInfo networkInfo, BuildContext context) async {
    final String fullTargetAddress = "${settings.targetAddress.address}:${settings.targetPort}";
    final String? localIpV4 = await networkInfo.getWifiIP();
    final String? localIpV6 = await networkInfo.getWifiIPv6();

    const headerStyle = TextStyle(fontWeight: FontWeight.bold);

    List<Widget> infos = [];
    infos.add(const Text("Target address", style: headerStyle));
    infos.add(Text(fullTargetAddress));
    infos.add(const Text("Listening address", style: headerStyle));
    if(localIpV4 != null) {
      final String fullLocalIpV4Address = "${localIpV4!}:${settings.listenPort.toString()}";
      infos.add(Text(fullLocalIpV4Address));
    }
    if(localIpV6 != null) {
      final String fullLocalIpV6Address = "${localIpV6!}:${settings.listenPort.toString()}";
      infos.add(Text(fullLocalIpV6Address));
    }

    await showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text("Relay Info"),
          content: SingleChildScrollView(
            child: ListBody(
              children: infos,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RelayBloc, RelayState>(
      builder: (context, state) {
        final networkInfo = NetworkInfo();

        Color switchColor = Colors.grey;
        if (state is RelayInactive) {
          switchColor = Colors.red;
        } else if (state is RelayActive) {
          switchColor = Colors.green;
        }

        final bool enableInfo = (state is! RelayInitial);

        final Color infoButtonColor = enableInfo ? Colors.white70 : Colors.black38;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Easy Relay"),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                enableFeedback: enableInfo,
                icon: const Icon(Icons.info_outline),
                color: infoButtonColor,
                splashRadius: 22,
                tooltip: "Show relay info",
                onPressed: () {
                  if (enableInfo) {
                    showInfoDialog((state as RelayStateWithSettings).settings, networkInfo, context);
                  }
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Ink(
                    decoration: const ShapeDecoration(
                      color: Colors.white12,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.power_settings_new_outlined),
                      iconSize: 70,
                      color: switchColor,
                      onPressed: () {
                        context.read<RelayBloc>().add(const RelaySwitched());
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/settings");
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      "Settings",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
