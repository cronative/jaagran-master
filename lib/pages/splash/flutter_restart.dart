import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaagran/pages/splash/splash_screen.dart';
import 'package:jaagran/utils/utils.dart';

class FlutterRestart {
  static const MethodChannel _channel = const MethodChannel('flutter_restart');

//  static Future<String> get platformVersion async {
//    final String version = await _channel.invokeMethod('getPlatformVersion');
//    return version;
//  }
  static restartApp(BuildContext context,{bool isSplash = false}) async {
    while (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    Navigator.of(context).pop();

    navigateToPageWithoutScaffold(context, SplashScreenPage());
  }
}
