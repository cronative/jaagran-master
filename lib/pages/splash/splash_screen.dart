import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/save_profile_info.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/model/login_model.dart';
import 'package:jaagran/pages/landing/landing_page.dart';
import 'package:jaagran/pages/login/login/login_page.dart';
import 'package:jaagran/pages/splash/app_settings.dart';

import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';

import 'package:get_storage/get_storage.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    printToConsole("ddd initCall");
    // _checkLogin();
    Future.delayed(const Duration(seconds: 2), () {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        printToConsole("ddd PushNotificationService().initialise(context)");
        // PushNotificationService().initialise(context);
        _checkLogin();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig sf = SizeConfig.getInstance(context);
    // return Container(
    //     color: Colors.white,
    //     child: Image.asset("assets/images/splash_screen.jpg"));
    //
    // return Scaffold(
    //   body: Container(
    //     color: Colors.white,
    //     child: Column(
    //       children: [
    //         Flexible(
    //           child: Image.asset(
    //             "assets/images/splash_screen.jpg",
    //             fit: BoxFit.fitWidth,
    //           ),
    //           flex: 9,
    //         ),
    //         Flexible(
    //           child: Center(
    //             child: CircularProgressIndicator(),
    //           ),
    //           flex: 2,
    //         ),
    //       ],
    //     ),
    //   ),
    // );
//
//     return SplashScreen(
//       seconds: 360,
//       routeName: "/",
//       navigateAfterSeconds: LoginPage(),
//       loadingText: Text(
//         'Loading please wait...\n\nV1.0',
//         textAlign: TextAlign.center,
//         style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: sf.scaleSize(13),
//             color: Colors.indigo),
//       ),
//       title: Text(
//         "Welcome to \n" + "Swasthyasethu",
//         textAlign: TextAlign.center,
//         style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: sf.scaleSize(20),
//             color: Colors.indigo),
//       ),
//       image: Image.asset(
//         'assets/images/app_logo.png',
//         width: sf.scaleSize(150),
//         height: sf.scaleSize(150),
//       ),
// //      gradientBackground: AppColors.color2,
//       backgroundColor: Colors.white,
//       styleTextUnderTheLoader: TextStyle(),
//       photoSize: sf.scaleSize(100),
//       loaderColor: Theme.of(context).accentColor,
//     );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/app_logo.jpeg',
                    width: sf.scaleSize(150),
                    height: sf.scaleSize(150),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "Welcome to \n" + "SwasthyaSethu",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: sf.scaleSize(20),
                        color: Colors.indigo),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        Theme.of(context).accentColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                  ),
                  Text(
                    'Loading please wait...\n\nV1.1',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: sf.scaleSize(13),
                        color: Colors.indigo),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkLogin() async {
    await _callSettingsApi();
    SessionManager manager = SessionManager.getInstance();

    printToConsole("ddd SessionManager.getInstance()");

    if (manager.getIsUserLogin()) {
      printToConsole("ddd manager.getIsUserLogin()");
      _callLogIn(manager.getUserEmail(), manager.getUserPassword());
    } else {
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop();
      printToConsole("ddd navigateToPageWithoutScaffold");
      navigateToPageWithoutScaffold(context, LoginPage(), isBottomTop: true);
    }
  }

  Future<void> _callLogIn(String email, String pass) async {
    HashMap params = HashMap();
    params["email"] = email;
    params["password"] = pass;
    final response = await callPostAPI("login", params);
    if (response.toString() == 'Something went wrong please try again') {
      showErrorAlertDialog(context, "Please check your internet connection",
          isCancelable: false, callback: () {
        // FlutterRestart.restartApp(context,isSplash : true);
        // navigateToPageWithoutScaffold(context, LoginPage());
      });
    } else {
      final result = json.decode(response.toString());
      LoginModel model = LoginModel.fromJson(result);
      if (model.status.toLowerCase() == "success") {
        SessionManager manager = SessionManager.getInstance();
        manager.saveUserData(email, pass, model.data);
        Navigator.of(context).pop();
        // navigateToPageWithoutScaffold(context, LandingPage());
        SaveProfileInfo(model.data.id);
        Navigator.of(context).push(
          MaterialPageRoute(
            settings: RouteSettings(name: "/landing"),
            builder: (context) => LandingPage(),
          ),
        );
      } else {
        showErrorAlertDialog(context, model.message, isCancelable: false,
            callback: () {
          Navigator.of(context).pop();
          navigateToPageWithoutScaffold(context, LoginPage());
        });
      }
    }
  }

  Future _callSettingsApi() async {
    try {
      await GetStorage.init();

      printToConsole("ddd _callSettingsApi");

      final response = await callGetAPI("app-settings", HashMap());
      printToConsole("ddd _callSettingsApi response");

      final result = json.decode(response.toString());
      AppSettings settings = AppSettings.fromJson(result['data'][0]);
      SessionManager manager = SessionManager.getInstance();
      manager.putDpPath(settings.dp_storage_path);
      manager.putAudioPath(Server_URL + settings.audio_storage_path);
      manager.putVideoPath(Server_URL + settings.video_storage_path);
      manager.putEBookPath(Server_URL + settings.ebook_storage_path);
      manager.putFeedbackCategory(settings.feedback_category);
      manager.putVCAppId(settings.agora_appid);

      manager.putEventPath(settings.events_storage_path);
      manager.putAddsPath(settings.adverts_storage_path);
      AGORA_APP_ID = settings.agora_appid;

      manager.putRazorPayKey(settings.razorpay_key);
      return false;
    } on Exception catch (e) {
      printToConsole("ddd _callSettingsApi Exception ${e.toString()}");

      return false;
    }
  }
}
