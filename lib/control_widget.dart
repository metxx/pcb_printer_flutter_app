import 'dart:convert';
import 'dart:io';

import 'global_variables.dart' as globalvar;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:measured_size/measured_size.dart';

class ControlWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ControlWidget();
  }
}

class _ControlWidget extends State<ControlWidget> {
  double _currentSliderValue = 20;
  double _x = 0;
  double _y = 0;

  var picked;

  //String? value;
  bool loading = true;
  List<ApiResponse> leaveRequest = [];

  static Uri imageUrl = Uri.parse(
      "${globalvar.server_ip}/serve_layer_for_preview?v=${DateTime.now().millisecondsSinceEpoch}");

  void get() async {
    var response = await http.get(
      Uri.parse("${globalvar.server_ip}/files_on_server"),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List<dynamic> data = jsonData["responseObj"];
      for (dynamic d in data) {
        leaveRequest.add(ApiResponse.fromJson(d));
      }
      setState(() {
        loading = false;
        globalvar.selected_layer = null;
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
      initState();
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
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  iconSize: 50,
                  color: Colors.brown,
                  tooltip: 'Move motif up',
                  onPressed: () {
                    setState(() {
                      _y = _y - 10;
                    });
                  },
                ),
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 50,
                  color: Colors.brown,
                  tooltip: 'Move motif left',
                  onPressed: () {
                    setState(() {
                      _x = _x - 10;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: 50,
                  color: Colors.brown,
                  tooltip: 'Move motif right',
                  onPressed: () {
                    setState(() {
                      _x = _x + 10;
                    });
                  },
                ),
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 50,
                  color: Colors.brown,
                  tooltip: 'Move motif down',
                  onPressed: () {
                    setState(() {
                      _y = _y + 10;
                    });
                  },
                ),
              ]),
          const SizedBox(height: 60),
        ],
      ),
    );

    Widget switchPhotoresist = SwitchListTile(
      title: const Text('Positive fotoresist'),
      value: globalvar.positive_fotoresist,
      onChanged: (bool value) {
        setState(() {
          globalvar.positive_fotoresist = value;
        });
      },
      secondary: const Icon(Icons.invert_colors),
    );

    Widget precisionSlider = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text('Precision slider'),
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

    // Widget preview_window = Card(
    //     shadowColor: Theme.of(context).shadowColor,
    //     elevation: 4,
    //     child: loading
    //         ? const CircularProgressIndicator()
    //         : Image.network(imageUrl.toString()));

    // Widget previewWindow = Card(
    //     shadowColor: Theme.of(context).shadowColor,
    //     elevation: 4,
    //     child: loading
    //         ? const CircularProgressIndicator()
    //         : Container(
    //             width: 1920 / 4,
    //             height: 1080 / 3,
    //             color: Colors.green,
    //             padding: EdgeInsets.all(35),
    //             alignment: Alignment.center,
    //             child: Transform.translate(
    //                 offset: Offset(_x, _y),
    //                 child: Image.network(imageUrl.toString())),
    //           ));

    // Widget previewWindow = Center(
    //     child: Stack(
    //   children: [
    //     Container(
    //       height: 400,
    //       color: Colors.green,
    //       padding: EdgeInsets.all(35),
    //       alignment: Alignment.center,
    //       child: Transform.translate(
    //           offset: Offset(_x, _y),
    //           child: Image.network(imageUrl.toString())),
    //     ),
    //     Container(
    //       height: 400,
    //       decoration: BoxDecoration(
    //           //color: Colors.black,
    //           border: Border.all(width: 35, color: Colors.red)),
    //     ),
    //   ],
    // ));

    Widget previewWindow = LayoutBuilder(builder: (context, constraints) {
      print("Height:" + constraints.maxHeight.toString());
      print("Width:" + constraints.maxWidth.toString());
      return Center(
        child: Stack(
          children: [
            Container(
              height: 1080 / 3,
              width: constraints.maxWidth,
              color: Colors.green,
              //padding: const EdgeInsets.all(35),
              alignment: Alignment.center,
              child: Transform.translate(
                  offset: Offset(_x, _y),
                  child: Image.network(imageUrl.toString())),
            ),
            Container(
                height: 1080 / 3,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  //color: Colors.black,
                  // border: Border.all(width: 35, color: Colors.red)),
                  border: BorderDirectional(
                    start: BorderSide(
                        color: Colors.red,
                        width: ((constraints.maxWidth - (1920 / 3)) / 2) >= 0
                            ? ((constraints.maxWidth - (1920 / 3)) / 2)
                            : 0,
                        style: BorderStyle.solid),
                    top: BorderSide(
                        color: Colors.red,
                        width: ((constraints.maxWidth - (1920 / 3)) / 2) <= 0
                            ? 0
                            : 0,
                        style: BorderStyle.solid),
                    bottom: BorderSide(
                        color: Colors.red,
                        width: ((constraints.maxWidth - (1920 / 3)) / 2) <= 0
                            ? 0
                            : 0,
                        style: BorderStyle.solid),
                    end: BorderSide(
                        color: Colors.red,
                        width: ((constraints.maxWidth - (1920 / 3)) / 2) >= 0
                            ? ((constraints.maxWidth - (1920 / 3)) / 2)
                            : 0,
                        style: BorderStyle.solid),
                  ),
                )),
          ],
        ),
      );
    });

    Widget chooseLayer = Card(
      shadowColor: Theme.of(context).shadowColor,
      elevation: 4,
      child: loading
          ? const CircularProgressIndicator()
          : DropdownButton<String>(
              icon: const Icon(Icons.arrow_drop_down_sharp),
              isExpanded: true,
              alignment: AlignmentDirectional.center,
              hint: const Text('Select layer'),
              value: globalvar.selected_layer,
              items: leaveRequest.map((item) {
                return DropdownMenuItem(
                  alignment: AlignmentDirectional.centerStart,
                  value: item.value,
                  child: Text(item.value),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  globalvar.selected_layer = val;
                  imageUrl = Uri.parse(
                      "${globalvar.server_ip}/serve_layer_for_preview?v=${DateTime.now().millisecondsSinceEpoch}");
                });
                globalvar.doPostRender("/render",
                    globalvar.positive_fotoresist.toString(), val.toString());
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
        previewWindow,
        chooseLayer,
        //bottomSheet,
        controlSection,
        switchPhotoresist,
        //precisionSlider,
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
            padding: const EdgeInsets.all(0))
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
