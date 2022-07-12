import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/commons/widgets/common_circular_image.dart';
import 'package:jaagran/pages/chat/models/group_model.dart';
import 'package:jaagran/pages/chat/models/user_search_model.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'models/group_member.dart';

class GroupMembersScreen extends StatefulWidget {
  final String userID;
  final GroupModel groupModel;

  const GroupMembersScreen({Key key, this.userID, this.groupModel})
      : super(key: key);

  @override
  _GroupMembersScreenState createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  SizeConfig _sf;
  Future<List<GroupMemberModel>> _post;
  String dpPath = '';
  bool isAdmin = false;
  bool isAPICall = false;
  bool addMemberToGrpCall = false;
  TextEditingController _searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _post = _callAPIForGroupMembers();
    _getSessionManager();
  }

  _getSessionManager() async {
    SessionManager sessionManager = SessionManager.getInstance();
    dpPath = Server_URL + sessionManager.getDpPath();
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupModel.name,
          style: _sf.getLargeStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isAPICall,
        child: Container(
          padding: EdgeInsets.all(16),
          child: FutureBuilder(
            future: _post,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                List<GroupMemberModel> lstMembers = snapshot.data;
                return ListView.builder(
                  itemCount: lstMembers.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == lstMembers.length) {
                      return isAdmin
                          ? addMemberToGrpCall
                              ? _addMemberView()
                              : Card(
                                  child: ListTile(
                                    onTap: () {
                                      setState(() {
                                        addMemberToGrpCall = true;
                                      });
                                    },
                                    title: Text(
                                      "+ Add member to group",
                                      style: _sf.getMediumStyle(
                                          color: Theme.of(context).accentColor),
                                    ),
                                  ),
                                )
                          : Container(
                              width: 0,
                              height: 0,
                            );
                    }
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ListTile(
                          leading: CommonCircularAvatar(
                            url: dpPath + lstMembers[index].dp,
                            size: 24,
                          ),
                          title: Text(
                            lstMembers[index].name,
                            style: _sf.getMediumStyle(),
                          ),
                          trailing: lstMembers[index].is_admin
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      bottom: _sf.scaleSize(20)),
                                  child: Container(
                                    padding: EdgeInsets.all(_sf.scaleSize(2)),
                                    decoration: BoxDecoration(
                                        // color: Colors.grey[100],
                                        // shape: BoxShape.rectangle,
                                        border: Border.all(
                                            color:
                                                Theme.of(context).accentColor,
                                            width: 1),
                                        borderRadius:
                                            BorderRadius.circular(6)),
                                    child: Text(
                                      "Group Admin",
                                      style: _sf.getExtraExtraSmallStyle(
                                        fontSize: _sf.scaleSize(8),
                                        color: Theme.of(context).accentColor,
                                      ),
                                    ),
                                  ),
                                )
                              : isAdmin
                                  ? GestureDetector(
                                      onTap: () {
                                        showYesNoDialog(
                                          context,
                                          "Are you sure you want to remove ${lstMembers[index].name} from group?",
                                          title: 'Remove member?',
                                          okText: 'Yes',
                                          okCall: () {
                                            _callAPIForRemoveGroupMember(
                                                lstMembers[index].receiver_id);
                                          },
                                          cancelText: 'No',
                                          cancelCall: () {},
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(Icons.close_rounded),
                                      ),
                                    )
                                  : Container(
                                      width: 0,
                                      height: 0,
                                    ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<List<GroupMemberModel>> _callAPIForGroupMembers() async {
    HashMap<String, String> params = HashMap();
    params['group_id'] = widget.groupModel.id;
    final result = await callPostAPI("group-members", params);
    final response = json.decode(result.toString());
    List<GroupMemberModel> lst = [];
    if (response['status'] == 'success') {
      lst = GroupMemberModel.getList(response['data']);
    }
    lst.forEach((element) {
      if (element.is_admin) {
        isAdmin = element.receiver_id == widget.userID;
      }
    });
    return lst;
  }

  _callAPIForRemoveGroupMember(String id) async {
    setState(() {
      isAPICall = true;
    });
    HashMap<String, String> params = HashMap();
    params['group_id'] = widget.groupModel.id;
    params['remove_user_id'] = id;
    final result = await callPostAPI("remove-from-group", params);
    final response = json.decode(result.toString());
    if (response['status'] == 'success') {}
    setState(() {
      isAPICall = false;
    });
    _post = _callAPIForGroupMembers();
  }

  _callAPIForAddGroupMember(String id) async {
    setState(() {
      isAPICall = true;
    });
    HashMap<String, String> params = HashMap();
    params['group_id'] = widget.groupModel.id;
    params['add_user_id'] = id;
    final result = await callPostAPI("add-group-member", params);

    final response = json.decode(result.toString());
    if (response['status'] == 'success') {
      showSuccessAlertDialog(context, response['message'], isCancelable: false,
          callback: () {
        setState(() {
          isAPICall = false;
          addMemberToGrpCall = false;
        });
      });
    } else {
      showErrorAlertDialog(context, response['message'], isCancelable: false,
          callback: () {
        setState(() {
          isAPICall = false;
        });
      });
    }
  }

  _addMemberView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              child: InkWell(
                onTap: () {
                  setState(() {
                    addMemberToGrpCall = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              alignment: Alignment.centerRight,
            ),
            SizedBox(
              height: 8,
            ),
            Container(
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
                      autofocus: true,
                      controller: _searchTextController,
                      style: _sf.getMediumStyle(),
                      decoration: InputDecoration(
                          hintText: "Search Member",
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
            SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(10)),
                  onPressed: () {
                    if (_selectedUserId.isEmpty) {
                      showWarningDialog(context, "Please select member!");
                      return;
                    }
                    _callAPIForAddGroupMember(_selectedUserId);
                  },
                  child: Text(
                    'Add',
                    style: _sf.getMediumStyle(color: Colors.white),
                  ),
                ),
                alignment: Alignment.centerRight,
              ),
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  String _selectedUserName = '';
  String _selectedUserId = '';

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
    List lst = List();
    listSuggestions.forEach((element) {
      lst.add({
        'name': element.name,
        'id': element.id,
      });
    });
    return lst;
  }
}
