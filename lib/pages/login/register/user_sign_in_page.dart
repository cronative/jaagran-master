import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:image_picker/image_picker.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/common_functions.dart';
import 'package:jaagran/pages/login/register/model/register_model.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UserSignInPage extends StatefulWidget {
  @override
  _UserSignInPageState createState() => _UserSignInPageState();
}

class _UserSignInPageState extends State<UserSignInPage> {
  SizeConfig _sf;
  FilePickerResult _profileImg;
  File _selectedImage;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _rePasswordController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  bool _isApiCall = false;
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;

  @override
  Widget build(BuildContext context) {
    Color accentColor = Theme.of(context).accentColor;
    _sf = SizeConfig.getInstance(context);
    printToConsole("45");

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
      bottomNavigationBar: Container(
        height: _sf.scaleSize(45),
        color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            getNavButton("Cancel", _sf.getCaviarDreams(), () {
              _cancel();
            },
                padding: EdgeInsets.symmetric(
                    vertical: _sf.scaleSize(8), horizontal: _sf.scaleSize(24))),
            getNavButton("Register", _sf.getCaviarDreams(), () {
              _register();
            },
                padding: EdgeInsets.symmetric(
                    vertical: _sf.scaleSize(8), horizontal: _sf.scaleSize(24))),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Theme.of(context).primaryColor,
      //   type: BottomNavigationBarType.fixed,
      //   onTap: (index) {
      //     if (index == 0) {
      //       _cancel();
      //     } else {
      //       _register();
      //     }
      //   },
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.call,
      //         size: 0,
      //       ),
      //       title: Text(
      //         "CANCEL",
      //         style: _sf.getLargeStyle(color: accentColor),
      //       ),
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Icons.call,
      //         size: 0,
      //       ),
      //       title: Text(
      //         "REGISTER",
      //         style: _sf.getLargeStyle(
      //             fontSize: _sf.scaleSize(21.5), color: accentColor),
      //       ),
      //     ),
      //   ],
      // ),
      body: ModalProgressHUD(
        inAsyncCall: _isApiCall,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "User Sign Up",
                    style: _sf.getLargeStyle(color: accentColor),
                  ),
                  SizedBox(
                    height: _sf.scaleSize(16),
                  ),
                  _getFileWidget(),
                  SizedBox(
                    height: _sf.scaleSize(16),
                  ),
                  TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    style: _sf.getMediumStyle(),
                    maxLengthEnforced: true,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(45),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter Alias / Nickname*',
                      filled: true,
                      fillColor: Theme.of(context).hintColor,
                      hintStyle: _sf.getSmallStyle(
                          color: Theme.of(context).accentColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.all(0),
                    ),
                  ),
                  SizedBox(
                    height: _sf.scaleSize(16),
                  ),
                  TextField(
                    controller: _emailController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.emailAddress,
                    style: _sf.getMediumStyle(),
                    maxLengthEnforced: true,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(100),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Email ID*',
                      filled: true,
                      fillColor: Theme.of(context).hintColor,
                      hintStyle: _sf.getSmallStyle(
                          color: Theme.of(context).accentColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.all(0),
                    ),
                  ),
                  SizedBox(
                    height: _sf.scaleSize(16),
                  ),
                  TextField(
                    controller: _mobileController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: _sf.getMediumStyle(),
                    decoration: InputDecoration(
                      hintText: 'Mobile No.*',
                      filled: true,
                      fillColor: Theme.of(context).hintColor,
                      hintStyle: _sf.getSmallStyle(
                          color: Theme.of(context).accentColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.all(0),
                    ),
                  ),
                  SizedBox(
                    height: _sf.scaleSize(16),
                  ),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textAlign: TextAlign.center,
                    obscureText: !_passwordVisible1,
                    style: _sf.getMediumStyle(),
                    maxLengthEnforced: true,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(16),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Password*',
                      filled: true,
                      fillColor: Theme.of(context).hintColor,
                      hintStyle: _sf.getSmallStyle(
                          color: Theme.of(context).accentColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.all(0),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible1
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible1 = !_passwordVisible1;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _sf.scaleSize(16),
                  ),
                  TextField(
                    controller: _rePasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    textAlign: TextAlign.center,
                    obscureText: !_passwordVisible2,
                    style: _sf.getMediumStyle(),
                    maxLengthEnforced: true,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(16),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Reconfirm Password*',
                      filled: true,
                      fillColor: Theme.of(context).hintColor,
                      hintStyle: _sf.getSmallStyle(
                          color: Theme.of(context).accentColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.all(0),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible2
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible2 = !_passwordVisible2;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _sf.scaleSize(16),
                  ),
                  TextField(
                    controller: _cityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    style: _sf.getMediumStyle(),
                    maxLengthEnforced: true,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(45),
                    ],
                    decoration: InputDecoration(
                      hintText: 'City*',
                      filled: true,
                      fillColor: Theme.of(context).hintColor,
                      hintStyle: _sf.getSmallStyle(
                          color: Theme.of(context).accentColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.all(0),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  void _register() async {
    String name = _nameController.text.toString().trim();
    String email = _emailController.text.toString().trim();
    String number = _mobileController.text.toString().trim();
    String password = _passwordController.text.toString().trim();
    String rePassword = _rePasswordController.text.toString().trim();
    String city = _cityController.text.toString().trim();

    if (name.isEmpty) {
      showWarningDialog(context, "Please enter name.");
      return;
    }
    if (email.isEmpty) {
      showWarningDialog(context, "Please enter email.");
      return;
    }
    if (number.isEmpty) {
      showWarningDialog(context, "Please enter number.");
      return;
    }
    if (password.isEmpty) {
      showWarningDialog(context, "Please enter password.");
      return;
    }
    if (rePassword.isEmpty) {
      showWarningDialog(context, "Please repeat password.");
      return;
    }
    if (city.isEmpty) {
      showWarningDialog(context, "Please enter city.");
      return;
    }
    if (!EmailValidator.validate(email)) {
      showWarningDialog(context, "Please enter valid email id.");
      return;
    }
    if (number.length < 10) {
      showWarningDialog(context, "Please enter valid mobile number.");
      return;
    }

    if (password.length < 6) {
      showWarningDialog(context, "Password must contain 6 characters.");
      return;
    }

    if (password != rePassword) {
      showWarningDialog(context, "Password not matching");
      return;
    }

    setState(() {
      _isApiCall = true;
    });

    // HashMap params = HashMap();
    // params["name"] = name;
    // params["email"] = email;
    // params["mobile"] = number;
    // params["password"] = password;
    // params["confirm_password"] = rePassword;
    // params["user_type"] = "USERS";
    // params["city"] = city;

    var postUri = Uri.parse(API_URL + "register");
    var request = new http.MultipartRequest("POST", postUri);

    // var request = new http.MultipartRequest("POST", "url");

    request.fields["name"] = name;
    request.fields["email"] = email;
    request.fields["mobile"] = number;

    request.fields["password"] = password;
    request.fields["confirm_password"] = rePassword;
    request.fields["user_type"] = "USERS";
    request.fields["city"] = city;

    if (_selectedImage != null) {
      _selectedImage = await compressImage(_selectedImage);

      printToConsole("file path : ${_selectedImage.path}");
      request.files.add(await http.MultipartFile.fromPath(
        'dp',
        _selectedImage.path,
        contentType: MediaType('image', _getType(_selectedImage.path)),
      ));
    }
    request.send().then((response) async {
      String res = await response.stream.bytesToString();
      printToConsole("responce : ${res}");
      final result = json.decode(res);
      RegisterModel model = RegisterModel.fromJson(result);
      if (model.status.toLowerCase() == "success") {
        showSuccessAlertDialog(context, model.message, isCancelable: false,
            callback: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      } else {
        setState(() {
          _isApiCall = false;
        });
        showErrorAlertDialog(
          context,
          model.message,
          isCancelable: false,
        );
      }
    });

    // _callRegisterAPI(params);
  }

  // void _callRegisterAPI(HashMap params) async {
  //   final response = await callPostAPI("register", params);
  //   final result = json.decode(response.toString());
  //   RegisterModel model = RegisterModel.fromJson(result);
  //   if (model.status.toLowerCase() == "success") {
  //     showSuccessAlertDialog(context, model.message, isCancelable: false,
  //         callback: () {
  //       Navigator.of(context).pop();
  //       Navigator.of(context).pop();
  //     });
  //   } else {
  //     showErrorAlertDialog(
  //       context,
  //       model.message,
  //       isCancelable: false,
  //     );
  //   }
  //   setState(() {
  //     _isApiCall = false;
  //   });
  // }

  String _getType(String path) {
    List<String> lstStr = path.split(".");
    return lstStr[lstStr.length - 1];
  }

  _getFileWidget() {
    return InkWell(
      onTap: () async {
        _profileImg = await FilePicker.platform
            .pickFiles(type: FileType.image, allowMultiple: false);
        setState(() {

        });
      },
      child: _profileImg == null
          ? Column(
        children: [
          CircleAvatar(
            radius: _sf.scaleSize(40),
            backgroundImage:
            AssetImage("assets/images/dp_circular_avatar.png"),
            backgroundColor: Colors.transparent,
          ),
          SizedBox(
            height: _sf.scaleSize(8),
          ),
          Text(
            "Select",
            style:
            _sf.getSmallStyle(color: Theme.of(context).accentColor),
          ),
        ],
      )
          : _showPicture(),
    );
  }

  _showPicture() {
    try {
      _selectedImage = File(_profileImg.files.single.path);
      return CircleAvatar(
        radius: _sf.scaleSize(40),
        backgroundImage: FileImage(
          _selectedImage,
        ),
      );
    } on Exception catch (e) {
      printToConsole(e.toString());
      return Container();
    }
  }
}
