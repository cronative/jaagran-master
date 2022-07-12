import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/chat/group_chat_request.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/appbar/header_widget.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:jaagran/commons/session_manager.dart';

import 'models/user_search_model.dart';

class CreateChatsPage extends StatefulWidget {
  @override
  _CreateChatsPageState createState() => _CreateChatsPageState();
}

class _CreateChatsPageState extends State<CreateChatsPage> {
  SizeConfig _sf;
  int _selectedValue = -1;
  TextEditingController _searchTextController = TextEditingController();
  String _selectedUserId = '';
  String _selectedUserName = '';
  bool isAsyncCall = false;
  bool isGroupSelected = false;

  updateAPICall(bool isAPICall) {
    setState(() {
      isAsyncCall = isAPICall;
    });
  }

  @override
  void initState() {
    // SystemChannels.textInput.invokeMethod('TextInput.hide');

    super.initState();
    // KeyboardVisibilityNotification().addNewListener(
    //   onChange: (bool visible) {
    //     printToConsole("KeyboardVisibilityNotification $visible");
    //     if(visible){
    //       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    //     }else{
    //       _scrollController.jumpTo(_scrollController.position.minScrollExtent);
    //     }
    //   },
    // );

    // FocusScope.of(context).unfocus();

    KeyboardVisibilityController().onChange.listen((bool visible) {
      printToConsole("KeyboardVisibilityNotification $visible");
      if (visible) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: getCommonAppBar(context, _sf),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: isAsyncCall,
        child: ListView(
          controller: _scrollController,
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              title: "Chat Request & Channel Creation",
            ),
            SizedBox(
              height: _sf.scaleSize(8),
            ),
            Padding(
              padding: EdgeInsets.all(_sf.scaleSize(20)),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Radio(
                      value: 0,
                      groupValue: _selectedValue,
                      onChanged: (val) {
                        setState(() {
                          isGroupSelected = false;
                          _selectedValue = val;
                        });
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedValue = 0;
                        isGroupSelected = false;
                      });
                    },
                    child: Text(
                      'One on One',
                      style: _sf.getLargeStyle(),
                    ),
                  ),
                  SizedBox(
                    width: _sf.scaleSize(32),
                  ),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Radio(
                      value: 1,
                      groupValue: _selectedValue,
                      onChanged: (val) {
                        setState(() {
                          _selectedValue = val;
                          isGroupSelected = true;
                        });
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isGroupSelected = true;
                        _selectedValue = 1;
                      });
                    },
                    child: Text(
                      'Group',
                      style: _sf.getLargeStyle(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_sf.scaleSize(20)),
              child: isGroupSelected
                  ? _getGroupRequestWidget()
                  : _getUserRequestWidget(),
            ),
            SizedBox(
              height: _sf.getScreenHeight() / 2.8,
            ),
          ],
        ),
      ),
    );
  }

  _callSearchAutoComplete(String pattern) async {
    if (_selectedUserName != _searchTextController.text) {
      _selectedUserId = '';
    }
    HashMap params = HashMap();
    params['search'] = pattern;
    final result = await callPostAPI("search-users", params);
    final response = json.decode(result.toString());

    List<UserSearchModel> listSuggestions =
        UserSearchModel.getList(response['data']);
    SessionManager sessionManager = SessionManager.getInstance();
    listSuggestions.removeWhere(
            (element) => element.id.trim() == sessionManager.getUserID().trim());
    List lst = List();
    listSuggestions.forEach((element) {
      lst.add({
        'name': element.name,
        'id': element.id,
      });
    });

    return lst;
  }

  void _callSendChatRequest() async {
    if (_selectedValue == -1) {
      showWarningDialog(
          context, "Please select chat type (One to One or Group)");
      return;
    }
    if (_selectedUserId.isEmpty) {
      showWarningDialog(context, "Please add participant");
      return;
    }
    setState(() {
      isAsyncCall = true;
    });
    HashMap params = HashMap();
    params['receiver_id'] = _selectedUserId;
    final result = await callPostAPI("chat-request", params);
    final response = json.decode(result.toString());
    setState(() {
      isAsyncCall = false;
    });
    if (response['status'] == 'success') {
      showSuccessAlertDialog(
        context,
        response['message'],
        isCancelable: false,
        callback: () {
          Navigator.of(context).pop();
        },
      );
    } else {
      showErrorAlertDialog(
        context,
        response['message'],
      );
    }
  }

  Widget _getUserRequestWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Add Participant',
              style: _sf.getMediumStyle(color: Theme.of(context).accentColor),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                height: _sf.scaleSize(40),
                child: Center(
                  child: TypeAheadField(
                    hideSuggestionsOnKeyboardHide: true,
                    hideOnError: true,
                    hideOnEmpty: true,
                    hideOnLoading: false,
                    loadingBuilder: (context) {
                      return Container(
                        height: 100,
                        padding: const EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    noItemsFoundBuilder: (context) {
                      return Container();
                    },
                    textFieldConfiguration: TextFieldConfiguration(
                        autofocus: false,
                        controller: _searchTextController,
                        style: _sf.getMediumStyle(),
                        decoration: InputDecoration(
                            hintText: "Search",
                            contentPadding: EdgeInsets.all(12),
                            hintStyle: _sf.getMediumStyle(
                                color: Theme.of(context).accentColor),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0),
                                borderSide: BorderSide.none))),
                    suggestionsCallback: (pattern) async {
                      if (pattern.length < 3) return List();
                      return await _callSearchAutoComplete(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion['name']),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      _searchTextController.text = suggestion['name'];
                      _selectedUserName = suggestion['name'];
                      _selectedUserId = suggestion['id'];
                      // if (_searchTextController.text.trim().length > 3)
                      //   _callSearch();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: _sf.scaleSize(24),
        ),
        // Row(
        //   mainAxisSize: MainAxisSize.max,
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Text(
        //       'Purpose',
        //       style: _sf.getMediumStyle(color: Theme.of(context).accentColor),
        //     ),
        //     SizedBox(
        //       width: 8,
        //     ),
        //     Expanded(
        //       child: Container(
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(12),
        //           color: Colors.grey[100],
        //         ),
        //         margin: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        //         child: Center(
        //             child: TextField(
        //           maxLines: 10,
        //           minLines: 10,
        //           decoration: InputDecoration(
        //             border: InputBorder.none,
        //             focusedBorder: InputBorder.none,
        //             enabledBorder: InputBorder.none,
        //             errorBorder: InputBorder.none,
        //             disabledBorder: InputBorder.none,
        //             contentPadding: EdgeInsets.only(
        //                 left: 15, bottom: 11, top: 11, right: 15),
        //           ),
        //           keyboardType: TextInputType.multiline,
        //         )),
        //       ),
        //     ),
        //   ],
        // ),
        SizedBox(
          height: _sf.scaleSize(40),
        ),
        Center(
          child: RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: () {
              _callSendChatRequest();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Send Chat Request",
                style: _sf.getMediumStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getGroupRequestWidget() {
    return GroupChatRequest(updateAPICall: updateAPICall);
  }
}
