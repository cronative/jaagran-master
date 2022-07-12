import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/common_functions.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

import 'model/expertise_model.dart';
import 'model/register_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ExpertSignInPage extends StatefulWidget {
  @override
  _ExpertSignInPageState createState() => _ExpertSignInPageState();
}

class _ExpertSignInPageState extends State<ExpertSignInPage> {
  SizeConfig _sf;
  FilePickerResult _profileImg;
  File _selectedImage;

  // TextEditingController _titleController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _rePasswordController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _qualificationController = TextEditingController();
  TextEditingController _trainedFromController = TextEditingController();
  TextEditingController _experienceController = TextEditingController();
  bool _isApiCall = false;
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;
  List<dynamic> _selectedLstExpertise;
  String _selectedTitle;

  String _myActivities;

  Future<ExpertiseModel> _postExpertiseList;

  @override
  void initState() {
    super.initState();
    _postExpertiseList = _callExpertiseApi();
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor = Theme.of(context).accentColor;
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
      //
      // BottomNavigationBar(
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
      //       title: getNavText("REGISTER", _sf.getCaviarDreams(),
      //           padding: EdgeInsets.symmetric(vertical: 10, horizontal: 32)),
      //     ),
      //   ],
      // )
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
                    "Expert Sign Up",
                    style: _sf.getLargeStyle(color: accentColor),
                  ),
                  SizedBox(
                    height: _sf.scaleSize(16),
                  ),
                  _getFileWidget(),
                  SizedBox(
                    height: _sf.scaleSize(16),
                  ),
                  // TextField(
                  //   controller: _titleController,
                  //   textAlign: TextAlign.center,
                  //   keyboardType: TextInputType.text,
                  //   style: _sf.getMediumStyle(),
                  //   decoration: InputDecoration(
                  //     hintText: 'Title (Dr. Prof Etc.)*',
                  //     hintStyle: _sf.getSmallStyle(color: Colors.black54),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     contentPadding: EdgeInsets.all(0),
                  //   ),
                  // ),
                  Container(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 0.0),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        color: Theme.of(context).hintColor),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        items: ["Dr.", "PhD", "Prof.", "Mr.", "Mrs.", "Miss"]
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: SizedBox(
                              width: _sf.getScreenWidth() - _sf.scaleSize(70),
                              child: Text(
                                value,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ),
                          );
                        }).toList(),
                        hint: SizedBox(
                          width: _sf.getScreenWidth() - _sf.scaleSize(70),
                          child: Text(
                            "Title (Dr. Prof Etc.)*",
                            textAlign: TextAlign.center,
                            style: _sf.getSmallStyle(
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                        value: _selectedTitle,
                        onChanged: (val) {
                          setState(() {
                            _selectedTitle = val;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _sf.scaleSize(16),
                  ),
                  TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    style: _sf.getMediumStyle(),
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(45),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter Your Name*',
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
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(100),
                    ],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.emailAddress,
                    style: _sf.getMediumStyle(),
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
                  // TextField(
                  //   controller: _passwordController,
                  //   textAlign: TextAlign.center,
                  //   keyboardType: TextInputType.visiblePassword,
                  //   obscureText: true,
                  //   style: _sf.getMediumStyle(),
                  //   decoration: InputDecoration(
                  //     hintText: 'Password*',
                  // //       filled: true,
                  //     fillColor:Theme.of(context).hintColor,
                  //     hintStyle: _sf.getSmallStyle(color: Theme.of(context).accentColor),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     contentPadding: EdgeInsets.all(0),
                  //   ),
                  // ),
                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textAlign: TextAlign.center,
                    obscureText: !_passwordVisible1,
                    style: _sf.getMediumStyle(),
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
                  Container(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 0.0),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        color: Theme.of(context).hintColor),
                    child: FutureBuilder(
                      future: _postExpertiseList,
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        List<LstExpertise> lst = List();

                        printToConsole("_postExpertiseList call");

                        if (snapshot.hasData) {
                          ExpertiseModel model = snapshot.data;
                          lst = model.lstExpertise;
                        }

                        // return DropdownButtonHideUnderline(
                        //   child: DropdownButton<LstExpertise>(
                        //     items: lst.map((LstExpertise value) {
                        //       return DropdownMenuItem<LstExpertise>(
                        //         value: value,
                        //         child: SizedBox(
                        //           width:
                        //               _sf.getScreenWidth() - _sf.scaleSize(70),
                        //           child: Text(
                        //             value.expertise,
                        //             textAlign: TextAlign.center,
                        //             style:
                        //                 Theme.of(context).textTheme.bodyText2,
                        //           ),
                        //         ),
                        //       );
                        //     }).toList(),
                        //     hint: SizedBox(
                        //       width: _sf.getScreenWidth() - _sf.scaleSize(70),
                        //       child: Text(
                        //         "Expertise",
                        //         textAlign: TextAlign.center,
                        //         style: _sf.getSmallStyle(color: Colors.black54),
                        //       ),
                        //     ),
                        //     value: _LstExpertise,
                        //     onChanged: (val) {
                        //       setState(() {
                        //         _LstExpertise = val;
                        //       });
                        //     },
                        //   ),
                        // );

                        return MultiSelectFormField(
                          fillColor: Theme.of(context).hintColor,
                          autovalidate: false,
                          title: Text(
                            'Expertise',
                            style: _sf.getSmallStyle(
                                color: Theme.of(context).accentColor),
                          ),
                          validator: (value) {
                            if (value == null || value.length == 0) {
                              return 'Please select one or more options';
                            }
                            return null;
                          },
                          dataSource: _convertToJSON(lst),
                          textField: 'expertise',
                          valueField: 'id',
                          okButtonLabel: 'OK',
                          cancelButtonLabel: 'CANCEL',
                          // required: true,
                          hintWidget: Text(
                            'Please choose one or more',
                            style: _sf.getExtraExtraSmallStyle(
                                color: Theme.of(context).accentColor),
                          ),
                          initialValue: _selectedLstExpertise,
                          onSaved: (value) {
                            if (value == null) return;
                            printToConsole("value : $value");
                            setState(() {
                              _selectedLstExpertise = value;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: _sf.scaleSize(16),
                  ),
                  TextField(
                    controller: _qualificationController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    style: _sf.getMediumStyle(),
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(100),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Qualification*',
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
                    controller: _experienceController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: _sf.getMediumStyle(),
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(2),
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      hintText: 'Experience Years*',
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
                    controller: _trainedFromController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    style: _sf.getMediumStyle(),
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(70),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Trained from (Organisation/Master/Institute)*',
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
                    style: _sf.getMediumStyle(),
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly
                    ],
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
                  TextField(
                    controller: _cityController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    style: _sf.getMediumStyle(),
                    textCapitalization: TextCapitalization.sentences,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(45),
                    ],
                    decoration: InputDecoration(
                      hintText: 'City.*',
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
    String title = _selectedTitle ?? "";
    String name = _nameController.text.toString().trim();
    String email = _emailController.text.toString().trim();
    String number = _mobileController.text.toString().trim();
    String password = _passwordController.text.toString().trim();
    String rePassword = _rePasswordController.text.toString().trim();
    String city = _cityController.text.toString().trim();
    // int expertise = 1;
    // int expertise = LstExpertise == null ? -1 : _LstExpertise.id;
    String qualification = _qualificationController.text.toString().trim();
    String experience = _experienceController.text.toString().trim();
    String trainedFrom = _trainedFromController.text.toString().trim();

    String expertise = _getIds(_selectedLstExpertise);
    printToConsole("expertise : $expertise");

    if (_selectedImage == null) {
      showWarningDialog(context, "Please select profile picture.");
      return;
    }
    if (title.isEmpty) {
      showWarningDialog(context, "Please select title.");
      return;
    }
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

    if (expertise.isEmpty) {
      showWarningDialog(context, "Please select expertise.");
      return;
    }

    if (city.isEmpty) {
      showWarningDialog(context, "Please enter city.");
      return;
    }

    if (qualification.isEmpty) {
      showWarningDialog(context, "Please enter qualification.");
      return;
    }
    if (trainedFrom.isEmpty) {
      showWarningDialog(context, "Please enter trained from.");
      return;
    }
    if (experience.isEmpty) {
      showWarningDialog(context, "Please enter experience.");
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
    // params["title"] = title;
    // params["name"] = name;
    // params["email"] = email;
    // params["mobile"] = number;
    //
    // params["password"] = password;
    // params["confirm_password"] = rePassword;
    // params["user_type"] = "EXPERTS";
    // params["city"] = city;
    //
    // params["expertise"] = expertise;
    // params["qualification"] = qualification;
    // params["experience"] = experience;

    var postUri = Uri.parse(API_URL + "register");
    var request = new http.MultipartRequest("POST", postUri);

    // var request = new http.MultipartRequest("POST", "url");

    request.fields["title"] = title;
    request.fields["name"] = name;
    request.fields["email"] = email;
    request.fields["mobile"] = number;

    request.fields["password"] = password;
    request.fields["confirm_password"] = rePassword;
    request.fields["user_type"] = "EXPERTS";
    request.fields["city"] = city;

    request.fields["expertise"] = expertise;
    request.fields["qualification"] = qualification;
    request.fields["trained_with"] = trainedFrom;
    request.fields["experience"] = experience;
    // request.files.add(new http.MultipartFile.fromBytes(
    //     'dp', await _selectedImage.readAsBytes(),
    //     contentType: MediaType('image', 'jpg')));

    printToConsole("file path : ${_selectedImage.path}");
    _selectedImage = await compressImage(_selectedImage);

    request.files.add(await http.MultipartFile.fromPath(
      'dp',
      _selectedImage.path,
      contentType: MediaType('image', _getType(_selectedImage.path)),
    ));

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
  //     showErrorAlertDialog(context, model.message, isCancelable: false,
  //         callback: () {
  //       // Navigator.of(context).pop();
  //       // Navigator.of(context).pop();
  //     });
  //   }
  //   setState(() {
  //     _isApiCall = false;
  //   });
  // }

  Future<ExpertiseModel> _callExpertiseApi() async {
    final response = await callGetAPI("expertise", HashMap());
    final result = json.decode(response.toString());
    // SessionManager manager = SessionManager.getInstance();
    // manager.setExpertiseResponse(response.toString());
    ExpertiseModel model = ExpertiseModel.fromJSON(result);
    return model;
  }

  _convertToJSON(List<LstExpertise> lstExpertise) {
    return lstExpertise.map((e) => e.toJson()).toList();
  }

  String _getIds(List lst) {
    if (lst == null) return "";
    if (lst.isEmpty) return "";
    String ids = "";
    lst.forEach((element) {
      ids += "$element,";
    });
    ids = ids.substring(0, ids.length - 1);
    printToConsole("ids : $ids");
    return ids;
  }

  String _getType(String path) {
    List<String> lstStr = path.split(".");
    return lstStr[lstStr.length - 1];
  }

  _getFileWidget() {
    return InkWell(
      onTap: () async {
        _profileImg = await FilePicker.platform
            .pickFiles(type: FileType.image, allowMultiple: false);
        setState(() {});
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
    _selectedImage = File(_profileImg.files.single.path);
    return CircleAvatar(
      radius: _sf.scaleSize(40),
      backgroundImage: FileImage(
        _selectedImage,
      ),
    );
  }
}
