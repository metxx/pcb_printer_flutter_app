import 'dart:convert';

import 'global_variables.dart' as globalvar;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class ControlWidget extends StatefulWidget {
  const ControlWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ControlWidget();
  }
}

class _ControlWidget extends State<ControlWidget> {
  double _x = 0;
  double _y = 0;

  // ignore: prefer_typing_uninitialized_variables
  var picked;

  //String? value;
  bool loading = true;
  List<ApiResponse> leaveRequest = [];

  Uri imageUrl = Uri.parse(
      "${globalvar.serverip}/serve_layer_for_preview?v=${DateTime.now().millisecondsSinceEpoch}");

  void get() async {
    var response = await http.get(
      Uri.parse("${globalvar.serverip}/files_on_server"),
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
      globalvar.selectedlayer = null;
    });
    picked = await FilePicker.platform
        .pickFiles(allowMultiple: false, withData: true);

    if (picked != null) {
      //print(picked.files.first.name);
      globalvar.doPostFile('/uploadfile', picked.files.first.path);
      setState(() {
        loading = false;
      });
      initState();
    }
  }

  @override
  Widget build(BuildContext musimetoopravit) {
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
      value: globalvar.positivefotoresist,
      onChanged: (bool value) {
        setState(() {
          globalvar.positivefotoresist = value;
          globalvar.doPostRender(
              "/render",
              globalvar.positivefotoresist.toString(),
              globalvar.selectedlayer.toString());
          imageUrl = Uri.parse(
              "${globalvar.serverip}/serve_layer_for_preview?v=${DateTime.now().millisecondsSinceEpoch}");
        });
      },
      secondary: const Icon(Icons.invert_colors),
    );

    // Widget precisionSlider = Card(
    //     shadowColor: Theme.of(context).shadowColor,
    //     elevation: 4,
    //     child: Column(
    //       children: [
    //         const SizedBox(height: 10),
    //         const Text('Precision slider'),
    //         const SizedBox(height: 10),
    //         Slider(
    //           value: _currentSliderValue,
    //           min: 1,
    //           max: 100,
    //           divisions: 10,
    //           label: _currentSliderValue.round().toString(),
    //           onChanged: (double value) {
    //             setState(() {
    //               _currentSliderValue = value;
    //             });
    //           },
    //         ),
    //       ],
    //     ));

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
                  // print('upload pressed');
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
              },
            ),
          ],
        ));

    Widget previewWindow = LayoutBuilder(builder: (context, constraints) {
      // print("Height:" + constraints.maxHeight.toString());
      // print("Width:" + constraints.maxWidth.toString());
      return Center(
        child: Stack(
          children: [
            Container(
              height: 1080 / 3,
              width: constraints.maxWidth,
              color: globalvar.positivefotoresist ? Colors.white : Colors.black,
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
                            ? (((1080 / 3) - constraints.maxWidth * (0.5625)) /
                                2)
                            : 0,
                        style: BorderStyle.solid),
                    bottom: BorderSide(
                        color: Colors.red,
                        width: ((constraints.maxWidth - (1920 / 3)) / 2) <= 0
                            ? (((1080 / 3) - constraints.maxWidth * (0.5625)) /
                                2)
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
              value: globalvar.selectedlayer,
              items: leaveRequest.map((item) {
                return DropdownMenuItem(
                  alignment: AlignmentDirectional.centerStart,
                  value: item.value,
                  child: Text(item.value),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  globalvar.selectedlayer = val;
                  imageUrl = Uri.parse(
                      "${globalvar.serverip}/serve_layer_for_preview?v=${DateTime.now().millisecondsSinceEpoch}");
                });
                globalvar.doPostRender("/render",
                    globalvar.positivefotoresist.toString(), val.toString());
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

    // return ListView(
    //   children: [
    //     previewWindow,
    //     chooseLayer,
    //     //bottomSheet,
    //     controlSection,
    //     switchPhotoresist,
    //     //precisionSlider,
    //     clearuploadButton,
    //   ],
    // );
    // }

    return Container(
      constraints: BoxConstraints(
        minHeight: 500, //minimum height
        minWidth: 300, // minimum width

        maxHeight: MediaQuery.of(context).size.height,
        //maximum height set to 100% of vertical height

        maxWidth: MediaQuery.of(context).size.width,
        //maximum width set to 100% of width
      ),
      child: ListView(
        children: [
          previewWindow,
          controlSection,
          chooseLayer,
          //bottomSheet,
          switchPhotoresist,
          //precisionSlider,
          clearuploadButton,
        ],
      ),
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
