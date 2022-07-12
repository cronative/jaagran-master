import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_functions.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/wallet/wallet_util.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'model/event_details_mode.dart';

class EventDetails extends StatefulWidget {
  final String eventId;

  const EventDetails({Key key, this.eventId}) : super(key: key);

  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  Future<EventDetailsModel> _post;
  bool isApiCall = false;
  SizeConfig _sf;
  bool _isVirtualEvent = false;
  bool _eventBookingDone = false;
  EventDetailsModel _eventDetails;
  WalletUtil _walletUtil;

  @override
  void initState() {
    super.initState();
    _walletUtil = WalletUtil();
    _post = _getEventDetails();
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: getCommonAppBar(context, SizeConfig.getInstance(context)),
      bottomNavigationBar: _isVirtualEvent
          ? _eventBookingDone
              ? Container(
                  height: 60,
                  alignment: AlignmentDirectional.center,
                  color: Theme.of(context).buttonColor,
                  child: Text(
                    "You are registered for this event",
                    style: _sf.getMediumStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              : Container(
                  height: 60,
                  alignment: AlignmentDirectional.center,
                  color: Theme.of(context).buttonColor,
                  child: getNavButton("Register", _sf.getCaviarDreams(), () {
                    _checkPayment();
                    // _callRegisterEventAPI();
                  }),
                  padding: EdgeInsets.symmetric(
                    vertical: _sf.scaleSize(8),
                    horizontal: _sf.scaleSize(20),
                  ),
                )
          : Container(),
      body: ModalProgressHUD(
        inAsyncCall: isApiCall,
        child: ListView(
          children: [
            Container(
              alignment: AlignmentDirectional.center,
              color: Colors.white,
              padding: EdgeInsets.only(
                  bottom: _sf.scaleSize(16), top: _sf.scaleSize(16)),
              child: Text(
                "Events",
                style: _sf.getLargeStyle(color: Theme.of(context).accentColor),
              ),
            ),
            FutureBuilder(
              future: _post,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                      height: _sf.getScreenHeight() - _sf.scaleSize(120),
                      child: Center(child: CircularProgressIndicator()));
                }
                EventDetailsModel eventDetails = snapshot.data;
                _eventDetails = eventDetails;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventDetails.title,
                        style: _sf.getLargeStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Image.network(getEventsImagePath(eventDetails.media_id)),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        eventDetails.description,
                        style: _sf.getMediumStyle(),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        "By : ${eventDetails.user_by}",
                        style: _sf.getSmallStyle(),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "DateTime : ${_getDateTime(eventDetails)}",
                        style: _sf.getSmallStyle(),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Virtual : ${eventDetails.event_virtual}",
                        style: _sf.getSmallStyle(),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Venue : ${eventDetails.venue}",
                        style: _sf.getSmallStyle(),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Footnote : ${eventDetails.event_footnotes}",
                        style: _sf.getSmallStyle(),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      _checkIsEmpty(eventDetails.event_booking_amount)
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "Booking Amount : ${eventDetails.event_booking_amount}",
                                style: _sf.getSmallStyle(),
                              ),
                            ),

                      _checkIsEmpty(eventDetails.event_cost)
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "Event Cost : ${eventDetails.event_cost}",
                                style: _sf.getSmallStyle(),
                              ),
                            ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "CONTACT : ${eventDetails.event_mobile}",
                        style: _sf.getSmallStyle(),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "EMAIL : ${eventDetails.event_email}",
                        style: _sf.getSmallStyle(),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text(
                        "Links :",
                        style: _sf.getSmallStyle(),
                      ),
                      // SizedBox(
                      //   height: 8,
                      // ),
                      _getLinks(eventDetails.links),
                      SizedBox(
                        height: 24,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<EventDetailsModel> _getEventDetails() async {
    final result =
        await callGetAPI("event-detail/${widget.eventId}", HashMap());
    final response = json.decode(result.toString());
    if (response['status'] == 'success') {
      EventDetailsModel model =
          EventDetailsModel.fromJson(response['data']['event_details']);
      if (model.event_virtual.toLowerCase() == 'y') {
        setState(() {
          _isVirtualEvent = true;
        });
      }
      SessionManager _manager = SessionManager.getInstance();
      if (model.user_id == _manager.getUserID()) {
        _eventBookingDone = true;
      } else {
        _eventBookingDone = model.is_booking_amout_paid;
      }
      setState(() {});
      return model;
    } else {
      showErrorAlertDialog(context, response['message']);
      return null;
    }
  }

  _getLinks(List<EventLink> links) {
    return Wrap(
      direction: Axis.horizontal,
      children: [
        for (int i = 0; i < links.length; i++)
          InkWell(
            onTap: () {
              launchURL(links[i].url);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 32,
              ),
              child: Text(
                links[i].name,
                style: _sf.getSmallStyle(
                    color: Theme.of(context).accentColor,
                    decoration: TextDecoration.underline),
              ),
            ),
          ),
      ],
    );
  }

  String _getDateTime(EventDetailsModel eventDetails) {
    String date = '';
    if (eventDetails.event_start_date == eventDetails.event_end_date ||
        eventDetails.event_end_date == null ||
        eventDetails.event_end_date == 'null' ||
        eventDetails.event_end_date.isEmpty) {
      date = eventDetails.event_start_date;
    } else {
      date =
          eventDetails.event_start_date + " to " + eventDetails.event_end_date;
    }
    String time = '';
    if (eventDetails.event_start_time == eventDetails.event_end_time ||
        eventDetails.event_end_time == null ||
        eventDetails.event_end_time == 'null' ||
        eventDetails.event_end_time.isEmpty) {
      time = eventDetails.event_start_time;
    } else {
      time = get12HrTime(context, eventDetails.event_start_time) +
          " to " +
          get12HrTime(context, eventDetails.event_end_time);
    }

    return date + ', ' + time;
  }

  _checkPayment() {
    int bookingAmt = 0;
    try {
      bookingAmt = int.parse(_eventDetails.event_booking_amount);
    } on Exception catch (e) {
      bookingAmt = 0;
    }
    if (bookingAmt == 0) {
      _callRegisterEventAPI();
    }
    if (_walletUtil.balance >= bookingAmt) {
      _walletUtil.showPaymentSheet(
        context: context,
        title: "Booking of : " + _eventDetails.title,
        amount: _eventDetails.event_booking_amount,
        sender_id: _eventDetails.user_id,
        id: _eventDetails.id,
        type: 'LS',
        onSuccess: () {
          Navigator.of(context).pop();
          _callRegisterEventAPI();
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

  void _callRegisterEventAPI() async {
    setState(() {
      isApiCall = true;
    });
    HashMap<String, String> params = HashMap();
    params['event_id'] = _eventDetails.id;

    final result = await callPostAPI("event-register", params);
    final response = json.decode(result.toString());
    if (response['status'] == 'success') {
      _eventBookingDone = true;
      showSuccessAlertDialog(context, response['message']);
      setState(() {});
    } else {
      showErrorAlertDialog(context, response['message']);
    }
    setState(() {
      isApiCall = false;
    });
  }

  _checkIsEmpty(String str) {
    if (str == null) return true;
    if (str == 'null') return true;
    if (str.isEmpty) return true;
    return false;
  }
}
