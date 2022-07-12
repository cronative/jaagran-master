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
import 'package:jaagran/pages/notifications/model/notification_model.dart';
import 'package:jaagran/pages/profile/model/profile_model.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';

class VcConfirmPage extends StatefulWidget {
  final NotificationData vcRequestData;
  final String notificationId;

  const VcConfirmPage({Key key, this.vcRequestData, this.notificationId})
      : super(key: key);

  @override
  _VcConfirmPageState createState() => _VcConfirmPageState();
}

class _VcConfirmPageState extends State<VcConfirmPage> {
  SizeConfig _sf;
  Future<ProfileModel> _profileModelPost;
  bool isChangeDateTime = false;
  DateTime _selectedDate;
  TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _profileModelPost = getProfileById(widget.vcRequestData.receiver_id);

    _selectedDate = _getSessionDate();
    _selectedTime = _getSessionTime();
  }

  DateTime _getSessionDate() {
    widget.vcRequestData.session_date =
        widget.vcRequestData.session_date.replaceAll("-", "/");
    List<String> dates = widget.vcRequestData.session_date.split("/");
    DateTime time = DateTime.now();

    return DateTime(
      int.parse(dates[0]),
      int.parse(dates[1]),
      int.parse(dates[2]),
      time.hour,
      time.minute,
      time.second,
      time.millisecond,
      time.microsecond,
    );
  }

  TimeOfDay _getSessionTime() {
    List<String> time = widget.vcRequestData.session_time.split(":");
    int hr = int.parse(time[0]);
    int min = int.parse(time[1]);
    return TimeOfDay(hour: hr, minute: min);
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      appBar: getCommonAppBar(context, _sf),
      body: FutureBuilder(
        future: _profileModelPost,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          ProfileModel profileModel = snapshot.data;
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderWidget(
                title: "Live Sessions",
              ),
              _getProfileView(profileModel),
              Container(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Text(
                  "Notes :",
                  style: _sf.getMediumStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 4, left: 16, right: 16),
                child: Text(
                  widget.vcRequestData.notes,
                  style: _sf.getMediumStyle(),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20, left: 16, right: 16),
                child: Text(
                  "Session Request Date:  ${widget.vcRequestData.session_date}",
                  style: _sf.getMediumStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20, left: 16, right: 16),
                child: Text(
                  "Session Request Time:  ${_get12HrTime(widget.vcRequestData.session_time)}",
                  style: _sf.getMediumStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
              // isChangeDateTime
              //     ? _modifyDateTime()
              //     : Container(
              //   padding: EdgeInsets.only(top: 20, left: 16, right: 16),
              //   child: InkWell(
              //     onTap: () {
              //       setState(() {
              //         isChangeDateTime = true;
              //       });
              //     },
              //     child: Container(
              //       padding: EdgeInsets.only(top: 8, left: 8, right: 8),
              //       child: Text(
              //         "Change Date & time",
              //         style: _sf.getMediumStyle(
              //             color: Theme.of(context).accentColor,
              //             decoration: TextDecoration.underline),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 60,
        alignment: AlignmentDirectional.center,
        color: Theme.of(context).buttonColor,
        child: getNavButton(
          "Confirm Appointment",
          _sf.getCaviarDreams(),
              () {
            _callAcceptAPI();
          },
          padding: EdgeInsets.symmetric(
            vertical: _sf.scaleSize(8),
            horizontal: _sf.scaleSize(20),
          ),
        ),
      ),
    );
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
  Future<String> _getUserDp(String dp) async {
    SessionManager manager = SessionManager.getInstance();
    if (dp.isEmpty || dp == "null") return "";
    return Server_URL + manager.getDpPath() + dp;
  }
  _get12HrTime(String session_time) {
    List<String> time = session_time.split(":");
    int hr = int.parse(time[0]);
    int min = int.parse(time[1]);
    TimeOfDay timeOfDay = TimeOfDay(hour: hr, minute: min);
    return timeOfDay.format(context);
  }



  _callAcceptAPI() async {
    if (_selectedDate == null) {
      showWarningDialog(context, "Please select date");
      return;
    }
    if (_selectedTime == null) {
      showWarningDialog(context, "Please select time");
      return;
    }
    HashMap<String, String> params = HashMap();
    params['id'] = widget.vcRequestData.id;
    params['status'] = 'confirm';
    params['confirm_date'] = getFormattedDateForAPI(_selectedDate);
    params['confirm_time'] =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    // params['confirm_time'] = getFormattedDateForAPI(_selectedDate);
    // params['confirm_date'] =
    // '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
    final result = await callPostAPI("vc-request-action", params);
    final response = json.decode(result.toString());
    if (response['status'] == 'success') {
      _callAPIForDeleteNotification();
      showSuccessAlertDialog(context, response['message'], isCancelable: false,
          callback: () {
            Navigator.of(context).pop();
            // Navigator.of(context).pop();
          });
    } else {
      showErrorAlertDialog(context, response['message']);
    }
  }

  _callAPIForDeleteNotification() async {
    HashMap params = HashMap();
    params['notification_id'] = widget.notificationId;
    final result = await callPostAPI("notification-delete", params);
    final response = json.decode(result.toString());
  }
}
