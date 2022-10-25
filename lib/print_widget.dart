import 'global_variables.dart' as globalvar;
import 'package:flutter/material.dart';

class PrintWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PrintWidget();
  }
}

class _PrintWidget extends State<PrintWidget> {
  double _currentPowerSliderValue = 50;
  double _currenttimeSliderValue = 50;
  bool _overlay = false;

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).accentColor;

    Widget powerOutputSlider = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text('UV LED output power'),
            const SizedBox(height: 8),
            Slider(
              value: _currentPowerSliderValue,
              min: 0,
              max: 100,
              divisions: 50,
              label: _currentPowerSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentPowerSliderValue = value;
                });
              },
            ),
          ],
        ));

    Widget timeSlider = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text('Exposure time in minutes'),
            const SizedBox(height: 8),
            Slider(
              value: _currenttimeSliderValue,
              min: 0,
              max: 240,
              divisions: 240,
              label: _currenttimeSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currenttimeSliderValue = value;
                });
              },
            ),
          ],
        ));

    Widget printButton = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const SizedBox(width: 8, height: 20),
            ElevatedButton(
                child: const Text(
                  'Send parametrs to print',
                  textScaleFactor: 1.5,
                ),
                onPressed: () {
                  globalvar.doPostJason("/print", "0", "0", "false", "false",
                      "5000", "0", "copper.GTL");
                  //globalvar.doPost('/destroy');
                }),
          ],
        ));

    // Widget switchOverlay = SwitchListTile(
    //   title: const Text('Corection mask'),
    //   value: _overlay,
    //   onChanged: (bool value) {
    //     setState(() {
    //       _overlay = value;
    //     });
    //     //doPostparam('overlay', {'enable': _overlay.toString()});
    //   },
    //   secondary: const Icon(Icons.fullscreen_rounded),
    // );

    return ListView(
      //children: [switchOverlay, powerOutputSlider, timeSlider, printButton],
      children: [powerOutputSlider, timeSlider, printButton],
    );
  }
}
