import 'dart:collection';
import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/pages/login/forgot/password/model/forgot_password_model.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';

class ForgotPassword extends StatefulWidget {
  final VoidCallback newUserCall;

  const ForgotPassword(this.newUserCall);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _emailController = TextEditingController();
  bool _isApiCall = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig _sf = SizeConfig.getInstance(context);
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
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: _sf.scaleSize(32),
                ),
                SizedBox(
                  height: _sf.scaleSize(32),
                ),
                Text(
                  "Forgot Password",
                  style: _sf.getExtraLargeStyle(
                      color: Theme.of(context).accentColor),
                ),
                SizedBox(
                  height: _sf.scaleSize(32),
                ),
                TextField(
                  controller: _emailController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.emailAddress,
                  style: _sf.getMediumStyle(),
                  decoration: InputDecoration(
                    hintText: 'Enter Email ID',
                    filled: true,
                    fillColor: Theme.of(context).hintColor,
                    hintStyle: _sf.getSmallStyle(
                      color: Theme.of(context).accentColor,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
                SizedBox(
                  height: _sf.scaleSize(32),
                ),
                _isApiCall
                    ? Center(child: CircularProgressIndicator())
                    : RaisedButton(
                        onPressed: () {
                          String email = _emailController.text.toString();
                          FocusScope.of(context).unfocus();
                          if (EmailValidator.validate(email)) {
                            _callApiForgotPassword(email);
                            setState(() {
                              _isApiCall = true;
                            });
                          } else {
                            showErrorAlertDialog(context, "Invalid Email");
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          "Submit",
                          style: _sf.getMediumStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.only(
                            left: 40, right: 40, top: 16, bottom: 16),
                        color: Theme.of(context).buttonColor,
                      ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).primaryColor,
            height: _sf.scaleSize(50),
            child: Center(
              child: getNavButton(
                "New User ? Sign Up!",
                _sf.getCaviarDreams(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                () {
                  Navigator.of(context).pop();
                  widget.newUserCall.call();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _callApiForgotPassword(String email) async {
    // https://jaagran.in/api/forgot-password?email=dhana2513%40gmail.com
    HashMap params = HashMap();
    params["email"] = email;
    final response = await callPostAPI("forgot-password", params);
    final result = json.decode(response.toString());
    ForgotPasswordModel model = ForgotPasswordModel.fromJson(result);
    if (model.status == "success") {
      showSuccessAlertDialog(context, model.message, callback: () {
        Navigator.of(context).pop();
      }, isCancelable: false);
    } else {
      showErrorAlertDialog(context, model.message, callback: () {
        Navigator.of(context).pop();
      }, isCancelable: false);
    }
    setState(() {
      _isApiCall = false;
    });
  }
}
