import 'dart:collection';
import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'dart:io' show Platform;
import 'package:package_info/package_info.dart';

import 'package:url_launcher/url_launcher.dart';

class VersionCheck {
  BuildContext context;

  VersionCheck(this.context) {
    try {
      _callVersionCheckAPI();
    } on Exception catch (e) {
      // TODO
    }
  }

  _callVersionCheckAPI() async {
    final result = await callGetAPI("app-version", HashMap());
    final response = json.decode(result.toString());
    if (response['status'] == 'success') {
      if (response['data']['force_update']) {
        String msg = response['data']['update_message'].toString().trim();
        if (Platform.isAndroid) {
          _callAndroidVersionCheck(
            msg,
            response['data']['android_version'].toString().trim(),
          );
        } else if (Platform.isIOS) {
          _callIOSVersionCheck(
            msg,
            response['data']['ios_version'].toString().trim(),
          );
        }
      }
    }
  }

  void _callAndroidVersionCheck(String msg, String androidVersion) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    printToConsole("_callAndroidVersionCheck $version");

    if (version == androidVersion) {
      _showDialog(msg,
          "https://play.google.com/store/apps/details?id=com.swasthya.sethu");
    }
  }

  void _callIOSVersionCheck(String msg, String iosVersion) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    printToConsole("_callIOSVersionCheck $version");

    if (version != iosVersion) {
      _showDialog(
          msg, "https://apps.apple.com/us/app/swasthyasethu/id1553684115");
    }
  }

  void _showDialog(String msg, String url) {
    showCustomWarningDialog(context, msg, isCancelable: false, okCall: () {
      printToConsole("update call hit");
      _launchURL(url);
    }, okText: 'Update', showCancel: false, title: 'New Update Available!');
  }

  _launchURL(String url) async {
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
}
