library baka_control.globals;

import 'package:http/http.dart' as http;
import 'dart:convert';

String serverhttp = 'http://';
String serverport = ':8000';
String inputserverip = '192.168.137.3';
String serverip = serverhttp + inputserverip + serverport;
int scale = 1;
bool ispositive = false;
bool ismirror = true;
String? selectedlayer;
bool positivefotoresist = false;
String exptime = '0';

Future<http.Response> doPostJason(
    String path,
    String movex,
    String movey,
    String positive,
    String mirror,
    String exptime,
    String pwm,
    String filename) {
  return http.post(
    Uri.parse(serverip + path),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'move_x': movex,
      'move_y': movey,
      'positive': positive,
      'mirror': mirror,
      'exp_time': exptime,
      'pwm': pwm,
      'file_name': filename
    }),
  );
}

Future<http.Response> doPostRender(
    String path, String positive, String filename) {
  return http.post(
    Uri.parse(serverip + path),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{'positive': positive, 'file_name': filename}),
  );
}

void doPostFile(String path, var file) async {
  http.MultipartRequest request =
      http.MultipartRequest("POST", Uri.parse(serverip + path));

  http.MultipartFile multipartFile =
      await http.MultipartFile.fromPath('file', file);

  request.files.add(multipartFile);

  // var streamedResponse = await request.send();
  // var response = await http.Response.fromStream(streamedResponse);
  //print(response.body);
  // items = List<String>.from(jsonDecode(response.body));
  // print(items);

  //print(response.headers);
}

void doPost(var path) async {
  var url = Uri.parse(serverip + path);
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
