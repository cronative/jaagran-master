import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_functions.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/appbar/header_widget.dart';
import 'package:jaagran/pages/profile/model/profile_model.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LiveSessionRequestPage extends StatefulWidget {
  final ProfileModel profile;

  const LiveSessionRequestPage({
    Key key,
    this.profile,
  }) : super(key: key);

  @override
  _LiveSessionRequestPageState createState() => _LiveSessionRequestPageState();
}

class _LiveSessionRequestPageState extends State<LiveSessionRequestPage> {
  SizeConfig _sf;
  DateTime _selectedDate;
  TimeOfDay _selectedTime;
  TextEditingController _notesController = TextEditingController();
  bool isAPICall = false;

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: getCommonAppBar(context, _sf),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: isAPICall,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: ListView(
            children: [
              HeaderWidget(
                title: "Sessions Request",
              ),
              _getProfileView(widget.profile),
              SizedBox(
                height: _sf.scaleSize(12),
              ),
              Text(
                "Notes for the Expert",
                style: _sf.getMediumStyle(),
              ),
              SizedBox(
                height: _sf.scaleSize(8),
              ),
              TextField(
                autofocus: false,
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: _sf.scaleSize(16),
              ),
              InkWell(
                onTap: () async {
                  _selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(
                      Duration(days: 30),
                    ),
                  );
                  setState(() {});
                },
                child: Text(
                  "Select Date: ${_getSelectedDate()}",
                  style:
                      _sf.getMediumStyle(decoration: TextDecoration.underline),
                ),
              ),
              SizedBox(
                height: _sf.scaleSize(16),
              ),
              InkWell(
                onTap: () async {
                  _selectedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ??
                        TimeOfDay(
                          minute: 0,
                          hour: 0,
                        ),
                  );
                  setState(() {});
                },
                child: Text(
                  "Select Time: ${_getSelectedTime()}",
                  style:
                      _sf.getMediumStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        alignment: AlignmentDirectional.center,
        color: Theme.of(context).buttonColor,
        child: getNavButton(
          "Seek Appointment",
          _sf.getCaviarDreams(),
          () {
            _callVCRequestAPI();
          },
          padding: EdgeInsets.symmetric(
            vertical: _sf.scaleSize(8),
            horizontal: _sf.scaleSize(20),
          ),
        ),
      ),
    );
  }

  Future<String> _getUserDp(String dp) async {
    SessionManager manager = SessionManager.getInstance();
    if (dp.isEmpty || dp == "null") return "";
    return Server_URL + manager.getDpPath() + dp;
  }

  Widget _getProfileView(ProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _sf.scaleSize(8)),
          child: Text(
            profile.title + " " + profile.name,
            style: _sf.getLargeStyle(
                color: const Color(0x00ff805B97), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: _sf.scaleSize(12),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  alignment: AlignmentDirectional.center,
                  padding: EdgeInsets.only(left: 4),
                  child: FutureBuilder<String>(
                    future: _getUserDp(profile.dp),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        String dp = snapshot.data.toString().trim();
                        // printToConsole("user dp : $dp");
                        if (dp.isNotEmpty) {
                          return CircleAvatar(
                            radius: _sf.scaleSize(50),
                            backgroundImage: AssetImage(
                                "assets/images/dp_circular_avatar.png"),
                            backgroundColor: Colors.transparent,
                            child: CircleAvatar(
                              radius: _sf.scaleSize(50),
                              backgroundImage: NetworkImage(
                                dp,
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                          );
                        }
                      }
                      return CircleAvatar(
                        radius: _sf.scaleSize(50),
                        backgroundImage:
                            AssetImage("assets/images/dp_circular_avatar.png"),
                        backgroundColor: Colors.transparent,
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(
              width: _sf.scaleSize(16),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: _sf.getScreenWidth() / 2,
                  padding: EdgeInsets.all(_sf.scaleSize(6)),
                  child: Text(
                    "Expertise : ${profile.expertise}",
                    style: _sf.getMediumStyle(color: Colors.black87),
                  ),
                ),
                Container(
                  width: _sf.getScreenWidth() / 2,
                  padding: EdgeInsets.all(_sf.scaleSize(6)),
                  child: Text(
                    "Trained from : ${profile.trained_with == 'null' ? "" : profile.trained_with}",
                    style: _sf.getMediumStyle(color: Colors.black87),
                  ),
                ),
              ],
            )
          ],
        )
      ],
    );
  }

  String _getSelectedDate() {
    if (_selectedDate == null) return '';
    DateFormat dateFormat = DateFormat("dd/MM/yy");
    return dateFormat.format(_selectedDate);
  }

  _getSelectedTime() {
    if (_selectedTime == null) return '';
    final localizations = MaterialLocalizations.of(context);
    final formattedTimeOfDay = localizations.formatTimeOfDay(_selectedTime);
    return formattedTimeOfDay;
  }

  void _callVCRequestAPI() async {
    setState(() {
      isAPICall = true;
    });
    if (_selectedDate == null) {
      showWarningDialog(context, "Please select date");
      return;
    }
    if (_selectedTime == null) {
      showWarningDialog(context, "Please select time");
      return;
    }
    if (_notesController.text.trim().isEmpty) {
      showWarningDialog(context, "Please add note");
      return;
    }
    HashMap<String, String> params = HashMap();
    params['receiver_id'] = widget.profile.id;
    params['session_date'] = getFormattedDateForAPI(_selectedDate);
    params['session_time'] =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    params['notes'] = _notesController.text.trim();
    final result = await callPostAPI("vc-request", params);
    final response = json.decode(result.toString());
    if (response['status'] == 'success') {
      showSuccessAlertDialog(context, response['message'], isCancelable: false,
          callback: () {
        Navigator.of(context).pop();
      });
    } else {
      showErrorAlertDialog(context, response['message']);
    }
    setState(() {
      isAPICall = false;
    });
  }
}
