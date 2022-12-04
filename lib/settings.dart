import 'dart:io';

import 'package:easy_relay/model/relay_settings.dart';
import 'package:easy_relay/utils/ip_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/relay/relay_bloc.dart';

class Settings extends StatelessWidget {
  Settings({super.key});

  final _formKey = GlobalKey<FormState>();

  final _targetAddressController = TextEditingController();
  final _targetPortController = TextEditingController();
  final _listenPortController = TextEditingController();

  void onSaveForm(BuildContext context) {

    final destinationAddress = InternetAddress.tryParse(_targetAddressController.text)!;
    final destinationPort = int.parse(_targetPortController.text);
    final listenPort = int.parse(_listenPortController.text);

    final settings = RelaySettings(
        targetAddress: destinationAddress,
        targetPort: destinationPort,
        listenPort: listenPort
    );

    context.read<RelayBloc>().add(
        RelaySettingsUpdated(
            relaySettings: settings
        )
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(),
      ),
      hintColor: Colors.white70,
      textTheme: const TextTheme(
        subtitle1: TextStyle(color: Colors.white),
      )
    );

    final state = BlocProvider.of<RelayBloc>(context).state;
    String prevTargetAddress = "";
    String prevTargetPort = "";
    String prevListenPort = "";

    if (state is! RelayInitial) {
      final settings = (state as RelayStateWithSettings).settings;
      prevTargetAddress = settings.targetAddress.address;
      prevTargetPort = settings.targetPort.toString();
      prevListenPort = settings.listenPort.toString();
    }

    _targetAddressController.text = prevTargetAddress;
    _targetPortController.text = prevTargetPort;
    _listenPortController.text = prevListenPort;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Easy Relay - Settings"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Theme(
          data: theme,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _targetAddressController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Target address",
                        hintText: "Enter target address",
                      ),
                      validator: (value) {
                        if(!validateAddress(value)) {
                          return "Please enter valid ip address";
                        }
                        return null;
                      }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _targetPortController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Target port",
                        hintText: "Enter target port(1000-65535)",
                      ),
                      validator: (value) {
                        if(!validatePort(value)) {
                          return "Please enter valid port number";
                        }
                        return null;
                      }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: _listenPortController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Listen port",
                        hintText: "Enter listen port(1000-65535)",
                      ),
                      validator: (value) {
                        if(!validatePort(value)) {
                          return "Please enter valid port number";
                        }
                        return null;
                      }
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if(_formKey.currentState!.validate()) {
                        onSaveForm(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
