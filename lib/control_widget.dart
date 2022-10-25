import 'dart:convert';
import 'dart:io';

import 'global_variables.dart' as globalvar;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class FoodCourt {
  final String name;
  FoodCourt(this.name);
}

class ControlWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ControlWidget();
  }
}

class _ControlWidget extends State<ControlWidget> {
  double _currentSliderValue = 20;

  var picked;

  void _pickFile() async {
    picked = await FilePicker.platform
        .pickFiles(allowMultiple: false, withData: true);

    if (picked != null) {
      print(picked.files.first.name);
      globalvar.doPostFile('/uploadfile', picked.files.first.path);
    }
  }

  void _clearCachedFiles() {
    FilePicker.platform.clearTemporaryFiles().then((result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: result! ? Colors.green : Colors.red,
          content: Text((result
              ? 'Temporary files removed with success.'
              : 'Failed to clean temporary files')),
        ),
      );
    });
  }

  rescale(bool direction) {
    var value;

    if (direction) {
      value = 1 + (_currentSliderValue / 1000);
    } else {
      value = 1 - (_currentSliderValue / 1000);
    }
    return value;
  }

  void _show(BuildContext ctx) {
    showModalBottomSheet(
        elevation: 10,
        backgroundColor: Colors.amber,
        context: ctx,
        builder: (ctx) => Container(
              width: 300,
              height: 250,
              color: Colors.white54,
              alignment: Alignment.center,
              child: const Text('Breathe in... Breathe out...'),
            ));
  }

  @override
  Widget build(BuildContext musimetoopravit) {
    Color color = Theme.of(musimetoopravit).accentColor;

    Widget controlSection = Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildButtonColumn(color, Icons.rotate_left_rounded, "move",
                  {'key': 'rotate_right'}),
              _buildButtonColumn(color, Icons.keyboard_arrow_up_rounded, "move",
                  {'y': _currentSliderValue.round().toString()}),
              _buildButtonColumn(color, Icons.rotate_right_rounded, "move",
                  {'key': 'rotate_right'})
            ],
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildButtonColumn(color, Icons.keyboard_arrow_left_rounded,
                  "move", {'x': _currentSliderValue.round().toString()}),
              _buildButtonColumn(
                  color, Icons.select_all_rounded, "move", {'key': 'select'}),
              _buildButtonColumn(color, Icons.keyboard_arrow_right_rounded,
                  "move", {'x': (-_currentSliderValue).round().toString()}),
            ],
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildButtonColumn(color, Icons.zoom_out_rounded, "scale",
                  {'scale': rescale(false).toString()}),
              _buildButtonColumn(color, Icons.keyboard_arrow_down_rounded,
                  "move", {'y': (-_currentSliderValue).round().toString()}),
              _buildButtonColumn(color, Icons.zoom_in_rounded, "scale",
                  {'scale': rescale(true).toString()}),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );

    Widget precisionSlider = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text('Precision slider'),
            const SizedBox(height: 10),
            Slider(
              value: _currentSliderValue,
              min: 1,
              max: 100,
              divisions: 10,
              label: _currentSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              },
            ),
          ],
        ));

    Widget clearuploadButton = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 8, height: 20),
            ElevatedButton(
                child: const Text(
                  'Upload Gerber',
                  textScaleFactor: 1.5,
                ),
                onPressed: () {
                  _pickFile();
                  print('upload pressed');
                }),
            const SizedBox(height: 60),
            const SizedBox(width: 8, height: 20),
            ElevatedButton(
              child: const Text(
                'Clear',
                textScaleFactor: 1.5,
              ),
              onPressed: () {
                globalvar.doPost('/destroy');
                //_clearCachedFiles();
              },
            ),
          ],
        ));

    Widget preview_window = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        child: Image.file(
          File('/home/met_xx/Code/pcb-tools-met_xx/to_display.png'),
        ));

    // Widget choose_layer = Card(
    //   shadowColor: Theme.of(context).shadowColor,
    //   elevation: 4,
    //   child: DropdownButton(
    //     // Initial Value
    //     value: globalvar.dropdownvalue,

    //     // Down Arrow Icon
    //     icon: const Icon(Icons.keyboard_arrow_down),

    //     hint: Text('no layer loaded'),

    //     // Array list of items
    //     items: globalvar.items.map((String items) {
    //       return DropdownMenuItem(
    //         value: items,
    //         child: Text(items),
    //       );
    //     }).toList(),
    //     // After selecting the desired option,it will
    //     // change button value to selected value
    //     onChanged: (String? newValue) {
    //       setState(() {
    //         globalvar.dropdownvalue = newValue!;
    //       });
    //     },
    //   ),
    // );

    Widget choose_layer = Card(
      shadowColor: Theme.of(context).shadowColor,
      elevation: 4,
      child: FutureBuilder<List<FoodCourt>>(
          future: _getFoodCourt(),
          builder: (context, snapshot) {
            var selectedFc;
            return DropdownButton<String>(
                hint: Text("Select"),
                value: selectedFc,
                onChanged: (newValue) {
                  setState(() {
                    selectedFc = newValue;
                  });
                },
                items: snapshot.data
                    ?.map((fc) => DropdownMenuItem<String>(
                          value: fc.name,
                          child: Text(fc.name),
                        ))
                    .toList());
          }),
    );

    // Widget bottomSheet = Card(
    //     shadowColor: Theme.of(context).shadowColor,
    //     elevation: 4,
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         const SizedBox(width: 8, height: 20),
    //         ElevatedButton(
    //             child: const Text(
    //               'Choose layer',
    //               textScaleFactor: 1.5,
    //             ),
    //             onPressed: () => _show(context)),
    //       ],
    //     ));

    return ListView(
      children: [
        preview_window,
        choose_layer,
        //bottomSheet,
        controlSection,
        precisionSlider,
        clearuploadButton,
      ],
    );
  }

  Column _buildButtonColumn(
      Color color, IconData icon, var path, var parametrs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () => doPostparam(path, parametrs),
            //constraints: BoxConstraints(maxHeight: 300),
            icon: Icon(
              icon,
              size: 35,
            ),
            color: color,
            padding: EdgeInsets.all(0))
      ],
    );
  }
}

void doPostparam(var path, var params) async {
  var url = Uri.http(globalvar.server_ip, '/' + path, params);
  try {
    var response = await http.post(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    print('$url');
  } catch (e) {
    print(e);
    print('URL: $url'); // prompt error to user
  }
}

// void doPostfile(var file) async {
//   var url = Uri.parse('http://127.0.0.1:8000/uploadfile');
//   try {
//     var response = await http.post(url, body: file);
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');
//     print('$url');
//   } catch (e) {
//     print(e);
//     print('URL: $url'); // prompt error to user
//   }
// }

Future<List<FoodCourt>> _getFoodCourt() async {
  var data =
      await http.get(Uri.parse(globalvar.server_ip + "/files_on_server"));
  var jsonData = json.decode(data.body);

  List<FoodCourt> fcs = [];

  for (var u in jsonData) {
    FoodCourt fc = FoodCourt(u["name"]);
    fcs.add(fc);
  }
  print(fcs);
  return fcs;
}
