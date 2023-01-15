import 'package:flutter/material.dart';
import 'home_widget.dart';

// ignore: prefer_const_constructors
void main() => runApp(App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
      ),
      title: 'Fiala Diplomka',
      // ignore: prefer_const_constructors
      home: Home(),
    );
  }
}

// to run on brave browser
// flutter run -d web-server