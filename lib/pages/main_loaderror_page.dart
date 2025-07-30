import 'package:flutter/material.dart';
import 'package:sagahelper/core/global_data.dart';

class ErrorScreen extends StatelessWidget {
  final Object error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    LocalDataManager.resetConfig();

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrangeAccent,
          brightness: MediaQuery.platformBrightnessOf(context),
        ),
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/gif/saga_err.gif', width: 200, height: 200),
              const SizedBox(height: 40),
              Text(
                'An error has ocurred, restart the app!\n${error.toString()}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
