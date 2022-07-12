import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsAndConditionPage extends StatefulWidget {
  @override
  _TermsAndConditionPageState createState() => _TermsAndConditionPageState();
}

class _TermsAndConditionPageState extends State<TermsAndConditionPage> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    // WebView.platform = SurfaceAndroidWebView(
    // );
  }

  SizeConfig _sf;

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(

      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.only(right: _sf.scaleSize(65)),
          child: Image.asset(
            "assets/images/banner_logo.jpeg",
            fit: BoxFit.fitHeight,
          ),
        ),
      ),

      body: Container(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://swasthyasethu.in/tnc_mobile.html',
        ),
      ),
      bottomNavigationBar: Container(
        height: _sf.scaleSize(45),
        color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            getNavButton("Cancel", _sf.getCaviarDreams(), () {
              Navigator.of(context).pop(false);
            },
                padding: EdgeInsets.symmetric(
                    vertical: _sf.scaleSize(8), horizontal: _sf.scaleSize(24))),
            getNavButton("Accept", _sf.getCaviarDreams(), () {
              Navigator.of(context).pop(true);
            },
                padding: EdgeInsets.symmetric(
                    vertical: _sf.scaleSize(8), horizontal: _sf.scaleSize(24))),
          ],
        ),
      ),
    );
  }
}
