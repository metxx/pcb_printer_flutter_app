library baka_control.globals;

import 'package:http/http.dart' as http;
import 'dart:convert';

String server_ip = 'http://127.0.0.1:8000';
int scale = 1;
bool is_positive = false;
bool is_mirror = false;
String? selected_layer;
bool positive_fotoresist = false;

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
    Uri.parse(server_ip + path),
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

Future<http.Response> doPostRender(String path, String movex, String movey,
    String positive, String mirror, String filename) {
  return http.post(
    Uri.parse(server_ip + path),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'move_x': movex,
      'move_y': movey,
      'positive': positive,
      'mirror': mirror,
      'file_name': filename
    }),
  );
}

void doPostFile(String path, var file) async {
  http.MultipartRequest request =
      http.MultipartRequest("POST", Uri.parse(server_ip + path));

  http.MultipartFile multipartFile =
      await http.MultipartFile.fromPath('file', file);

  request.files.add(multipartFile);

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);
  print(response.body);
  // items = List<String>.from(jsonDecode(response.body));
  // print(items);

  //print(response.headers);
}

void doPost(var path) async {
  var url = Uri.parse(server_ip + path);
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
