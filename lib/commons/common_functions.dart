import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/profile/model/profile_model.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:url_launcher/url_launcher.dart';

Future<ProfileModel> getProfileById(String userId) async {
  HashMap params = HashMap();
  params['user_id'] = userId;
  final result = await callPostAPI("profile", params);
  final response = json.decode(result.toString());
  if (response['status'] == 'success') {
    ProfileModel model = ProfileModel.fromJson(response['data']);
    model.id = userId;
    return model;
  } else {
    return null;
  }
}

String getImagePath(String dp) {
  printToConsole("getImagePath call");

  SessionManager manager = SessionManager.getInstance();
  if (dp.isEmpty || dp == "null") return "";
  String imagePath = Server_URL + manager.getDpPath() + dp;
  printToConsole("Image path : $imagePath \n dp : $dp");
  return imagePath;
}

String getEventsImagePath(String src) {
  printToConsole("getImagePath call");

  SessionManager manager = SessionManager.getInstance();
  if (src.isEmpty || src == "null") return "";
  String imagePath = Server_URL + manager.getEventPath() + src;
  printToConsole("Image path : $imagePath \n dp : $src");
  return imagePath;
}

String getFormattedDateForAPI(DateTime dateTime) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  return dateFormat.format(dateTime);
}

get12HrTime(BuildContext context, String session_time) {
  if (session_time == null) return '';
  if (session_time == 'null' || session_time.isEmpty) return '';
  List<String> time = session_time.split(":");
  int hr = int.parse(time[0]);
  int min = int.parse(time[1]);
  TimeOfDay timeOfDay = TimeOfDay(hour: hr, minute: min);
  return timeOfDay.format(context);
}

String getShortDesc40Char(String description) {
  List<String> words = description.split(" ");
  String lineToShow = '';
  int i = 0;
  for (; i < words.length; i++) {
    if (i == 40) break;
    lineToShow += " " + words[i];
  }
  if (i == words.length) {
    return lineToShow;
  }
  return lineToShow + "...";
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: true,
      forceWebView: true,
      enableJavaScript: true,
    );
  } else {
    throw 'Could not launch $url';
  }
}
