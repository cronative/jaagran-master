import 'dart:collection';
import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/save_profile_info.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/model/login_model.dart';
import 'package:jaagran/pages/landing/landing_page.dart';
import 'package:jaagran/pages/login/register/register_as_slection_page.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../forgot/password/forgot_password.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  SizeConfig _sf;
  TextEditingController _userName = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _isApiCall = false;

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      // appBar: AppBar(
      //   title: Container(
      //     padding: EdgeInsets.only(left: 24),
      //     height: _sf.scaleSize(36),
      //     child: Image.asset(
      //       "assets/images/app_banner_dark.png",
      //       fit: BoxFit.fitHeight,
      //     ),
      //   ),
      // ),
      backgroundColor: Theme.of(context).buttonColor,
      resizeToAvoidBottomInset: false,
      body: ModalProgressHUD(
        inAsyncCall: _isApiCall,
        child: Container(
          child: _getLoginInputs(),
          padding: EdgeInsets.all(_sf.scaleSize(16)),
        ),
        // child: Column(
        //   children: [
        //     Expanded(
        //       child: Container(
        //         child: _getLoginInputs(),
        //         padding: EdgeInsets.all(_sf.scaleSize(16)),
        //       ),
        //       flex: 12,
        //     ),
        //     Expanded(
        //       child: Align(
        //         alignment: Alignment.bottomCenter,
        //         child: InkWell(
        //           onTap: () {
        //             registerCall();
        //           },
        //           child: Container(
        //             color: Theme.of(context).primaryColor,
        //             height: _sf.scaleSize(50),
        //             child: Center(
        //               child: Text(
        //                 "New User ? Sign Up !",
        //                 style: _sf.getLargeStyle(
        //                     color: Theme.of(context).accentColor),
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //       flex: 2,
        //     ),
        //   ],
        // ),
      ),
    );
  }

  Widget _getLoginInputs() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: _sf.scaleSize(32)),
        Image.asset(
          "assets/images/app_logo.jpeg",
          width: _sf.scaleSize(120),
          height: _sf.scaleSize(120),
        ),
        // SizedBox(height: _sf.scaleSize(16)),
        // Text(
        //   "Sign in with email",
        //   style: _sf.getLargeStyle(color: Colors.white),
        // ),
        SizedBox(height: _sf.scaleSize(32)),
        TextField(
          controller: _userName,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.emailAddress,
          style: _sf.getMediumStyle(),
          decoration: InputDecoration(
            hintText: 'Email ID',
            filled: true,
            fillColor: Colors.white,
            hintStyle: _sf.getMediumStyle(color: Theme.of(context).accentColor),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            contentPadding: EdgeInsets.all(20),
          ),
        ),
        SizedBox(height: _sf.scaleSize(16)),
        TextField(
          controller: _password,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          style: _sf.getMediumStyle(),
          decoration: InputDecoration(
            hintText: 'Password',
            hintStyle: _sf.getMediumStyle(color: Theme.of(context).accentColor),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            contentPadding: EdgeInsets.all(20),
          ),
        ),
        SizedBox(height: _sf.scaleSize(24)),
        SizedBox(
          width: double.infinity,
          child: RaisedButton(
            onPressed: () {
              String email = _userName.text.toString().trim();
              String pass = _password.text.toString().trim();
              if (email.isEmpty) {
                showErrorAlertDialog(context, "Email Can Not Left Black.");
                return;
              }
              if (pass.isEmpty) {
                showErrorAlertDialog(context, "Password Can Not Left Black.");
                return;
              }
              if (!EmailValidator.validate(email)) {
                showErrorAlertDialog(context, "Invalid Email");
                return;
              }
              FocusScope.of(context).unfocus();
              _callLoginAPI(email, pass);
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(
              "Login",
              style: _sf.getMediumStyle(color: Colors.white),
            ),
            padding: EdgeInsets.only(left: 64, right: 64, top: 16, bottom: 16),
            color: Theme.of(context).textSelectionColor,
          ),
        ),
        SizedBox(height: _sf.scaleSize(24)),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                navigateToPageWithoutScaffold(context, ForgotPassword(() {
                  registerCall();
                }));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Forgot Password?",
                  style: _sf.getMediumStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                registerCall();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Not a member? Sign-up now!",
                  style: _sf.getMediumStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: _sf.scaleSize(20)),
      ],
    );
  }

  void registerCall() {
    navigateToPageWithoutScaffold(context, RegisterAsSelection());
  }

  void _callLoginAPI(String email, String pass) async {
    setState(() {
      _isApiCall = true;
    });
    HashMap params = HashMap();
    params["email"] = email;
    params["password"] = pass;
    final response = await callPostAPI("login", params);
    final result = json.decode(response.toString());
    printToConsole("res : $result");
    LoginModel model = LoginModel.fromJson(result);

    if (model.status.toLowerCase() == "success") {
      // showSuccessAlertDialog(context, model.message);
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
      printToConsole("   msg : ${model.status}");
      showErrorAlertDialog(context, model.message);
    }
    setState(() {
      _isApiCall = false;
    });
  }
}
