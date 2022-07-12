import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';

callGetAPI(String controllerName, HashMap hmap) async {
  String url = generateUrl(controllerName, hmap);

  SessionManager manager = SessionManager.getInstance();
  printToConsole("ddd: ${manager.getAuthToken()}");

  printToConsole("URL:" + url);
  var response = await http.get(
    url,
    headers: {"Authorization": manager.getAuthToken()},
  ).timeout(Duration(seconds: 60));

  // if (response.statusCode == 200) {
  printToConsole(response.body.toString());
  return response.body.toString();
  // } else {
  //   printToConsole(response.body.toString());
  //   return '{"Error":"An error has occure while calling api"}';
  // }
}

callPostAPI(String controllerName, params, {int timeOut = 60}) async {
  String url = generateUrl(controllerName, HashMap());
  printToConsole("URL:" + url);
  // final postParam = json.encode(params);
  SessionManager manager = SessionManager.getInstance();

  printToConsole("post parameters: " + params.toString());
  // printToConsole("header : " + manager.getAuthToken());
  try {
    var response = await http
        .post(
          url,
          headers: {"Authorization": manager.getAuthToken()},
          body: params,
        )
        .timeout(Duration(seconds: timeOut));

    printToConsole(response.body.toString());
    return response.body.toString();
  } on Exception catch (_) {
    return 'Something went wrong please try again';
  }

////  ResultInfo inf=loginPageState;
//  OnSuccess(response.body.toString());
}

callGetAPIDirect(String url) async {
  printToConsole("URL:" + url);

  var response = await http
      .get(
        url,
        // headers: {
        //
        // },
      )
      .timeout(Duration(seconds: 60));
  printToConsole(response.body);
  response.body;
}

callGetAPIDirectMap(String url) async {
  printToConsole("URL:" + url);

  var response = await http
      .get(
        url,
      )
      .timeout(Duration(seconds: 60));
  printToConsole(response.body);
  response.body;
}

String generateUrl(String controllerName, HashMap map) {
  if (map == null) {
    map = HashMap();
  }
  if (map.isEmpty) {
    return API_URL + controllerName;
  } else {
    String temp = "";
    map.forEach((key, value) {
      if (temp.isEmpty) {
        temp = "?";
        temp = temp + key + "=" + value.toString();
      } else {
        temp = temp + "&" + key + "=" + value.toString();
      }
    });

    return API_URL + controllerName + temp;
  }
}
