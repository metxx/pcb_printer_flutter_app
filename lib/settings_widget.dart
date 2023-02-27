import 'package:flutter/services.dart';

import 'global_variables.dart' as globalvar;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lan_scanner/lan_scanner.dart';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingsWidget();
  }
}

class _SettingsWidget extends State<SettingsWidget> {
  late TextEditingController _controller;

  final List<HostModel> _hosts = <HostModel>[];

  double progress = 0.0;

  late SnackBar snackBar;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget lanscaner = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            LinearProgressIndicator(value: progress),
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
    Widget serverIPTextField = TextField(
      controller: _controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Current server IP: ${globalvar.serverip}',
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
          globalvar.serverip =
              globalvar.serverhttp + value + globalvar.serverport;
        });
      },
    );

    return ListView(
      children: [serverIPTextField, lanscaner],
    );
  }
}

void doPostparam(var path, var params) async {
  var url = Uri.http(globalvar.serverip, '/api/control/' + path, params);
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

void doPost(var path) async {
  var url = Uri.http(globalvar.serverip, '/api/control/' + path);
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
