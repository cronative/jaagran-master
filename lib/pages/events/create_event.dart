import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'model/links_model.dart';

class CreateEvent extends StatefulWidget {
  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  int currentStep = 0;
  SizeConfig _sf;
  bool _isApiCall = false;
  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _byController = TextEditingController();
  TextEditingController _courseDurationController = TextEditingController();
  TextEditingController _isVirtualController = TextEditingController();
  TextEditingController _venueController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileNameController = TextEditingController();
  TextEditingController _eventDetailsController = TextEditingController();
  TextEditingController _costController = TextEditingController();
  TextEditingController _bookingAmtController = TextEditingController();
  TextEditingController _footNoteController = TextEditingController();
  TextEditingController _link1NameController = TextEditingController();
  TextEditingController _link1UrlController = TextEditingController();
  TextEditingController _link2NameController = TextEditingController();
  TextEditingController _link2UrlController = TextEditingController();
  TextEditingController _link3NameController = TextEditingController();
  TextEditingController _link3UrlController = TextEditingController();
  Color accentColor;
  String fromTime = "From Time";
  String toTime = "To Time";
  String fromDate = "From Date*";
  String toDate = "To Date";

  TimeOfDay _selectedFromTime;
  TimeOfDay _selectedToTime;
  DateTime _selectedFromDate;
  DateTime _selectedToDate;

  FilePickerResult _profileImg;
  File _selectedImage;
  bool isVirtualEvent = false;

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    accentColor = Theme.of(context).accentColor;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: getCommonAppBar(context, SizeConfig.getInstance(context)),
      body: ModalProgressHUD(
        inAsyncCall: _isApiCall,
        child: ListView(
          children: [
            Container(
              alignment: AlignmentDirectional.center,
              color: Colors.white,
              padding: EdgeInsets.only(
                  bottom: _sf.scaleSize(16), top: _sf.scaleSize(16)),
              child: Text(
                "Create an Events",
                style: _sf.getLargeStyle(color: accentColor),
              ),
            ),
            Stepper(
              steps: [
                Step(
                  title: Text("Step 1"),
                  content: Column(
                    children: [
                      TextField(
                        controller: _eventNameController,
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.text,
                        style: _sf.getMediumStyle(),
                        maxLengthEnforced: true,
                        textCapitalization: TextCapitalization.sentences,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(100),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter Event Name*',
                          filled: true,
                          fillColor: Theme.of(context).hintColor,
                          hintStyle: _sf.getSmallStyle(color: accentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                      SizedBox(
                        height: _sf.scaleSize(16),
                      ),
                      TextField(
                        controller: _byController,
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.text,
                        style: _sf.getMediumStyle(),
                        textCapitalization: TextCapitalization.sentences,
                        maxLengthEnforced: true,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(100),
                        ],
                        decoration: InputDecoration(
                          hintText: 'By*',
                          filled: true,
                          fillColor: Theme.of(context).hintColor,
                          hintStyle: _sf.getSmallStyle(color: accentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                      SizedBox(
                        height: _sf.scaleSize(16),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              _selectedFromDate = await _selectDate();
                              if (_selectedToDate != null) {
                                if (_selectedToDate
                                    .isBefore(_selectedFromDate)) {
                                  _selectedToDate = null;
                                  toDate = "To Date";
                                }
                              }
                              DateFormat dateFormat = DateFormat("yyyy-MM-dd");

                              String date =
                                  dateFormat.format(_selectedFromDate);
                              setState(() {
                                fromDate = date;
                              });
                            },
                            child: Container(
                              width: _sf.getScreenWidth() / 2.7,
                              height: 50,
                              padding: EdgeInsets.only(left: 8, right: 8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white, width: 0.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  color: Theme.of(context).hintColor),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.date_range,
                                      color: accentColor,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      fromDate,
                                      style:
                                          _sf.getSmallStyle(color: accentColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (_selectedFromDate == null) {
                                showWarningDialog(
                                    context, "Please select from date first");
                                return;
                              }

                              _selectedToDate = await _selectDate();

                              if (_selectedToDate.isBefore(_selectedFromDate)) {
                                showWarningDialog(context,
                                    "To date should be greater that from date");
                                return;
                              }
                              DateFormat dateFormat = DateFormat("yyyy-MM-dd");

                              String date = dateFormat.format(_selectedToDate);
                              setState(() {
                                toDate = date;
                              });
                            },
                            child: Container(
                              width: _sf.getScreenWidth() / 2.7,
                              height: 50,
                              padding: EdgeInsets.only(left: 8, right: 8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white, width: 0.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  color: Theme.of(context).hintColor),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.date_range,
                                      color: accentColor,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      toDate,
                                      style:
                                          _sf.getSmallStyle(color: accentColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: _sf.scaleSize(16),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              _selectedFromTime = await _selectTime();
                              if (_selectedToTime != null) {
                                if (_convertToMinutes(_selectedToTime) <=
                                    _convertToMinutes(_selectedFromTime)) {
                                  _selectedToTime = null;
                                  toTime = "To Time";
                                } else {
                                  _calculateDuration();
                                }
                              }
                              if (_selectedFromTime != null) {
                                final MaterialLocalizations localizations =
                                    MaterialLocalizations.of(context);
                                final String formattedTimeOfDay = localizations
                                    .formatTimeOfDay(_selectedFromTime);
                                String time = formattedTimeOfDay;
                                setState(() {
                                  fromTime = time;
                                });
                              }
                            },
                            child: Container(
                              width: _sf.getScreenWidth() / 2.7,
                              height: 50,
                              padding: EdgeInsets.only(left: 8, right: 8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white, width: 0.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  color: Theme.of(context).hintColor),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.watch_later_outlined,
                                      color: accentColor,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      isVirtualEvent
                                          ? fromTime + '*'
                                          : fromTime,
                                      style:
                                          _sf.getSmallStyle(color: accentColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (_selectedFromTime == null) {
                                showWarningDialog(
                                    context, "Please select from time first");
                                return;
                              }
                              _selectedToTime = await _selectTime();
                              if (_selectedToTime != null) {
                                if (_convertToMinutes(_selectedToTime) <=
                                    _convertToMinutes(_selectedFromTime)) {
                                  showWarningDialog(context,
                                      "From time should be greater than to time");
                                  return;
                                }
                                final MaterialLocalizations localizations =
                                    MaterialLocalizations.of(context);
                                final String formattedTimeOfDay = localizations
                                    .formatTimeOfDay(_selectedToTime);
                                String time = formattedTimeOfDay;
                                _calculateDuration();
                                setState(() {
                                  toTime = time;
                                });
                              }
                            },
                            child: Container(
                              width: _sf.getScreenWidth() / 2.7,
                              height: 50,
                              padding: EdgeInsets.only(left: 8, right: 8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white, width: 0.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  color: Theme.of(context).hintColor),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.watch_later_outlined,
                                      color: accentColor,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      toTime,
                                      style:
                                          _sf.getSmallStyle(color: accentColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: _sf.scaleSize(16),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: _sf.getScreenWidth() / 2.7,
                            child: TextField(
                              controller: _courseDurationController,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              style: _sf.getMediumStyle(),
                              maxLengthEnforced: true,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(5),
                              ],
                              decoration: InputDecoration(
                                hintText: isVirtualEvent
                                    ? 'Duration(Hours)'
                                    : 'Duration(Hours)*',
                                filled: true,
                                fillColor: Theme.of(context).hintColor,
                                hintStyle:
                                    _sf.getSmallStyle(color: accentColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                            ),
                          ),
                          Container(
                            width: _sf.getScreenWidth() / 2.7,
                            child: TextField(
                              controller: _isVirtualController,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.text,
                              style: _sf.getMediumStyle(),
                              onChanged: (str) {
                                setState(() {
                                  isVirtualEvent =
                                      str.toLowerCase().trim() == 'y';
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Virtual (Y/N)*',
                                filled: true,
                                fillColor: Theme.of(context).hintColor,
                                hintStyle:
                                    _sf.getSmallStyle(color: accentColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: _sf.scaleSize(16),
                      ),
                      TextField(
                        controller: _venueController,
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        style: _sf.getMediumStyle(),
                        maxLengthEnforced: true,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(100),
                        ],
                        maxLines: 3,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Venue*',
                          filled: true,
                          fillColor: Theme.of(context).hintColor,
                          hintStyle: _sf.getSmallStyle(color: accentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                      SizedBox(
                        height: _sf.scaleSize(16),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: _sf.getScreenWidth() / 2.7,
                            child: TextField(
                              controller: _emailController,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.emailAddress,
                              style: _sf.getMediumStyle(),
                              maxLengthEnforced: true,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(100),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Email*',
                                filled: true,
                                fillColor: Theme.of(context).hintColor,
                                hintStyle:
                                    _sf.getSmallStyle(color: accentColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                            ),
                          ),
                          Container(
                            width: _sf.getScreenWidth() / 2.7,
                            child: TextField(
                              controller: _mobileNameController,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.number,
                              style: _sf.getMediumStyle(),
                              maxLengthEnforced: true,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Mobile*',
                                filled: true,
                                fillColor: Theme.of(context).hintColor,
                                hintStyle:
                                    _sf.getSmallStyle(color: accentColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  isActive: currentStep == 0,
                ),
                Step(
                  title: Text("Step 2"),
                  content: Column(
                    children: [
                      TextField(
                        controller: _eventDetailsController,
                        textAlign: TextAlign.start,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        style: _sf.getMediumStyle(),
                        textCapitalization: TextCapitalization.sentences,
                        maxLengthEnforced: true,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(1000),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Event Details*',
                          filled: true,
                          fillColor: Theme.of(context).hintColor,
                          hintStyle: _sf.getSmallStyle(color: accentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                      SizedBox(
                        height: _sf.scaleSize(16),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: _sf.getScreenWidth() / 2.7,
                            child: TextField(
                              controller: _costController,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.number,
                              style: _sf.getMediumStyle(),
                              maxLengthEnforced: true,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(7),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Cost',
                                filled: true,
                                fillColor: Theme.of(context).hintColor,
                                hintStyle:
                                    _sf.getSmallStyle(color: accentColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                            ),
                          ),
                          Container(
                            width: _sf.getScreenWidth() / 2.7,
                            child: TextField(
                              controller: _bookingAmtController,
                              textAlign: TextAlign.start,
                              keyboardType: TextInputType.number,
                              style: _sf.getMediumStyle(),
                              maxLengthEnforced: true,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(7),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Booking Amt.',
                                filled: true,
                                fillColor: Theme.of(context).hintColor,
                                hintStyle:
                                    _sf.getSmallStyle(color: accentColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: _sf.scaleSize(16),
                      ),
                      TextField(
                        controller: _footNoteController,
                        textAlign: TextAlign.start,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 3,
                        style: _sf.getMediumStyle(),
                        maxLengthEnforced: true,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(150),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Footnote',
                          filled: true,
                          fillColor: Theme.of(context).hintColor,
                          hintStyle: _sf.getSmallStyle(color: accentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                  isActive: currentStep == 1,
                ),
                Step(
                  title: Text("Step 3"),
                  content: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Attachments",
                              style: _sf.getLargeStyle(color: accentColor),
                            ),
                            _getFileWidget(),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              "Link 1 Name : ",
                              style: _sf.getSmallStyle(color: accentColor),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                              height: 30,
                              width: _sf.getScreenWidth() / 2.2,
                              child: TextField(
                                controller: _link1NameController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                maxLines: 1,
                                style: _sf.getSmallStyle(),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: -12, horizontal: 8),
                                ),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              "Link URL        : ",
                              style: _sf.getSmallStyle(color: accentColor),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                              height: 30,
                              width: _sf.getScreenWidth() / 2.2,
                              child: TextField(
                                controller: _link1UrlController,
                                maxLines: 1,
                                style: _sf.getSmallStyle(),
                                maxLengthEnforced: true,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(100),
                                ],
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: -12, horizontal: 8),
                                ),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              "Link 2 Name : ",
                              style: _sf.getSmallStyle(color: accentColor),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                              height: 30,
                              width: _sf.getScreenWidth() / 2.2,
                              child: TextField(
                                controller: _link2NameController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                maxLines: 1,
                                maxLengthEnforced: true,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(100),
                                ],
                                style: _sf.getSmallStyle(),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: -12, horizontal: 8),
                                ),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              "Link URL        : ",
                              style: _sf.getSmallStyle(color: accentColor),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                              height: 30,
                              width: _sf.getScreenWidth() / 2.2,
                              child: TextField(
                                controller: _link2UrlController,
                                maxLines: 1,
                                maxLengthEnforced: true,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(100),
                                ],
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: -12, horizontal: 8),
                                ),
                                style: _sf.getSmallStyle(),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              "Link 3 Name : ",
                              style: _sf.getSmallStyle(color: accentColor),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                              height: 30,
                              width: _sf.getScreenWidth() / 2.2,
                              child: TextField(
                                controller: _link3NameController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                maxLines: 1,
                                maxLengthEnforced: true,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(100),
                                ],
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: -12, horizontal: 8),
                                ),
                                style: _sf.getSmallStyle(),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Text(
                              "Link URL        : ",
                              style: _sf.getSmallStyle(color: accentColor),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                              height: 30,
                              width: _sf.getScreenWidth() / 2.2,
                              child: TextField(
                                controller: _link3UrlController,
                                maxLines: 1,
                                maxLengthEnforced: true,
                                inputFormatters: <TextInputFormatter>[
                                  LengthLimitingTextInputFormatter(100),
                                ],
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: -12, horizontal: 8),
                                ),
                                style: _sf.getSmallStyle(),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: _sf.scaleSize(8),
                      ),
                    ],
                  ),
                  isActive: currentStep == 2,
                ),
              ],
              onStepContinue: () {
                if (currentStep == 2) {
                  _callCreateEvent();
                } else {
                  setState(() {
                    currentStep++;
                  });
                }
              },
              onStepCancel: () {
                if (currentStep == 0) {
                  Navigator.of(context).pop();
                } else {
                  setState(() {
                    currentStep--;
                  });
                }
              },
              onStepTapped: (tap) {
                setState(() {
                  currentStep = tap;
                });
              },
              currentStep: currentStep,
              type: StepperType.vertical,
              physics: ClampingScrollPhysics(),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime> _selectDate() async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    return picked;
  }

  Future<TimeOfDay> _selectTime() async {
    TimeOfDay time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    return time;
  }

  void _callCreateEvent() async {
    //step0
    String eventName = _eventNameController.text.trim();
    String eventBy = _byController.text.trim();
    String courseDuration = _courseDurationController.text.trim();
    String isVirtual = _isVirtualController.text.trim().toUpperCase();
    String venue = _venueController.text.trim();
    String email = _emailController.text.trim();
    String mobile = _mobileNameController.text.trim();

    if (eventName.isEmpty) {
      showWarningDialog(context, "Please enter event name");
      setState(() {
        currentStep = 0;
      });
      return;
    }
    if (eventBy.isEmpty) {
      showWarningDialog(context, "Please enter event by");
      setState(() {
        currentStep = 0;
      });
      return;
    }
    if (fromDate == "From Date*") {
      showWarningDialog(context, "Please select from date");
      setState(() {
        currentStep = 0;
      });
      return;
    }

    if (isVirtualEvent && fromTime == "From Time") {
      showWarningDialog(context, "Please select from time");
      setState(() {
        currentStep = 0;
      });
      return;
    }
    if (fromTime == "From Time") {
      fromTime = "";
    }
    if (toTime == "To Time") {
      toTime = "";
    }
    if (courseDuration.isEmpty) {
      showWarningDialog(context, "Please enter course duration");
      setState(() {
        currentStep = 0;
      });
      return;
    }
    if (isVirtual.isEmpty || !(isVirtual == "Y" || isVirtual == "N")) {
      showWarningDialog(context, "Please enter Virtual (Y/N)");
      setState(() {
        currentStep = 0;
      });
      return;
    }

    if (venue.isEmpty) {
      showWarningDialog(context, "Please enter event venue");
      setState(() {
        currentStep = 0;
      });
      return;
    }

    if (email.isEmpty) {
      showWarningDialog(context, "Please enter email address");
      setState(() {
        currentStep = 0;
      });
      return;
    }

    if (mobile.isEmpty) {
      showWarningDialog(context, "Please enter mobile number");
      setState(() {
        currentStep = 0;
      });
      return;
    }
    if (toDate == "To Date") {
      toDate = fromDate;
    }
    //step1
    String eventDetails = _eventDetailsController.text.trim();
    String cost = _costController.text.trim();
    String bookingAmt = _bookingAmtController.text.trim();
    String footNotes = _footNoteController.text.trim();

    if (eventDetails.isEmpty) {
      showWarningDialog(context, "Please enter event details");
      setState(() {
        currentStep = 1;
      });
      return;
    }

    // if (eventDetails.isEmpty) {
    //   showWarningDialog(context, "Please enter event details");
    //   setState(() {
    //     currentStep = 1;
    //   });
    //   return;
    // }
    // if (eventDetails.isEmpty) {
    //   showWarningDialog(context, "Please enter event details");
    //   setState(() {
    //     currentStep = 1;
    //   });
    //   return;
    // }
    // if (eventDetails.isEmpty) {
    //   showWarningDialog(context, "Please enter event details");
    //   setState(() {
    //     currentStep = 1;
    //   });
    //   return;
    // }

    // if (_selectedImage == null) {
    //   showWarningDialog(context, "Please select event photo");
    //   setState(() {
    //     currentStep = 2;
    //   });
    //   return;
    // }
    //step2
    String link1Name = _link1NameController.text.trim();
    String link1Url = _link1UrlController.text.trim();
    String link2Name = _link2NameController.text.trim();
    String link2Url = _link2UrlController.text.trim();
    String link3Name = _link3NameController.text.trim();
    String link3Url = _link3UrlController.text.trim();

    List<LinkModel> lstLinks = List();
    if (link1Name.isNotEmpty && link1Url.isNotEmpty)
      lstLinks.add(LinkModel(link1Name, link1Url));
    if (link2Name.isNotEmpty && link2Url.isNotEmpty)
      lstLinks.add(LinkModel(link2Name, link2Url));
    if (link3Name.isNotEmpty && link3Url.isNotEmpty)
      lstLinks.add(LinkModel(link3Name, link3Url));

    var postUri = Uri.parse(API_URL + "create-event");
    var request = new http.MultipartRequest("POST", postUri);

    request.fields['title'] = eventName;
    request.fields['event_detail'] = eventDetails;
    request.fields['event_by'] = eventBy;
    request.fields['start_date'] = fromDate;
    request.fields['start_time'] = _getTime(_selectedFromTime);
    request.fields['event_virtual'] = isVirtual;
    request.fields['venue'] = venue;
    request.fields['event_email'] = email;
    request.fields['event_mobile'] = mobile;
    request.fields['course_hours'] = courseDuration;
    request.fields['end_date'] = toDate;
    request.fields['end_time'] = _getTime(_selectedToTime);
    request.fields['event_cost'] = cost;
    request.fields['event_booking_amount'] = bookingAmt;
    request.fields['event_footnotes'] = footNotes;
    request.fields['links'] = _getJson(lstLinks);

    printToConsole("links ${request.fields['links']}");
    // params['attachments'] = courseDuration;//tmp
    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'attachments',
        _selectedImage.path,
        contentType: MediaType('image', _getType(_selectedImage.path)),
      ));
    }
    Map<String, String> map = HashMap();
    SessionManager manager = SessionManager.getInstance();

    map["Authorization"] = manager.getAuthToken();
    map["Accept"] = "application/json";
    request.headers.addAll(map);

    setState(() {
      _isApiCall = true;
    });

    request.send().then((response) async {
      String res = await response.stream.bytesToString();
      printToConsole("responce : ${res}");
      final result = json.decode(res);
      if (result['status'] == 'success') {
        showSuccessAlertDialog(context, result['message'], isCancelable: false,
            callback: () {
          Navigator.of(context).pop();
        });
      } else {
        showErrorAlertDialog(
          context,
          result['message'],
          isCancelable: false,
        );
      }
      setState(() {
        _isApiCall = false;
      });
    });
  }

  int _convertToMinutes(TimeOfDay time) {
    int min = (time.hour * 60) + time.minute;
    printToConsole("$min");
    return min;
  }

  void _calculateDuration() {
    if (_selectedToTime != null && _selectedFromTime != null) {
      int minutes = _convertToMinutes(_selectedToTime) -
          _convertToMinutes(_selectedFromTime);
      int hours = (minutes / 60).round();
      _courseDurationController.text = "$hours";
    }
  }

  String _getType(String path) {
    List<String> lstStr = path.split(".");
    return lstStr[lstStr.length - 1];
  }

  String _getJson(List<LinkModel> lstLinks) {
    String json =
        jsonEncode(lstLinks.map((i) => i.toJson()).toList()).toString();
    return json;
  }

  String _getTime(TimeOfDay time) {
    if (time == null) {
      return "";
    } else {
      return "${time.hour}:${time.minute}:00";
    }
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
                  "Photo",
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
