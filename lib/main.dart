import 'package:flutter/material.dart';
import 'home_widget.dart';
import 'package:get_storage/get_storage.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

// ignore: prefer_const_constructors
void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("My App");
    setWindowMinSize(const Size(500, 800));
    // setWindowMaxSize(const Size(800, 1024));
    // Future<Null>.delayed(const Duration(seconds: 1), () {
    //   setWindowFrame(Rect.fromCenter(
    //       center: const Offset(1000, 700), width: 700, height: 970));
    // });
  }
  runApp(const App());
}

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