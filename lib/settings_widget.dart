import 'global_variables.dart' as globalvar;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SettingsWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsWidget();
  }
}

class _SettingsWidget extends State<SettingsWidget> {

bool _fullcreen = false;
late TextEditingController _controller;

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

    Widget switchFullscreen = SwitchListTile(
              title: const Text('Fullscreen mode'),
              value: _fullcreen,
              onChanged: (bool value) {
                setState(() {
                  _fullcreen = value;
                });
                doPostparam('fullscreen', {'enable':_fullcreen.toString()});
              },
              secondary: const Icon(Icons.fullscreen_rounded),
            );

    Widget serverIPTextField = TextField(
          controller: _controller,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Current server IP: ' + globalvar.server_ip,
            ),
          onSubmitted: (String value) async {
            await showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Server IP adress'),
                  content: Text(
                      'You updated server IP adress to "$value"'),
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
            globalvar.server_ip = value;
          },
        );

    return ListView(
        children: [
          switchFullscreen,
          serverIPTextField
        ],
      );
  }
}

void doPostparam(var path, var params) async {
  var url = Uri.http(globalvar.server_ip, '/api/control/' + path, params);
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
  var url = Uri.http(globalvar.server_ip, '/api/control/' + path);
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