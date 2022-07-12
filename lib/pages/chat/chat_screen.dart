import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/chat/models/chat_list_model.dart';
import 'package:jaagran/pages/chat/socket_utils.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';

import 'models/message_model.dart';
import 'models/user_model.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  ChatScreen({this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  SocketUtils socketUtils;
  List<ChatMessage> lstChatMessages = [];
  SizeConfig _sf;
  ChatListModel chatListModel;

  @override
  void initState() {
    super.initState();
    socketUtils = SocketUtils();
    _addUserToSocketChat();
    _getChatHistory();
  }

  _getChatHistory() async {
    HashMap<String, String> params = HashMap();
    params['reciver_id'] = widget.user.id;
    final result = await callPostAPI("chat-history", params);
    final response = json.decode(result.toString());
    if (response['status'] == 'success') {
      chatListModel = ChatListModel.fromJson(response['data']);
      lstChatMessages = chatListModel.data;
    } else {
      lstChatMessages = [];
    }

    setState(() {});
  }

  _addUserToSocketChat() {
    SessionManager manager = SessionManager.getInstance();
    String currentUserID = manager.getUserID();
    print(currentUserID);
    print('currentUserID');
    socketUtils.addUserForChat(manager.getUserName(), currentUserID);
  }

  _buildMessage(ChatMessage message, bool isMe) {
    final Container msg = Container(
      margin: EdgeInsets.only(
        top: 4.0,
        bottom: 4.0,
      ),
      padding: EdgeInsets.symmetric(
          horizontal: _sf.scaleSize(16), vertical: _sf.scaleSize(8)),
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).hintColor : Color(0xFFFFEFEE),
        borderRadius: isMe
            ? BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
              )
            : BorderRadius.only(
                topRight: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            message.message,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Container(
            height: 20,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                message.created_at,
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          // SizedBox(height: 8.0),
        ],
      ),
    );
    if (isMe) {
      return Align(
        child: msg,
        alignment: Alignment.centerRight,
      );
    }
    return Align(
      child: msg,
      alignment: Alignment.centerLeft,
    );
  }

  TextEditingController _chatTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          widget.user.name,
          style: _sf.getLargeStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_horiz),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    child: new StreamBuilder(
                      stream: socketUtils.channel.stream,
                      builder: (context, snapshot) {
                        printToConsole(
                            "snapshot.data.toString(): ${snapshot.data.toString()}");
                        if (snapshot.hasData) {
                          try {
                            if (snapshot.hasData.toString() != '[]') {
                              var jsonMsg =
                                  json.decode(snapshot.data.toString());
                              printToConsole("jsonMsg: $jsonMsg");
                              if (jsonMsg.isNotEmpty) {
                                if (jsonMsg['text'] != null) {
                                  ChatMessage msg = ChatMessage(
                                    created_at:
                                        jsonMsg['time'].toString().trim(),
                                    message: jsonMsg['text'].toString().trim(),
                                    sender_id:
                                        jsonMsg['from'].toString().trim(),
                                    sender_name:
                                        jsonMsg['user'].toString().trim(),
                                    receiver_id:
                                        jsonMsg['to'].toString().trim(),
                                  );
                                  lstChatMessages.insert(0, msg);
                                }
                              }
                            }
                          } on Exception catch (e) {
                            // TODO
                          }
                        }

                        return ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.only(top: 15.0),
                          itemCount: lstChatMessages.length,
                          itemBuilder: (BuildContext context, int index) {
                            // return Container();
                            final ChatMessage message = lstChatMessages[index];

                            return _buildMessage(
                                message, message.sender_id != widget.user.id);
                          },
                        );
                        // return new Padding(
                        //   padding: const EdgeInsets.all(0.0),
                        //   child: new Text(snapshot.hasData
                        //       ? '${snapshot.data.toString()}'
                        //       : ''),
                        // );
                      },
                    )
                    // StreamBuilder(
                    //   stream: socketUtils.channel.stream,
                    //   builder: (BuildContext context,
                    //       AsyncSnapshot<dynamic> snapshot) {
                    //     printToConsole(
                    //         "snapshot.connectionState :${snapshot.connectionState.toString()}");

                    //     printToConsole(
                    //         "snapshot.data.toString(): ${snapshot.data.toString()}");
                    //     if (snapshot.hasData) {
                    //       try {
                    //         if (snapshot.hasData.toString() != '[]') {
                    //           var jsonMsg = json.decode(snapshot.data.toString());
                    //           if (jsonMsg.isNotEmpty) {
                    //             if (jsonMsg['text'] != null) {
                    //               ChatMessage msg = ChatMessage(
                    //                 created_at: jsonMsg['time'].toString().trim(),
                    //                 message: jsonMsg['text'].toString().trim(),
                    //                 sender_id: jsonMsg['from'].toString().trim(),
                    //                 sender_name:
                    //                     jsonMsg['user'].toString().trim(),
                    //                 receiver_id: jsonMsg['to'].toString().trim(),
                    //               );
                    //               lstChatMessages.insert(0, msg);
                    //             }
                    //           }
                    //         }
                    //       } on Exception catch (e) {
                    //         // TODO
                    //       }
                    //     }
                    //     return ListView.builder(
                    //       reverse: true,
                    //       padding: EdgeInsets.only(top: 15.0),
                    //       itemCount: lstChatMessages.length,
                    //       itemBuilder: (BuildContext context, int index) {
                    //         // return Container();
                    //         final ChatMessage message = lstChatMessages[index];

                    //         return _buildMessage(
                    //             message, message.sender_id != widget.user.id);
                    //       },
                    //     );
                    //   },
                    // ),
                    ),
              ),
            ),
          ),
          Container(
            height: 4,
            color: Colors.white,
          ),
          Container(
            height: 1,
            color: Colors.grey[100],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            // height: 70.0,
            color: Colors.white,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 24,
                ),
                Expanded(
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: _chatTextController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Send a message...',
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    printToConsole("send button click");
                    String msg = _chatTextController.text.trim();
                    if (msg.isEmpty) return;
                    _sendMessage(msg);
                    ChatMessage chatMsg = ChatMessage(
                      created_at: DateFormat('hh:mm a').format(DateTime.now()),
                      message: msg,
                      sender_id: socketUtils.userID,
                      sender_name: socketUtils.userName,
                      receiver_id: widget.user.id,
                    );

                    lstChatMessages.insert(0, chatMsg);
                    _chatTextController.text = '';
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.send_sharp,
                      size: _sf.scaleSize(24),
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socketUtils.channel.sink.close();
    super.dispose();
  }

  void _sendMessage(String message) {
    print("Send Chat");
    socketUtils.sendMessageChat(message, widget.user.id);
  }
}
