import 'dart:collection';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:jaagran/commons/notification_controller/notification_controller.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/chat/create_chats_page.dart';
import 'package:jaagran/pages/profile/profile_page.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';

import '../main.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final NotificationController _notificationController =
      Get.put(NotificationController());
  BuildContext context;

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) => CupertinoAlertDialog(
    //     title: Text(title),
    //     content: Text(body),
    //     actions: [
    //       CupertinoDialogAction(
    //         isDefaultAction: true,
    //         child: Text('Ok'),
    //         onPressed: () async {
    //           // Navigator.of(context, rootNavigator: true).pop();
    //           // await Navigator.push(
    //           //   context,
    //           //   MaterialPageRoute(
    //           //     builder: (context) => SecondScreen(payload),
    //           //   ),
    //           // );
    //         },
    //       )
    //     ],
    //   ),
    // );
  }

  Future onSelectNotification(String payload) async {
    printToConsole('onSelectNotification call $payload');
    // navigateToPageWithoutScaffold(context, CreateChatsPage());
    // showDialog(
    //   context: context,
    //   builder: (_) {
    //     return new AlertDialog(
    //       title: Text("PayLoad"),
    //       content: Text("Payload : $payload"),
    //     );
    //   },
    // );
    // navigatorKey.currentState.push(
    //   MaterialPageRoute(
    //     builder: (BuildContext context) {
    //       return CreateChatsPage();
    //     },
    //   ),
    // );
  }

  void showNotification(String title, String body, String message) async {
    await _demoNotification(title, body,message);
  }

  Future<void> _demoNotification(String title, String body, String message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'channel_ID', 'channel name', 'channel description',
        importance: Importance.max,
        playSound: true,
        showProgress: true,
        priority: Priority.high,
        ticker: '');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: message);
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future initialise(BuildContext context) async {
    this.context = context;
//initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (!_notificationController.isNewNotification.isTrue) {
          _notificationController.changeValue();
        }
        // showNotification(
        //     message['notification']['title'], message['notification']['body'],message.toString());
        print('onMessage: $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (!_notificationController.isNewNotification.isTrue) {
          _notificationController.changeValue();
        }
        print('onLaunch: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        if (!_notificationController.isNewNotification.isTrue) {
          _notificationController.changeValue();
        }
        print('onResume: $message');
      },
    );
  }


}

registerDeviceToFCM() async {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  String tokan = await _fcm.getToken();
  SessionManager manager = SessionManager.getInstance();
  _fcm.subscribeToTopic(
      manager.getIsExpert() ? "JaagranExperts" : "JaagranUsers");
  HashMap params = HashMap();
  params["device_token"] = tokan;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isIOS) {
    // IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    // params["device_version"] = iosInfo.utsname.version;
    // params["device_platform"] = "ios";
    // params["device_model"] = iosInfo.utsname.machine;
    var iosInfo = await DeviceInfoPlugin().iosInfo;
    // var systemName = iosInfo.systemName;
    params["device_version"] = iosInfo.systemVersion;
    params["device_platform"] = "ios";
    params["device_model"]  = iosInfo.model;
  } else {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    params["device_version"] = '${androidInfo.version.sdkInt}';
    params["device_platform"] = "android";
    params["device_model"] = androidInfo.model;
  }

  final result = await callPostAPI("add-user-device", params);
  printToConsole(result.toString());
}
