library baka_control.globals;

//import 'dart:ffi';
//import 'dart:html';

import 'dart:ffi';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';

Duration _duration = const Duration(seconds: 0);

String serverhttp = 'http://';
String serverport = ':8000';
String inputserverip = '192.168.137.3';
String serverip = serverhttp + inputserverip + serverport;
int scale = 1;
bool ispositive = false;
bool ismirror = true;
String? selectedToplayer;
String? selectedBottomlayer;
bool positivefotoresist = false;
int exptime = 5;
// List<bool> isSelected = [false];
bool locked = false;
int topbottom = 0;
double currentSliderValue = 20;

double movex = 0;
double movey = 0;

Future<http.Response> doPostJason(
    String path,
    String movex,
    String movey,
    String positive,
    String mirror,
    String exptime,
    String pwm,
    String filename,
    String toporbottom) {
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
      'file_name': filename,
      'topbottom': toporbottom
    }),
  );
}

Future<http.Response> doPostRender(String path, String filename) {
  return http.post(
    Uri.parse(serverip + path),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'file_name': filename,
      'topbottom': topbottom == 1 ? "top" : "bottom",
    }),
  );
}

// void doPostFile(String path, var file) async {
//   http.MultipartRequest request =
//       http.MultipartRequest("POST", Uri.parse(serverip + path));

//   http.MultipartFile multipartFile =
//       await http.MultipartFile.fromPath('file', file);

//   request.files.add(multipartFile);

//   // var streamedResponse = await request.send();
//   // var response = await http.Response.fromStream(streamedResponse);
//   //print(response.body);
//   // items = List<String>.from(jsonDecode(response.body));
//   // print(items);

//   //print(response.headers);
// }

void doPostFile(String path, String file) async {
  var request = http.MultipartRequest('POST', Uri.parse(serverip + path));
  request.files.add(await http.MultipartFile.fromPath('file', file));
  var res = await request.send();
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
