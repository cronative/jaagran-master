import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/model/status_only.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  SizeConfig _sf;
  bool isApiCall = false;
  TextEditingController _feedbackDescController = TextEditingController();
  List<String> lstFeedbackCat = [];
  String _selectedCat;

  // Future<List<HelpModel>> _callGetHelpDetails() async {
  //   final result = await callGetAPI("help-details", HashMap());
  //   final response = json.decode(result.toString());
  //   List<HelpModel> lst = HelpModel.getList(response['data']);
  //   return lst;
  // }

  @override
  void initState() {
    super.initState();
    // FirebaseCrashlytics.instance.crash();

    // _post = _callProblemApi();
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    Color accentColor = Theme.of(context).accentColor;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: getCommonAppBar(context, _sf),
      body: ModalProgressHUD(
        inAsyncCall: isApiCall,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  alignment: AlignmentDirectional.center,
                  color: Colors.white,
                  padding: EdgeInsets.only(
                      bottom: _sf.scaleSize(16), top: _sf.scaleSize(16)),
                  child: Text(
                    "Feedback",
                    style: _sf.getLargeStyle(color: accentColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      FutureBuilder(
                        future: _getFeedBackCat(),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          return Container(
                              padding: EdgeInsets.only(left: 14, right: 8),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white, width: 0.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  color: Theme.of(context).hintColor),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  items: lstFeedbackCat.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        textAlign: TextAlign.start,
                                        style: _sf.getMediumStyle(),
                                      ),
                                    );
                                  }).toList(),
                                  hint: SizedBox(
                                    width: _sf.getScreenWidth() -
                                        _sf.scaleSize(70),
                                    child: Text(
                                      "Select Category of Feedback",
                                      textAlign: TextAlign.start,
                                      style: _sf.getMediumStyle(
                                          color: Theme.of(context).accentColor),
                                    ),
                                  ),
                                  value: _selectedCat,
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedCat = val;
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                    });
                                  },
                                ),
                              ));
                        },
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: TextField(
                          autofocus: false,
                          controller: _feedbackDescController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: _sf.scaleSize(24),
                                  horizontal: _sf.scaleSize(48)),
                              hintMaxLines: 3,
                              filled: true,
                              fillColor: Theme.of(context).hintColor,
                              hintStyle: _sf.getMediumStyle(
                                  color: Theme.of(context).accentColor),
                              hintText: "Enter your specific feedback"),
                          keyboardType: TextInputType.multiline,
                          maxLengthEnforced: true,
                          inputFormatters: <TextInputFormatter>[
                            LengthLimitingTextInputFormatter(1000),
                          ],
                          maxLines: _sf.scaleSize(13).round(),
                          // minLines: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                height: 60,
                alignment: AlignmentDirectional.center,
                color: Theme.of(context).buttonColor,
                child: getNavButton(
                  "Post",
                  _sf.getCaviarDreams(),
                  () => _postFeedback(),
                  padding: EdgeInsets.symmetric(
                    vertical: _sf.scaleSize(8),
                    horizontal: _sf.scaleSize(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _getFeedBackCat() async {
    SessionManager manager = SessionManager.getInstance();
    lstFeedbackCat = manager.getFeedbackCategories();
    return lstFeedbackCat;
  }

  void _postFeedback() async {
    if (isApiCall) return;

    if (_selectedCat == null) {
      showWarningDialog(context, "Please select category of feedback");
      return;
    }

    String desc = _feedbackDescController.text.toString().trim();
    if (desc.isEmpty) {
      showWarningDialog(context, "Please type specific feedback");
      return;
    }

    setState(() {
      isApiCall = true;
    });
    HashMap<String, dynamic> params = HashMap();
    params["category"] = _selectedCat;
    params["feedback"] = desc;
    final response = await callPostAPI("feedback", params);
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
}
