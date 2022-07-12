import 'package:flutter/material.dart';
import 'package:jaagran/pages/splash/splash_screen.dart';

void main() async {
  // runApp(FilePickerDemo());
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

// GlobalKey Application = GlobalKey();
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // navigatorKey: Application.navKey, // GlobalKey()
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0x00ffAE84C9),
        accentColor: Color(0x00ff490A74),
        buttonColor: Color(0x00ffAE84C9),
        textSelectionColor: Color(0x00ff6E4586),
        hintColor: Color(0x00ffE9DDF3),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreenPage(),
      navigatorKey: navigatorKey,
      // home: MyHomePage(),
    );
  }
}

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Permission.camera.request();
//   await Permission.microphone.request();
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => new _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: InAppWebViewPage()
//     );
//   }
// }
//
// class InAppWebViewPage extends StatefulWidget {
//   @override
//   _InAppWebViewPageState createState() => new _InAppWebViewPageState();
// }
//
// class _InAppWebViewPageState extends State<InAppWebViewPage> {
//   InAppWebViewController _webViewController;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//             title: Text("InAppWebView")
//         ),
//         body: Container(
//             child: Column(children: <Widget>[
//               Expanded(
//                 child: Container(
//                   child: InAppWebView(
//                       initialUrl: "https://streamyard.com/wxcuam7j8q",
//                       initialOptions: InAppWebViewGroupOptions(
//                         crossPlatform: InAppWebViewOptions(
//                           mediaPlaybackRequiresUserGesture: false,
//                           debuggingEnabled: true,
//                         ),
//                       ),
//                       onWebViewCreated: (InAppWebViewController controller) {
//                         _webViewController = controller;
//                       },
//                       androidOnPermissionRequest: (InAppWebViewController controller, String origin, List<String> resources) async {
//                         return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
//                       }
//                   ),
//                 ),
//               ),
//             ]))
//     );
//   }
// }
