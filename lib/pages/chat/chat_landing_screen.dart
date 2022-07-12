import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/chat/group_chat_screen.dart';
import 'package:jaagran/pages/chat/models/chat_index.dart';
import 'package:jaagran/pages/chat/models/group_model.dart';
import 'package:jaagran/pages/chat/models/user_model.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/appbar/header_widget.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'chat_screen.dart';
import 'create_chats_page.dart';

class ChatLandingScreen extends StatefulWidget {
  @override
  _ChatLandingScreenState createState() => _ChatLandingScreenState();
}

class _ChatLandingScreenState extends State<ChatLandingScreen> {
  SizeConfig _sf;
  Future<List<ChatIndex>> _post;
  String currentUserID;
  SessionManager sessionManager;

  @override
  void initState() {
    super.initState();
    _post = _callGetChatIndex();
    _getUserID();
  }

  _getUserID() async {
    sessionManager = SessionManager.getInstance();
    currentUserID = sessionManager.getUserID();
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      appBar: getCommonAppBar(context, _sf),
      body: Column(
        children: [
          HeaderWidget(
            title: "Chats",
          ),
          Padding(
            padding: EdgeInsets.all(_sf.scaleSize(6)),
            child: FutureBuilder(
                future: _post,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  List<ChatIndex> lstChatIndex = snapshot.data;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: lstChatIndex.length,
                    itemBuilder: (BuildContext context, int index) {
                      ChatIndex chatUser = lstChatIndex[index];
                      return Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ListTile(
                            onTap: () async {
                              bool isGroupChat = false;
                              if (chatUser.group_id == null) {
                                isGroupChat = true;
                              } else {
                                isGroupChat =
                                    chatUser.group_id.toLowerCase() != 'null' &&
                                        chatUser.group_id.isNotEmpty;
                              }
                              if (!isGroupChat) {
                                if (chatUser.isRequestAccepted) {
                                  navigateToPageWithoutScaffold(
                                      context,
                                      ChatScreen(
                                        user: ChatUser(
                                          id: _getId(chatUser),
                                          name: chatUser.name,
                                          imageUrl: chatUser.dp != null
                                              ? getImageUrl(
                                                  sessionManager.getDpPath() +
                                                      chatUser.dp)
                                              : "",
                                        ),
                                      ));
                                } else {
                                  showYesNoDialog(
                                    context,
                                    chatUser.name + " send you chat request",
                                    title: "Chat Request",
                                    cancelCall: () async {
                                      bool done = await _callChatRequestAction(
                                          _getId(chatUser), "N", index);
                                      _post = _callGetChatIndex();
                                    },
                                    okCall: () async {
                                      bool done = await _callChatRequestAction(
                                          _getId(chatUser), "Y", index);
                                      _post = _callGetChatIndex();
                                    },
                                    okText: "accept",
                                    cancelText: "reject",
                                  );
                                }
                              } else {
                                if (chatUser.isRequestAccepted) {
                                  navigateToPageWithoutScaffold(
                                      context,
                                      GroupChatScreen(
                                        groupModel: GroupModel(
                                          id: chatUser.group_id,
                                          name: chatUser.name,
                                          dp: getImageUrl(
                                              sessionManager.getDpPath() +
                                                  chatUser.dp),
                                        ),
                                        onGrpLeft: () {
                                          setState(() {});
                                          _post = _callGetChatIndex();
                                        },
                                      ));
                                } else {
                                  showYesNoDialog(
                                    context,
                                    chatUser.name +
                                        " group created join the group?",
                                    title: "Group Chat Request",
                                    cancelCall: () async {
                                      await _callChatRequestAction(
                                          chatUser.group_id, "N", index,
                                          isGroupReq: true);
                                      _post = _callGetChatIndex();
                                    },
                                    okCall: () async {
                                      await _callChatRequestAction(
                                          chatUser.group_id, "Y", index,
                                          isGroupReq: true);
                                      _post = _callGetChatIndex();
                                    },
                                    okText: "accept",
                                    cancelText: "reject",
                                  );
                                }
                              }
                            },
                            leading: CircleAvatar(
                              radius: _sf.scaleSize(20),
                              backgroundColor: Colors.transparent,
                              child: CircleAvatar(
                                radius: _sf.scaleSize(20),
                                backgroundImage: NetworkImage(
                                  getImageUrl(sessionManager.getDpPath() +
                                      lstChatIndex[index].dp),
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                              backgroundImage: AssetImage(
                                  "assets/images/dp_circular_avatar.png"),
                            ),
                            title: Text(
                              lstChatIndex[index].name,
                              style: _sf.getMediumStyle(),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        alignment: AlignmentDirectional.center,
        color: Theme.of(context).buttonColor,
        child: getNavButton(
          "Create Chats",
          _sf.getCaviarDreams(),
          () => navigateToPageWithoutScaffold(context, CreateChatsPage()),
          padding: EdgeInsets.symmetric(
            vertical: _sf.scaleSize(8),
            horizontal: _sf.scaleSize(20),
          ),
        ),
      ),
    );
  }

  Future<List<ChatIndex>> _callGetChatIndex() async {
    final result = await callGetAPI("chat-index", HashMap());
    final response = json.decode(result.toString());
    List<ChatIndex> lstChatIndex = [];
    if (response['status'] == 'success') {
      lstChatIndex = ChatIndex.getList(response['message']);
    }
    return lstChatIndex;
  }

  bool isApiCall;

  Future<bool> _callChatRequestAction(String id, String action, int index,
      {bool isGroupReq = false}) async {
    //id = sender_id / activity_detail_id
    setState(() {
      isApiCall = true;
    });
    HashMap params = HashMap();
    params['status'] = action;
    if (!isGroupReq) {
      params['sender_id'] = id;
    } else {
      params['group_id'] = id;
    }
    final result = await callPostAPI("chat-request-action", params);
    final response = json.decode(result.toString());
    setState(() {
      isApiCall = false;
    });
    if (response['status'] == 'success') {
      showSuccessAlertDialog(context, response['message']);
      return true;
    } else {
      showErrorAlertDialog(context, response['message']);
    }
    return false;
  }

  String _getId(ChatIndex chatUser) {
    if (chatUser.sender_id == currentUserID) {
      return chatUser.receiver_id;
    } else {
      return chatUser.sender_id;
    }
  }
}
