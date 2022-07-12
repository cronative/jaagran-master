import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/common_functions.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';

import 'models/user_search_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class GroupChatRequest extends StatefulWidget {
  final Function(bool isAPICall) updateAPICall;

  const GroupChatRequest({
    this.updateAPICall,
  });

  @override
  _GroupChatRequestState createState() => _GroupChatRequestState();
}

class _GroupChatRequestState extends State<GroupChatRequest> {
  SizeConfig _sf;
  TextEditingController _searchTextController = TextEditingController();
  TextEditingController _grpNameTextController = TextEditingController();
  List<UserSearchModel> listSuggestions = [];

  List<UserSearchModel> _selectedUsers = [];
  FilePickerResult _profileImg;
  File _selectedImage;

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
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
              'Chat Group Name',
              style: _sf.getMediumStyle(color: Theme.of(context).accentColor),
            ),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                child: Center(
                    child: TextField(
                  controller: _grpNameTextController,
                  maxLines: 1,
                  minLines: 1,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                  ),
                  keyboardType: TextInputType.multiline,
                )),
              ),
            ),
          ],
        ),
        SizedBox(
          height: _sf.scaleSize(16),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Add Group Chat Icon',
              style: _sf.getMediumStyle(color: Theme.of(context).accentColor),
            ),
            SizedBox(
              width: _sf.scaleSize(20),
            ),
            InkWell(
              onTap: () async {
                _profileImg = await FilePicker.platform
                    .pickFiles(type: FileType.image, allowMultiple: false);
                setState(() {});
              },
              child: _profileImg == null
                  ? CircleAvatar(
                      radius: _sf.scaleSize(24),
                      backgroundImage:
                          AssetImage("assets/images/dp_circular_avatar.png"),
                      backgroundColor: Colors.transparent,
                    )
                  : _showPicture(),
            ),
          ],
        ),
        SizedBox(
          height: _sf.scaleSize(16),
        ),
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
                      _searchTextController.text = '';
                      _selectedUsers.add(listSuggestions[
                          listSuggestions.indexWhere((element) =>
                              element.name == suggestion['name'])]);
                      setState(() {});
                      // _selectedUserName = suggestion['name'];
                      // _selectedUserId = suggestion['id'];
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
          height: _sf.scaleSize(16),
        ),
        _selectedUsers.length != 0
            ? Container(
                height: 1,
                color: Colors.grey[200],
              )
            : Container(),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _selectedUsers.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Text(
                      _selectedUsers[index].name,
                      style: _sf.getMediumStyle(),
                    )),
                    InkWell(
                      onTap: () {
                        _selectedUsers.remove(_selectedUsers[index]);
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  color: Colors.grey[200],
                ),
              ],
            );
          },
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
          height: _sf.scaleSize(30),
        ),
        Center(
          child: RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onPressed: () {
              _callSendGroupChatRequest();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Send Group Chat Invitation",
                style: _sf.getMediumStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(
          height: _sf.scaleSize(30),
        ),
      ],
    );
  }

  _callSearchAutoComplete(String pattern) async {
    HashMap params = HashMap();
    params['search'] = pattern;
    final result = await callPostAPI("search-users", params);
    final response = json.decode(result.toString());

    listSuggestions = UserSearchModel.getList(response['data']);
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

  _showPicture() {
    _selectedImage = File(_profileImg.files.single.path);
    return CircleAvatar(
      radius: _sf.scaleSize(24),
      backgroundImage: FileImage(
        _selectedImage,
      ),
    );
  }

  void _callSendGroupChatRequest() async {
    String groupName = _grpNameTextController.text.trim();
    if (groupName.isEmpty) {
      showWarningDialog(context, "Please enter group name");
      return;
    }
    String userIds = _getCommaSepratedIds();
    if (userIds.isEmpty) {
      showWarningDialog(context, "Please add users");
      return;
    }
    if (_selectedImage == null) {
      showWarningDialog(context, "Please add group icon");
      return;
    }
    SessionManager manager = SessionManager.getInstance();
    widget.updateAPICall.call(true);
    var postUri = Uri.parse(API_URL + "create-chat-group");
    var request = http.MultipartRequest("POST", postUri);
    request.headers['Authorization'] = manager.getAuthToken();
    request.fields["group_name"] = groupName;
    SessionManager sessionManager = SessionManager.getInstance();
    request.fields["group_users"] = sessionManager.getUserID()+","+userIds;
    _selectedImage = await compressImage(_selectedImage);

    request.files.add(await http.MultipartFile.fromPath(
      'group_icon',
      _selectedImage.path,
      contentType: MediaType('image', _getType(_selectedImage.path)),
    ));

    printToConsole("multipart url : " + postUri.toString());
    request.send().then((response) async {
      String res = await response.stream.bytesToString();
      printToConsole("responce : ${res}");
      final result = json.decode(res);
      widget.updateAPICall.call(false);
      if (result['status'] == 'success') {
        showSuccessAlertDialog(context, result['message'], isCancelable: false,
            callback: () {
          Navigator.of(context).pop();
        });
      } else {
        showErrorAlertDialog(context, result['message']);
      }
    });
  }

  String _getType(String path) {
    List<String> lstStr = path.split(".");
    return lstStr[lstStr.length - 1];
  }

  String _getCommaSepratedIds() {
    String ids = '';
    bool isFirst = true;
    _selectedUsers.forEach((element) {
      if (isFirst) {
        isFirst = false;
      } else {
        ids += ',';
      }
      ids += element.id;
    });
    return ids;
  }
}
