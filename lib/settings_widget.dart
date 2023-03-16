import 'global_variables.dart' as globalvar;
import 'package:flutter/material.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingsWidget();
  }
}

class _SettingsWidget extends State<SettingsWidget> {
  late TextEditingController _controllerIP;
  late TextEditingController _controllerScale;

  Duration _duration = Duration(seconds: globalvar.box.read('exptime'));

  final List<HostModel> _hosts = <HostModel>[];

  double progress = 0.0;

  bool developer = false;

  //late SnackBar snackBar;

  final snackBar = const SnackBar(content: Text('Layers not Locked!'));

  @override
  void initState() {
    super.initState();
    _controllerIP = TextEditingController();
    _controllerScale = TextEditingController();
  }

  @override
  void dispose() {
    _controllerIP.dispose();
    _controllerScale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget pickTime = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        margin: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.all(5),
                child: DurationPicker(
                  baseUnit: BaseUnit.second,
                  duration: _duration,
                  onChange: (val) {
                    setState(() => _duration = val);
                    // globalvar.exptime = _duration.inSeconds;
                    globalvar.box.write('exptime', _duration.inSeconds);
                  },
                  snapToMins: 5.0,
                )),
          ],
        ));

    Widget pwmSlider = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        margin: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.fromLTRB(15, 5, 25, 5),
                child: const Icon(Icons.lightbulb)),
            Container(
                margin: const EdgeInsets.all(5), child: const Text("LED PWM")),
            Expanded(
                child: Container(
              margin: const EdgeInsets.all(5),
              child: Slider(
                value: globalvar.currentSliderValue,
                max: 100,
                divisions: 20,
                label: globalvar.currentSliderValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    globalvar.box.write('pwm', value);
                    globalvar.currentSliderValue = value;
                  });
                },
              ),
            )),
          ],
        ));

    Widget switchPhotoresist = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        margin: const EdgeInsets.all(5),
        child: SwitchListTile(
          title: const Text('Positive fotoresist'),
          value: globalvar.box.read('positive') ?? false,
          onChanged: (bool value) {
            setState(() {
              globalvar.box.write('positive', value);
            });
          },
          secondary: const Icon(Icons.invert_colors),
        ));

    Widget printButton = Card(
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
                      'Print TopLayer',
                      textScaleFactor: 1.5,
                    ),
                    onPressed: () {
                      !globalvar.locked
                          ? ScaffoldMessenger.of(context).showSnackBar(snackBar)
                          : globalvar.doPostJason(
                              "/print",
                              (globalvar.movex * 6.4).toString(),
                              (globalvar.movey * 6.4).toString(),
                              globalvar.box.read('positive') ? "True" : "False",
                              globalvar.ismirror.toString(),
                              globalvar.exptime.toString(),
                              globalvar.currentSliderValue.toString(),
                              globalvar.selectedBottomlayer.toString(),
                              "top");
                      print('upload pressed');
                    })),
            Container(
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                    child: const Text(
                      'Print BottomLayer',
                      textScaleFactor: 1.5,
                    ),
                    onPressed: () {
                      !globalvar.locked
                          ? ScaffoldMessenger.of(context).showSnackBar(snackBar)
                          : globalvar.doPostJason(
                              "/print",
                              (globalvar.movex * 6.45).toString(),
                              (globalvar.movey * 6.45).toString(),
                              globalvar.positivefotoresist ? "True" : "False",
                              globalvar.ismirror.toString(),
                              globalvar.exptime.toString(),
                              globalvar.currentSliderValue.toString(),
                              globalvar.selectedToplayer.toString(),
                              "bottom");
                      // print('upload pressed');
                    })),
          ],
        ));

    Widget switchDeveloperoptions = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        margin: const EdgeInsets.all(5),
        child: SwitchListTile(
          title: const Text('Developer options'),
          value: developer,
          onChanged: (bool value) {
            setState(() {
              developer = value;
            });
          },
          secondary: const Icon(Icons.developer_board),
        ));

    Widget serverIPTextField = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        margin: const EdgeInsets.all(5),
        child: Container(
            margin: const EdgeInsets.all(5),
            child: TextField(
              controller: _controllerIP,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                // labelText: 'Current server IP: ${globalvar.serverip}',
                labelText:
                    'Current server IP: ${globalvar.box.read('ip') ?? "n/a"}',
              ),
              onSubmitted: (String value) async {
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Server IP adress'),
                      content: Text('You updated server IP adress to "$value"'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
                setState(() {
                  globalvar.box.write('ip', value);
                  globalvar.serverip = globalvar.serverhttp +
                      globalvar.box.read('ip') +
                      globalvar.serverport;
                });
              },
            )));

    Widget DisplayScaleTextField = Card(
        shadowColor: Theme.of(context).shadowColor,
        elevation: 4,
        //margin: const EdgeInsets.all(5),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              margin: const EdgeInsets.fromLTRB(15, 5, 25, 5),
              child: const Icon(Icons.zoom_in)),
          Container(
              margin: const EdgeInsets.all(5),
              child: const Text("Display scale")),
          Expanded(
              child: Container(
                  margin: const EdgeInsets.fromLTRB(15, 5, 5, 5),
                  child: TextField(
                    controller: _controllerScale,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      // labelText: 'Current server IP: ${globalvar.serverip}',
                      labelText:
                          'Current display scale value: ${globalvar.box.read('scale') ?? "n/a"}',
                    ),
                    onSubmitted: (String value) async {
                      await showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Display scale value'),
                            content: Text(
                                'You updated display scale value to "$value"'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                      setState(() {
                        globalvar.box.write('scale', value);
                        globalvar.scale = globalvar.box.read('scale');
                      });
                    },
                  )))
        ]));

    Widget lanscaner = Card(
      shadowColor: Theme.of(context).shadowColor,
      elevation: 4,
      margin: const EdgeInsets.all(5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(5),
              child: const Text("Lan scanner"),
            ),
            Container(
                margin: const EdgeInsets.all(5),
                child: LinearProgressIndicator(value: progress)),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  progress = 0.0;
                  _hosts.clear();
                });

                final scanner = LanScanner(debugLogging: true);
                final stream = scanner.icmpScan(
                  '192.168.0',
                  scanThreads: 20,
                  progressCallback: (newProgress) {
                    setState(() {
                      progress = newProgress;
                    });

                    print('progress: $progress');
                  },
                );

                stream.listen((HostModel host) {
                  setState(() {
                    _hosts.add(host);
                  });
                });
              },
              child: const Text('Scan'),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _hosts.length,
              itemBuilder: (context, index) {
                final host = _hosts[index];

                return Card(
                  child: ListTile(
                    title: Text(host.ip),
                    onTap: () => setState(
                      () {
                        globalvar.serverip = globalvar.serverhttp +
                            host.ip +
                            globalvar.serverport;
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(5),
      children: [
        pickTime,
        pwmSlider,
        switchPhotoresist,
        printButton,
        switchDeveloperoptions,
        if (developer) serverIPTextField,
        if (developer) DisplayScaleTextField,
        if (developer) lanscaner
      ],
    );
  }
}

Future<void> scanNetwork() async {
  await (NetworkInfo().getWifiIP()).then(
    (ip) async {
      final String subnet = ip!.substring(0, ip.lastIndexOf('.'));
      const port = 22;
      for (var i = 0; i < 256; i++) {
        String ip = '$subnet.$i';
        await Socket.connect(ip, port, timeout: Duration(milliseconds: 50))
            .then((socket) async {
          await InternetAddress(socket.address.address).reverse().then((value) {
            print(value.host);
            print(socket.address.address);
          }).catchError((error) {
            print(socket.address.address);
            print('Error: $error');
          });
          socket.destroy();
        }).catchError((error) => null);
      }
    },
  );
  print('Done');
}
