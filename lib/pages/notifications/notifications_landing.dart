import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/notification_controller/notification_controller.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/chat/chat_screen.dart';
import 'package:jaagran/pages/chat/group_chat_screen.dart';
import 'package:jaagran/pages/chat/models/chat_index.dart';
import 'package:jaagran/pages/chat/models/group_model.dart';
import 'package:jaagran/pages/chat/models/user_model.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/appbar/header_widget.dart';
import 'package:jaagran/pages/events/event_details.dart';
import 'package:jaagran/pages/follow/follower_page.dart';
import 'package:jaagran/pages/landing/model/seeking_model.dart';
import 'package:jaagran/pages/liveSessions/vc_confirm_page.dart';
import 'package:jaagran/pages/liveSessions/vc_request_action_page.dart';
import 'package:jaagran/pages/notifications/model/notification_model.dart';
import 'package:jaagran/pages/notifications/notification_helper.dart';
import 'package:jaagran/pages/profile/model/profile_model.dart';
import 'package:jaagran/pages/seeking/seek_details.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:jaagran/commons/session_manager.dart';

class NotificationsLanding extends StatefulWidget {
  @override
  _NotificationsLandingState createState() => _NotificationsLandingState();
}

class _NotificationsLandingState extends State<NotificationsLanding> {
  SizeConfig _sf;
  Future<List<NotificationModel>> _post;
  List<NotificationModel> lstNotifications = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final NotificationHelper notificationHelper = NotificationHelper();
  bool isApiCall = false;
  SessionManager sessionManager;
  final NotificationController _notificationController =
      Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    _post = _callGetNotificationList();
    _getSessionManager();
    Future.delayed(Duration(milliseconds: 500), () {
      printToConsole("_notificationController.isNewNotification.isTrue :${_notificationController.isNewNotification.isTrue}");
      if (_notificationController.isNewNotification.isTrue) {
        _notificationController.changeValue();
      }
    });
  }

  _getSessionManager() async {
    sessionManager = SessionManager.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      appBar: getCommonAppBar(context, _sf, isNotificationView: true),
      body: ModalProgressHUD(
        inAsyncCall: isApiCall,
        child: FutureBuilder(
          future: _post,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            // List<NotificationModel> lstNotification = snapshot.data;
            if (lstNotifications == null) {
              return _noData();
            }
            if (lstNotifications.isEmpty) {
              return _noData();
            }
            return Column(
              children: [
                HeaderWidget(
                  title: "Notifications",
                ),
                Expanded(
                  child: AnimatedList(
                    key: _listKey,
                    initialItemCount: lstNotifications.length,
                    itemBuilder: (BuildContext context, int index,
                        Animation<double> animation) {
                      return _notificationItemView(
                          lstNotifications[index], animation, index);
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _notificationItemView(NotificationModel notificationModel,
      Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        child: InkWell(
          onTap: () {
            _notificationAction(
              context,
              notificationModel,
              index,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: ListTile(
              tileColor: Colors.white,
              leading: Icon(Icons.notifications),
              title: Text(
                notificationModel.message_text,
                style: _sf.getMediumStyle(),
              ),
              trailing: GestureDetector(
                onTap: () async {
                  if (notificationModel.notification_type == 'chat_request') {
                    await _callChatRequestAction(notificationModel, "N", index);
                  } else if (notificationModel.notification_type ==
                      'group_request') {
                    await _callChatRequestAction(notificationModel, "N", index,
                        isGroupReq: true);
                  } else if (notificationModel.notification_type ==
                      'vc_request') {
                    bool isSuccess =
                        await _callCancelVcRequest(notificationModel);
                    if (!isSuccess) {
                      return;
                    }
                  }
                  _callAPIForDeleteNotification(notificationModel, index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _removeSingleItems(int removeIndex) {
    NotificationModel removedItem = lstNotifications.removeAt(removeIndex);
    AnimatedListRemovedItemBuilder builder = (context, animation) {
      return _notificationItemView(removedItem, animation, removeIndex);
    };
    _listKey.currentState.removeItem(removeIndex, builder);
  }

  Future<List<NotificationModel>> _callGetNotificationList() async {
    final result = await callGetAPI("notification-list", HashMap());
    final response = json.decode(result.toString());
    List<NotificationModel> lstNotification =
        NotificationModel.getList(response['data']);
    lstNotifications = lstNotification;
    return lstNotification;
  }

  Widget _noData() {
    return Center(
      child: Text(
        "You have no new notifications",
        style: _sf.getMediumStyle(),
      ),
    );
  }

  _notificationAction(BuildContext context, NotificationModel notificationModel,
      int index) async {
    // seek_like, seek_comment, comment_like, follow_user,
    // chat_msg, group_chat_msg, event, video, audio,
    // ebook, chat_request, group_request, vc_request, vc_modified_request

    switch (notificationModel.notification_type) {
      case 'seek_like':
        _openSeekDetails(notificationModel, index);
        break;
      case 'seek_comment':
        _openSeekDetails(notificationModel, index);
        break;
      case 'comment_like':
        _openSeekDetails(notificationModel, index);
        break;
      case 'follow_user':
        Navigator.of(context).pop();

        navigateToPageWithoutScaffold(context, FollowerPage());
        break;
      case 'event':
        Navigator.of(context).pop();

        navigateToPageWithoutScaffold(
          context,
          EventDetails(
            eventId: notificationModel.activity_detail_id,
          ),
        );
        break;
      case 'video':
        _openSeekDetails(notificationModel, index);
        break;
      case 'audio':
        _openSeekDetails(notificationModel, index);
        break;
      case 'ebook':
        _openSeekDetails(notificationModel, index);
        break;
      case 'group_chat_msg':
        setState(() {
          isApiCall = true;
        });
        List<ChatIndex> lstChatIndex = await notificationHelper.callChatIndex();
        setState(() {
          isApiCall = false;
        });
        if (lstChatIndex == null) return;
        if (lstChatIndex.isEmpty) return;
        ChatIndex chatGrp;
        lstChatIndex.forEach((element) {
          if (element.group_id == notificationModel.activity_detail_id) {
            chatGrp = element;
          }
        });
        if (chatGrp == null) return;
        Navigator.of(context).pop();
        navigateToPageWithoutScaffold(
            context,
            GroupChatScreen(
              groupModel: GroupModel(
                id: chatGrp.group_id,
                name: chatGrp.name,
                dp: getImageUrl(sessionManager.getDpPath() + chatGrp.dp),
              ),
              onGrpLeft: () {},
            ));
        _callAPIForDeleteNotification(notificationModel, index);
        break;
      case 'chat_msg':
        setState(() {
          isApiCall = true;
        });
        ProfileModel profileModel = await notificationHelper
            .getUserDataByUserId(notificationModel.sender_id);
        setState(() {
          isApiCall = false;
        });
        if (profileModel == null) return;
        Navigator.of(context).pop();
        navigateToPageWithoutScaffold(
            context,
            ChatScreen(
              user: ChatUser(
                id: notificationModel.sender_id,
                imageUrl:
                    getImageUrl(sessionManager.getDpPath() + profileModel.dp),
                name: profileModel.name,
              ),
            ));
        _callAPIForDeleteNotification(notificationModel, index);
        break;
      case 'chat_request':
        showYesNoDialog(
          context,
          notificationModel.message_text,
          title: "Chat Request",
          cancelCall: () {
            _callChatRequestAction(notificationModel, "N", index);
          },
          okCall: () {
            _callChatRequestAction(notificationModel, "Y", index);
          },
          okText: "accept",
          cancelText: "reject",
        );
        break;
      case 'group_request':
        showYesNoDialog(
          context,
          notificationModel.message_text,
          title: "Group Chat Request",
          cancelCall: () {
            _callChatRequestAction(notificationModel, "N", index,
                isGroupReq: true);
          },
          okCall: () {
            _callChatRequestAction(notificationModel, "Y", index,
                isGroupReq: true);
          },
          okText: "accept",
          cancelText: "reject",
        );
        break;
      case 'vc_request':
        Navigator.of(context).pop();
        navigateToPageWithoutScaffold(
          context,
          VcRequestActionPage(
            notificationId: notificationModel.id,
            vcRequestData: notificationModel.lstNotificationData[0],
          ),
        );
        break;
      case 'vc_modified_request':
        if (notificationModel.lstNotificationData.isEmpty) {
          return;
        }
        Navigator.of(context).pop();
        navigateToPageWithoutScaffold(
          context,
          VcConfirmPage(
            notificationId: notificationModel.id,
            vcRequestData: notificationModel.lstNotificationData[0],
          ),
        );
        break;
    }
  }

  _callChatRequestAction(
      NotificationModel notificationModel, String action, int index,
      {bool isGroupReq = false}) async {
    setState(() {
      isApiCall = true;
    });
    HashMap params = HashMap();
    params['status'] = action;
    if (!isGroupReq) {
      params['sender_id'] = notificationModel.sender_id;
    } else {
      params['group_id'] = notificationModel.activity_detail_id;
    }
    final result = await callPostAPI("chat-request-action", params);
    final response = json.decode(result.toString());
    setState(() {
      isApiCall = false;
    });
    if (response['status'] == 'success') {
      showSuccessAlertDialog(context, response['message']);
      _callAPIForDeleteNotification(notificationModel, index);
    } else {
      showErrorAlertDialog(context, response['message']);
    }
    return false;
  }

  _callAPIForDeleteNotification(NotificationModel notificationModel, int index,
      {bool callSetState = true}) async {
    setState(() {
      isApiCall = true;
    });
    HashMap params = HashMap();
    params['notification_id'] = notificationModel.id;
    final result = await callPostAPI("notification-delete", params);
    final response = json.decode(result.toString());
    setState(() {
      isApiCall = false;
    });
    if (response['status'] == 'success') {
      _removeSingleItems(index);
      setState(() {});
    }
  }

  void _openSeekDetails(NotificationModel notificationModel, int index) async {
    setState(() {
      isApiCall = true;
    });
    SeekingData seekingData = await notificationHelper
        .getSeekDetailsById(notificationModel.activity_detail_id);
    setState(() {
      isApiCall = false;
    });
    if (seekingData != null) {
      Navigator.of(context).pop();
      navigateToPageWithoutScaffold(
        context,
        SeekingDetails(
          seekingData,
          () {},
        ),
      );
    } else {
      showErrorAlertDialog(context, someThingWentWrong);
    }
  }

// void _callSeekDetails(String seekId) async {
//   setState(() {
//     isApiCall = true;
//   });
//   final result = await callGetAPI("seek-detail/${seekId}", HashMap());
//   final response = json.decode(result.toString());
//   SeekingData seekingData =
//       SeekingData.fromJson(response['data']['seek_details']);
//   setState(() {
//     isApiCall = false;
//   });
//   navigateToPageWithoutScaffold(
//       context,
//       SeekingDetails(
//         seekingData,
//         () {},
//       ));
//
// }

  Future<bool> _callCancelVcRequest(NotificationModel notificationModel) async {
    HashMap<String, String> params = HashMap();
    if(notificationModel.lstNotificationData.isEmpty){
      return true;
    }
    params['id'] = notificationModel.lstNotificationData[0].id;
    params['status'] = 'reject';
    params['confirm_date'] =
        notificationModel.lstNotificationData[0].session_date;
    params['confirm_time'] =
        notificationModel.lstNotificationData[0].session_time;
    final result = await callPostAPI("vc-request-action", params);
    final response = json.decode(result.toString());
    if (response['status'] == 'success') {
      showSuccessAlertDialog(context, response['message'], isCancelable: false,
          callback: () {
        return true;
      });
    } else {
      showErrorAlertDialog(context, response['message']);
      return false;
    }
    return false;
  }
}
