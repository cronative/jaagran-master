import 'dart:collection';
import 'dart:convert';

// import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_functions.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/commons/widgets/common_circular_image.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/appbar/header_widget.dart';
import 'package:jaagran/pages/liveSessions/agora/call.dart';
import 'package:jaagran/pages/liveSessions/vc_request_action_page.dart';
import 'package:jaagran/pages/notifications/model/notification_model.dart';
import 'package:jaagran/pages/wallet/wallet_util.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:permission_handler/permission_handler.dart';

import 'models/vc_index_model.dart';

class LiveSessionsLandingPage extends StatefulWidget {
  @override
  _LiveSessionsLandingPageState createState() =>
      _LiveSessionsLandingPageState();
}

class _LiveSessionsLandingPageState extends State<LiveSessionsLandingPage> {
  SizeConfig _sf;
  Future<List<VCIndexModel>> _post;
  String dpPath = '';

  @override
  void initState() {
    super.initState();
    _post = _callAPIForVCIndexModel();
    _walletUtil = WalletUtil();
    _getDpPath();
  }

  void _getDpPath() async {
    SessionManager sessionManager = SessionManager.getInstance();
    dpPath = sessionManager.getDpPath();
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      appBar: getCommonAppBar(context, _sf),
      body: Column(
        children: [
          HeaderWidget(
            title: "Live Sessions",
          ),
          FutureBuilder(
            future: _post,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              List<VCIndexModel> lst = snapshot.data;
              if (lst.isEmpty) {
                return Center(
                  child: Text(
                    "No Live Session Record Found!",
                    style: _sf.getMediumStyle(),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: lst.length,
                itemBuilder: (BuildContext context, int index) {
                  VCIndexModel vcIndexModel = lst[index];
                  bool isRequest = vcIndexModel.status.trim().toLowerCase() ==
                      'sender_request';
                  String time = isRequest
                      ? vcIndexModel.session_date
                      : vcIndexModel.confirm_date;
                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      onTap: () async {
                        if (isRequest) {
                          _openRequestAction(vcIndexModel);
                        } else if (_validateSession(vcIndexModel)) {
                          _openSession(vcIndexModel);
                        }
                      },
                      leading: CommonCircularAvatar(
                        url: getImageUrl(dpPath + vcIndexModel.dp),
                        size: 24,
                      ),
                      title: Text(
                        vcIndexModel.name,
                        style: _sf.getMediumStyle(),
                      ),
                      subtitle: Text(
                        "Time : " +
                            time +
                            ", " +
                            get12HrTime(
                                context,
                                isRequest
                                    ? vcIndexModel.session_time
                                    : vcIndexModel.confirm_time),
                        style: _sf.getSmallStyle(color: Colors.grey[700]),
                      ),
                    ),
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  Future<List<VCIndexModel>> _callAPIForVCIndexModel() async {
    final result = await callGetAPI("vc-index", HashMap());
    final response = json.decode(result.toString());
    List<VCIndexModel> lst = [];
    if (response['status'] == 'success') {
      lst = VCIndexModel.getList(response['data']);
    }
    return lst;
  }

  void _openSession(VCIndexModel vcIndexModel) async {
    String chanelName = 'Swasthyasethu_${vcIndexModel.id}';

    // String chanelName =
    //     'Swasthyasethu_15';
    printToConsole("chanelName $chanelName");
    await _handleCameraAndMic(Permission.camera);
    await _handleCameraAndMic(Permission.microphone);
    // ClientRole role;
    if (vcIndexModel.event_id == null) {
      vcIndexModel.event_id = '';
    }
    printToConsole("vcIndexModel.event_id : ${vcIndexModel.event_id}");
    // if (vcIndexModel.event_id != 'null' && vcIndexModel.event_id.isNotEmpty) {
    //   SessionManager sessionManager = SessionManager.getInstance();
    //   printToConsole(
    //       "vcIndexModel.sender_id == sessionManager.getUserID() ${vcIndexModel.sender_id} == ${sessionManager.getUserID()}");

    // if (vcIndexModel.sender_id == sessionManager.getUserID()) {
    //   role = ClientRole.Broadcaster;
    // } else {
    //   role = ClientRole.Audience;
    // }
    // } else {
    //   role = ClientRole.Broadcaster;
    // }

    // navigateToPageWithoutScaffold(
    //   context,
    //   CallPage(
    //     channelName: chanelName,
    //     role: role,
    //   ),
    // );
  }

  bool _validateSession(VCIndexModel vcIndexModel) {
    if (vcIndexModel.event_id == null) {
      return true; //Live Session Request
    }
    if (vcIndexModel.event_id == 'null' || vcIndexModel.event_id.isEmpty) {
      return true; //Live Session Request
    }
    SessionManager manager = SessionManager.getInstance();
    if (manager.getUserID() == vcIndexModel.sender_id) {
      return true;
    }
    if (vcIndexModel.is_event_cost_paid) {
      return true;
    } else {
      _makePayment(vcIndexModel);
    }
    return false;
  }

  WalletUtil _walletUtil;

  void _makePayment(VCIndexModel vcIndexModel) {
    int amt = vcIndexModel.event_cost;
    if (vcIndexModel.is_booking_amout_paid) {
      amt -= vcIndexModel.event_booking_amount;
    }

    if (_walletUtil.balance >= amt) {
      _walletUtil.showPaymentSheet(
        context: context,
        title: "Booking of : " + vcIndexModel.name,
        amount: amt.toString(),
        sender_id: vcIndexModel.sender_id,
        id: vcIndexModel.id,
        type: 'LS',
        onSuccess: () {
          Navigator.of(context).pop();
          vcIndexModel.is_booking_amout_paid = true;
          vcIndexModel.is_event_cost_paid = true;
          _openSession(vcIndexModel);
        },
      );
    } else {
      showYesNoDialog(
        context,
        "Insufficient Wallet Balance",
        title: "Wallet",
        okText: "Add Money",
        okCall: () {
          _walletUtil.showAddMoneyBottomSheet(
            context: context,
            onSuccess: () {},
          );
        },
      );
    }
  }

  void _openRequestAction(VCIndexModel vcIndexModel) {
    navigateToPageWithoutScaffold(
        context,
        VcRequestActionPage(
          notificationId: '',
          vcRequestData: NotificationData(
            id: vcIndexModel.id,
            sender_id: vcIndexModel.sender_id,
            confirm_date: vcIndexModel.session_date,
            confirm_time: vcIndexModel.session_time,
            event_id: vcIndexModel.event_id,
            notes: vcIndexModel.notes,
            receiver_id: vcIndexModel.receiver_id,
            session_date: vcIndexModel.session_date,
            session_time: vcIndexModel.session_time,
            status: vcIndexModel.status,
          ),
        ), onBack: () {
      setState(() {});
      _post = _callAPIForVCIndexModel();
    });
  }
}
