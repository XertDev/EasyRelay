import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/relay/relay_bloc.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Easy Relay"),
        centerTitle: true,
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
              BlocBuilder<RelayBloc, RelayState>(
                builder: (context, state) {
                  Color switchColor = Colors.grey;
                  if (state is RelayInactive) {
                    switchColor = Colors.red;
                  }
                  else if (state is RelayActive){
                    switchColor = Colors.green;
                  }

                  return Ink(
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
                  );
                },
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
  }
}
