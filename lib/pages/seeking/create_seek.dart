import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_summernote/flutter_summernote.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/commons/custom/custom_switch.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/model/help_model.dart';
import 'package:jaagran/pages/common/model/status_only.dart';
import 'package:jaagran/pages/seeking/model/problems_model.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'model/emotions_model.dart';

class CreateSeek extends StatefulWidget {
  @override
  _CreateSeekState createState() => _CreateSeekState();
}

class _CreateSeekState extends State<CreateSeek> {
  SizeConfig _sf;
  Future<ProblemsModel> _post;
  ProblemData _selectedProblem;
  EmotionsData _selectedEmotion;
  List<EmotionsData> _lstEmotions;
  bool isApiCalled = false;
  bool isApiCall = false;
  bool showToExperts = true;
  TextEditingController _problemDescController = TextEditingController();

  List<HelpModel> lstHelpModel;
  GlobalKey<FlutterSummernoteState> keyEditor = GlobalKey();

  Future<List<HelpModel>> _callGetHelpDetails() async {
    final result = await callGetAPI("help-details", HashMap());
    final response = json.decode(result.toString());
    List<HelpModel> lst = HelpModel.getList(response['data']);
    return lst;
  }

  @override
  void initState() {
    super.initState();
    _post = _callProblemApi();
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    Color accentColor = Theme.of(context).accentColor;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: getCommonAppBar(context, _sf),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return true;
        },
        child: ModalProgressHUD(
          inAsyncCall: isApiCall,
          child: KeyboardVisibilityBuilder(builder: (context, visible) {
            return ListView(
              children: [
                visible
                    ? Container()
                    : Container(
                        alignment: AlignmentDirectional.center,
                        color: Colors.white,
                        padding: EdgeInsets.only(
                            bottom: _sf.scaleSize(16), top: _sf.scaleSize(16)),
                        child: Text(
                          "Seeking",
                          style: _sf.getLargeStyle(color: accentColor),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FutureBuilder(
                    future: _post,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                            height: _sf.getScreenHeight() - _sf.scaleSize(200),
                            child: Center(child: CircularProgressIndicator()));
                      }
                      ProblemsModel data = snapshot.data;
                      isApiCalled = true;
                      List<ProblemData> lst = data.lstProblemsData;
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          visible
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(left: 14, right: 8),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 0.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      color: Theme.of(context).hintColor),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<ProblemData>(
                                      items: lst.map((ProblemData value) {
                                        return DropdownMenuItem<ProblemData>(
                                          value: value,
                                          child: Text(
                                            value.problems,
                                            textAlign: TextAlign.start,
                                            style: _sf.getMediumStyle(),
                                          ),
                                        );
                                      }).toList(),
                                      hint: SizedBox(
                                        width: _sf.getScreenWidth() -
                                            _sf.scaleSize(70),
                                        child: Text(
                                          "Select type of problem",
                                          textAlign: TextAlign.start,
                                          style: _sf.getMediumStyle(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                      ),
                                      value: _selectedProblem,
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedProblem = val;
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                        });
                                      },
                                    ),
                                  )),
                          // Container(
                          //   padding: EdgeInsets.symmetric(vertical: 20),
                          //   child: TextField(
                          //     autofocus: false,
                          //     controller: _problemDescController,
                          //     textCapitalization: TextCapitalization.sentences,
                          //     decoration: InputDecoration(
                          //         border: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(8),
                          //           borderSide: BorderSide.none,
                          //         ),
                          //         contentPadding: EdgeInsets.symmetric(
                          //             vertical: _sf.scaleSize(24),
                          //             horizontal: _sf.scaleSize(48)),
                          //         hintMaxLines: 3,
                          //         filled: true,
                          //         fillColor: Theme.of(context).hintColor,
                          //         hintStyle: _sf.getMediumStyle(
                          //             color: Theme.of(context).accentColor),
                          //         hintText:
                          //             "Enter your specific issue for which you are seeking help / support"),
                          //     keyboardType: TextInputType.multiline,
                          //     maxLengthEnforced: true,
                          //     inputFormatters: <TextInputFormatter>[
                          //       LengthLimitingTextInputFormatter(1000),
                          //     ],
                          //     maxLines: _sf.scaleSize(13).round(),
                          //     // minLines: 12,
                          //   ),
                          // ),

                          Padding(
                            padding: EdgeInsets.only(top: visible ? 0 : 16),
                            child: FlutterSummernote(
                              hint:
                                  "Enter your specific issue for which you are seeking help / support",
                              key: keyEditor,
                              height: _sf.scaleSize(250),
                              showBottomToolbar: false,
                              hasAttachment: false,
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Container(
                              padding: EdgeInsets.only(
                                left: 14,
                                right: 8,
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white, width: 0.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  color: Theme.of(context).hintColor),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<EmotionsData>(
                                  items: _lstEmotions.map((EmotionsData value) {
                                    return DropdownMenuItem<EmotionsData>(
                                      value: value,
                                      child: Text(
                                        value.emotion,
                                        textAlign: TextAlign.start,
                                        style: _sf.getMediumStyle(),
                                      ),
                                    );
                                  }).toList(),
                                  hint: SizedBox(
                                    width: _sf.getScreenWidth() -
                                        _sf.scaleSize(70),
                                    child: Text(
                                      "How are you feeling today ?",
                                      textAlign: TextAlign.start,
                                      style: _sf.getMediumStyle(
                                          color: Theme.of(context).accentColor),
                                    ),
                                  ),
                                  value: _selectedEmotion,
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedEmotion = val;
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    });
                                  },
                                ),
                              )),
                          _selectedEmotion == null
                              ? Container()
                              : Visibility(
                                  visible: !_selectedEmotion.isHappyEmotion,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, top: 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Post this only to Experts ?",
                                          style: _sf.getMediumStyle(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        SizedBox(
                                          width: 16,
                                        ),
                                        CustomSwitch(
                                          activeColor: Colors.purple,
                                          value: showToExperts,
                                          onChanged: (value) {
                                            print("VALUE : $value");
                                            setState(() {
                                              showToExperts = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ),
      bottomNavigationBar: Container(
        height: _sf.scaleSize(45),
        color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            getNavButton("Post", _sf.getCaviarDreams(), () {
              _postSeek();
            },
                padding: EdgeInsets.symmetric(
                    vertical: _sf.scaleSize(8), horizontal: _sf.scaleSize(24))),
            getNavButton("Help", _sf.getCaviarDreams(), () {
              _openHelpDialog();
            },
                padding: EdgeInsets.symmetric(
                    vertical: _sf.scaleSize(8), horizontal: _sf.scaleSize(24))),
          ],
        ),
      ),
      // bottomNavigationBar: Row(
      //   mainAxisSize: MainAxisSize.max,
      //   children: [
      //     Expanded(
      //       child: InkWell(
      //         onTap: () {
      //           _postSeek();
      //         },
      //         child: Container(
      //           height: 60,
      //           alignment: AlignmentDirectional.center,
      //           color: Theme.of(context).buttonColor,
      //           child: Text(
      //             "Post",
      //             style:
      //                 _sf.getLargeStyle(color: Theme.of(context).accentColor),
      //           ),
      //         ),
      //       ),
      //     ),
      //     Expanded(
      //       child: InkWell(
      //         onTap: () {
      //           _openHelpDialog();
      //         },
      //         child: Container(
      //           height: 60,
      //           alignment: AlignmentDirectional.center,
      //           color: Theme.of(context).buttonColor,
      //           child: Text(
      //             "Help",
      //             style:
      //                 _sf.getLargeStyle(color: Theme.of(context).accentColor),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Future<ProblemsModel> _callProblemApi() async {
    final result = await callGetAPI("problems", HashMap());
    final response = json.decode(result.toString());
    ProblemsModel model = ProblemsModel.fromJSON(response);
    await _callEmotionsModelApi();
    lstHelpModel = await _callGetHelpDetails();
    return model;
  }

  _callEmotionsModelApi() async {
    final result = await callGetAPI("emotions", HashMap());
    final response = json.decode(result.toString());
    EmotionsModel model = EmotionsModel.fromJSON(response);
    _lstEmotions = model.lstEmotionsData;
    return;
  }

  void _postSeek() async {
    if (!isApiCalled || isApiCall) return;
    if (_selectedProblem == null) {
      showWarningDialog(context, "Please select type of problem");
      return;
    }
    if (_selectedEmotion == null) {
      showWarningDialog(context, "Please select how you feeling today");
      return;
    }
    String desc = await keyEditor.currentState.getText();
    if (desc == null) {
      desc = '';
    }
    if (desc.isEmpty) {
      desc = await keyEditor.currentState.getText();
    }
    if (desc == null) {
      desc = '';
    }
    if (desc.isEmpty) {
      desc = await keyEditor.currentState.getText();
    }
    printToConsole("keyEditor : $desc");
    // String desc = _problemDescController.text.toString().trim();
    if (desc.isEmpty) {
      showWarningDialog(context, "Please type specific issue");
      return;
    }

    setState(() {
      isApiCall = true;
    });

    HashMap<String, dynamic> params = HashMap();
    params["problems"] = _selectedProblem.problems;
    params["description"] = desc;
    params["emotions"] = "${_selectedEmotion.id}";
    if (!_selectedEmotion.isHappyEmotion) {
      params["show_all"] = showToExperts ? "N" : "Y";
    } else {
      params["show_all"] = "Y";
    }
    final response = await callPostAPI("create-seek", params);
    final result = json.decode(response.toString());

    StatusOnly model = StatusOnly.fromJson(result);

    setState(() {
      isApiCall = false;
    });

    if (model.isSuccess) {
      showSuccessAlertDialog(context, model.message, isCancelable: false,
          callback: () {
        Navigator.pop(context);
      });
    } else {
      showErrorAlertDialog(context, model.message);
    }
  }

  void _openHelpDialog() {
    if (!isApiCalled || isApiCall) return;

    showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 40,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 24, bottom: 16),
                        child: Center(
                          child: Text(
                            "Seek posting",
                            style: _sf.getLargeStyle(
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          "assets/images/close_circle.svg",
                          color: Theme.of(context).accentColor,
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Html(data: _getSeekHelp()),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
              ],
            ),
          );
        });
  }

  String _getSeekHelp() {
    String details;
    lstHelpModel.forEach((element) {
      if (element.helpheader.toLowerCase().contains("seek posting")) {
        details = element.detail;
      }
    });
    return details;
  }
}
