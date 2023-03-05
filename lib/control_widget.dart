import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';

import 'global_variables.dart' as globalvar;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toggle_switch/toggle_switch.dart';
import 'package:invert_colors/invert_colors.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class ControlWidget extends StatefulWidget {
  const ControlWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ControlWidget();
  }
}

class _ControlWidget extends State<ControlWidget> {
  late TextEditingController _controller;

  var picked;

  //String? value;
  bool loading = true;
  List<ApiResponse> leaveRequest = [];

  Uri imageUrl_top = Uri.parse(
      "${globalvar.serverip}/serve_layer_for_preview_top?v=${DateTime.now().millisecondsSinceEpoch}");

  Uri imageUrl_bottom = Uri.parse(
      "${globalvar.serverip}/serve_layer_for_preview_bottom?v=${DateTime.now().millisecondsSinceEpoch}");

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
    _controller = TextEditingController();
    get();
    super.initState();
  }

  void _pickFile() async {
    setState(() {
      loading = true;
      globalvar.selectedToplayer = null;
      globalvar.selectedBottomlayer = null;
    });
    picked = await FilePicker.platform
        .pickFiles(allowMultiple: false, withData: true);

    if (picked != null) {
      var windowsPath = picked.files.first.path;
      print(windowsPath);
      globalvar.doPostFile('/uploadfile', windowsPath);
      setState(() {
        loading = false;
      });
      initState();
      //get();
    }
  }

  @override
  Widget build(BuildContext musimetoopravit) {
    Widget imagetop = globalvar.positivefotoresist
        ? InvertColors(
            child: CachedNetworkImage(
                imageUrl: imageUrl_top.toString(),
                placeholder: (context, url) =>
                    const CircularProgressIndicator()))
        : CachedNetworkImage(
            imageUrl: imageUrl_top.toString(),
            placeholder: (context, url) => const CircularProgressIndicator());

    Widget imagebottom = globalvar.positivefotoresist
        ? InvertColors(
            child: CachedNetworkImage(
                imageUrl: imageUrl_bottom.toString(),
                placeholder: (context, url) =>
                    const CircularProgressIndicator()))
        : CachedNetworkImage(
            imageUrl: imageUrl_bottom.toString(),
            placeholder: (context, url) => const CircularProgressIndicator());

    Widget controlSection = Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  iconSize: 50,
                  color: Colors.brown,
                  tooltip: globalvar.locked ? 'Motif is locked' : null,
                  onPressed: () {
                    setState(() {
                      globalvar.locked
                          ? null
                          : globalvar.movey = globalvar.movey - 10;
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
                  tooltip: globalvar.locked ? 'Motif is locked' : null,
                  onPressed: () {
                    setState(() {
                      globalvar.locked
                          ? null
                          : globalvar.movex = globalvar.movex - 10;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: 50,
                  color: Colors.brown,
                  tooltip: globalvar.locked ? 'Motif is locked' : null,
                  onPressed: () {
                    setState(() {
                      globalvar.locked
                          ? null
                          : globalvar.movex = globalvar.movex + 10;
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
                  tooltip: globalvar.locked ? 'Motif is locked' : null,
                  onPressed: () {
                    setState(() {
                      globalvar.locked
                          ? null
                          : globalvar.movey = globalvar.movey + 10;
                    });
                  },
                ),
              ]),
        ],
      ),
    );

    @override
    Widget previewWindowTop = Card(
      shadowColor: Theme.of(context).shadowColor,
      elevation: 4,
      margin: const EdgeInsets.all(5),
      child: Stack(
        children: [
          Center(
              child: ClipRect(
                  child: Container(
            constraints: const BoxConstraints(minWidth: 700, maxWidth: 1920),
            color: globalvar.positivefotoresist ? Colors.white : Colors.black,
            alignment: Alignment.center,
            child: Transform.translate(
                offset: Offset(globalvar.movex, globalvar.movey),
                child: globalvar.selectedToplayer != null
                    ? imagetop
                    : Image.asset('images/calibration.png')),
          ))),
          Container(
            alignment: Alignment.topCenter,
            child: IconButton(
              isSelected: globalvar.locked,
              icon: globalvar.locked
                  ? const Icon(Icons.lock)
                  : const Icon(Icons.lock_open),
              iconSize: 50,
              color: globalvar.locked ? Colors.amber : Colors.amber,
              onPressed: () {
                setState(() {
                  globalvar.locked = !globalvar.locked;
                });
              },
            ),
          ),
        ],
      ),
    );

    @override
    Widget previewWindowBottom = Card(
      shadowColor: Theme.of(context).shadowColor,
      elevation: 4,
      margin: const EdgeInsets.all(5),
      child: Stack(
        children: [
          Center(
              child: ClipRect(
                  child: Container(
            constraints: const BoxConstraints(minWidth: 700, maxWidth: 1920),
            color: globalvar.positivefotoresist ? Colors.white : Colors.black,
            alignment: Alignment.center,
            child: Transform.translate(
                offset: Offset(globalvar.movex, globalvar.movey),
                child: globalvar.selectedBottomlayer != null
                    ? imagebottom
                    : Image.asset('images/calibration.png')),
          ))),
          Container(
            alignment: Alignment.topCenter,
            child: IconButton(
              isSelected: globalvar.locked,
              icon: globalvar.locked
                  ? const Icon(Icons.lock)
                  : const Icon(Icons.lock_open),
              iconSize: 50,
              color: globalvar.locked ? Colors.amber : Colors.amber,
              onPressed: () {
                setState(() {
                  globalvar.locked = !globalvar.locked;
                });
              },
            ),
          ),
        ],
      ),
    );

    @override
    Widget chooseTopLayer = Card(
      shadowColor: Theme.of(context).shadowColor,
      elevation: 4,
      margin: const EdgeInsets.all(5),
      child: Container(
          margin: const EdgeInsets.all(10),
          child: loading
              ? const SizedBox(
                  height: 25.0,
                  width: 1,
                  child: LinearProgressIndicator(),
                )
              : DropdownButton<String>(
                  icon: const Icon(Icons.arrow_drop_down_sharp),
                  isExpanded: true,
                  alignment: AlignmentDirectional.center,
                  hint: globalvar.locked
                      ? const Text('Motif is locked')
                      : const Text('Select layer'),
                  value: globalvar.selectedToplayer,
                  items: leaveRequest.map((item) {
                    return DropdownMenuItem(
                      enabled: !globalvar.locked,
                      alignment: AlignmentDirectional.centerStart,
                      value: item.value,
                      child: Text(item.value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      globalvar.locked
                          ? null
                          : globalvar.selectedToplayer = val;
                      globalvar.locked
                          ? null
                          : imageUrl_top = Uri.parse(
                              "${globalvar.serverip}/serve_layer_for_preview_top?v=${DateTime.now().millisecondsSinceEpoch}");
                    });
                    globalvar.doPostRender("/render", val.toString());
                  },
                )),
    );

    @override
    Widget chooseBottomLayer = Card(
      shadowColor: Theme.of(context).shadowColor,
      elevation: 4,
      margin: const EdgeInsets.all(5),
      child: Container(
          margin: const EdgeInsets.all(10),
          child: loading
              ? const SizedBox(
                  height: 25.0,
                  width: 1,
                  child: LinearProgressIndicator(),
                )
              : DropdownButton<String>(
                  icon: const Icon(Icons.arrow_drop_down_sharp),
                  isExpanded: true,
                  alignment: AlignmentDirectional.center,
                  hint: globalvar.locked
                      ? const Text('Motif is locked')
                      : const Text('Select layer'),
                  value: globalvar.selectedBottomlayer,
                  items: leaveRequest.map((item) {
                    return DropdownMenuItem(
                      enabled: !globalvar.locked,
                      alignment: AlignmentDirectional.centerStart,
                      value: item.value,
                      child: Text(item.value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      globalvar.locked
                          ? null
                          : globalvar.selectedBottomlayer = val;
                      globalvar.locked
                          ? null
                          : imageUrl_bottom = Uri.parse(
                              "${globalvar.serverip}/serve_layer_for_preview_bottom?v=${DateTime.now().millisecondsSinceEpoch}");
                    });
                    globalvar.doPostRender("/render", val.toString());
                  },
                )),
    );

    Widget uploadButton = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        margin: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                    child: const Text(
                      'Upload Gerber',
                      textScaleFactor: 1.5,
                    ),
                    onPressed: () {
                      _pickFile();
                      //globalvar.doPostFile('/uploadfile', null);
                    })),
          ],
        ));

    Widget switchDoubleside = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        margin: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: ToggleSwitch(
                minWidth: 700.0,
                cornerRadius: 20.0,
                activeBgColors: const [
                  [Colors.orange],
                  [Colors.orange]
                ],
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey,
                inactiveFgColor: Colors.white,
                initialLabelIndex: globalvar.topbottom,
                totalSwitches: 2,
                labels: const ['Top', 'Bottom'],
                radiusStyle: true,
                onToggle: (index) {
                  setState(() {
                    globalvar.topbottom = index!;
                    imageUrl_top = Uri.parse(
                        "${globalvar.serverip}/serve_layer_for_preview_top?v=${DateTime.now().millisecondsSinceEpoch}");
                    imageUrl_bottom = Uri.parse(
                        "${globalvar.serverip}/serve_layer_for_preview_bottom?v=${DateTime.now().millisecondsSinceEpoch}");
                  });
                },
              ),
            ),
          ],
        ));

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
        padding: const EdgeInsets.all(5),
        children: [
          globalvar.topbottom == 1 ? previewWindowTop : previewWindowBottom,
          controlSection,
          switchDoubleside,
          globalvar.topbottom == 1 ? chooseTopLayer : chooseBottomLayer,
          uploadButton,
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
