import 'package:flutter/material.dart';
import 'control_widget.dart';
import 'settings_widget.dart';
import 'print_widget.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    ControlWidget(),
    PrintWidget(),
    SettingsWidget()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PCB Printer'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.api_rounded, color: Colors.red,),
            label: 'Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.print_rounded,color: Colors.deepOrange,),
            label: 'Print',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_accessibility_rounded, color: Colors.green,),
            label: 'Settings'
          )
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    }); 
  }
}