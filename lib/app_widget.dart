import 'package:flutter/material.dart';
import 'package:frequencimetro_8051/bluetooth_demo_widget.dart';
import 'package:frequencimetro_8051/frequencimetro_page.dart';

class AppWidget extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      themeMode: ThemeMode.light,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(0, 0, 0, 255),
        ),
      ),
      home: MyApp(),
    );
  }
}
