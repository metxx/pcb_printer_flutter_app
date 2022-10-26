import 'dart:convert';
import 'dart:io';

import 'global_variables.dart' as globalvar;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ControlWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ControlWidget();
  }
}

class _ControlWidget extends State<ControlWidget> {
  double _currentSliderValue = 20;

  var picked;
  //String? value;
  bool loading = true;
  List<ApiResponse> leaveRequest = [];

  static Uri imageUrl = Uri.parse(
      "${globalvar.server_ip}/serve_layer_for_preview?v=${DateTime.now().millisecondsSinceEpoch}");

  void get() async {
    var response = await http.get(
      Uri.parse("http://127.0.0.1:8000/files_on_server"),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List<dynamic> data = jsonData["responseObj"];
      for (dynamic d in data) {
        leaveRequest.add(ApiResponse.fromJson(d));
      }
      setState(() {
        loading = false;
      });
    } else {
      throw Exception();
    }
  }

  @override
  void initState() {
    get();
    super.initState();
  }

  void _pickFile() async {
    setState(() {
      loading = true;
      globalvar.selected_layer = null;
    });
    picked = await FilePicker.platform
        .pickFiles(allowMultiple: false, withData: true);

    if (picked != null) {
      print(picked.files.first.name);
      globalvar.doPostFile('/uploadfile', picked.files.first.path);
      setState(() {
        loading = false;
      });
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

  // void _show(BuildContext ctx) {
  //   showModalBottomSheet(
  //       elevation: 10,
  //       backgroundColor: Colors.amber,
  //       context: ctx,
  //       builder: (ctx) => Container(
  //             width: 300,
  //             height: 250,
  //             color: Colors.white54,
  //             alignment: Alignment.center,
  //             child: const Text('Breathe in... Breathe out...'),
  //           ));
  // }

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
        child: loading
            ? const CircularProgressIndicator()
            : Image.network(imageUrl.toString()));

    Widget choose_layer = Card(
      shadowColor: Theme.of(context).shadowColor,
      elevation: 4,
      child: loading
          ? const CircularProgressIndicator()
          : DropdownButton<String>(
              hint: const Text('Select layer'),
              value: globalvar.selected_layer,
              items: leaveRequest.map((item) {
                return DropdownMenuItem(
                  value: item.value,
                  child: Text(item.value),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  //value = val;
                  globalvar.selected_layer = val;
                  imageUrl = Uri.parse(
                      "${globalvar.server_ip}/serve_layer_for_preview?v=${DateTime.now().millisecondsSinceEpoch}");
                });
              },
            ),
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

class ApiResponse {
  ApiResponse({
    required this.key,
    required this.value,
  });

  int key;
  String value;

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
        key: json["Key"],
        value: json["Value"],
      );

  Map<String, dynamic> toJson() => {
        "Key": key,
        "Value": value,
      };
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
