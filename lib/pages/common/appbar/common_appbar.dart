import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaagran/commons/notification_controller/notification_controller.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/chat/chat_landing_screen.dart';
import 'package:jaagran/pages/common/appbar/user_overlay_view.dart';
import 'package:jaagran/pages/events/event_list.dart';
import 'package:jaagran/pages/feedback/feedback_page.dart';
import 'package:jaagran/pages/follow/follower_page.dart';
import 'package:jaagran/pages/follow/following_page.dart';
import 'package:jaagran/pages/libraries/libraries_page.dart';
import 'package:jaagran/pages/notifications/notifications_landing.dart';
import 'package:jaagran/pages/profile/profile_page.dart';
import 'package:jaagran/pages/search/search_view.dart';
import 'package:jaagran/pages/uploads/upload_page.dart';
import 'package:jaagran/pages/liveSessions/live_sessions_landing.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';

import 'notification_icon.dart';

AppBar getCommonAppBar(BuildContext context, SizeConfig _sf,
    {bool isSearchView = false, bool isNotificationView = false}) {
  OverlayEntry _overLayEntry;
  return AppBar(
    title: Container(
      height: _sf.scaleSize(30),
      child: Image.asset(
        "assets/images/banner_logo.jpeg",
        fit: BoxFit.fitHeight,
      ),
    ),
    // leading: InkWell(
    //   onTap: (){
    //     Navigator.of(context).pop();
    //   },
    //   child: Align(
    //     alignment: Alignment.centerRight,
    //     child: Icon(Icons.arrow_back_ios),
    //   ),
    // ),

    leadingWidth: _sf.scaleSize(32),
    actions: [
      isSearchView
          ? Container()
          : InkWell(
              onTap: () {
                navigateToPageWithoutScaffold(context, SearchView(),
                    isBottomTop: true);
              },
              child: Container(
                alignment: AlignmentDirectional.center,
                padding: EdgeInsets.only(left: 2, right: 2),
                child: Icon(
                  Icons.search,
                  size: _sf.scaleSize(26),
                  color: Colors.white,
                ),
              ),
            ),
      isNotificationView
          ? Container()
          : InkWell(
              onTap: () {
                navigateToPageWithoutScaffold(context, NotificationsLanding(),
                    isBottomTop: true);
              },
              child: NotificationIcon(),
            ),
      InkWell(
        onTap: () async {
          _overLayEntry = await createUserOverlayEntry(
            context,
            () {
              _overLayEntry?.remove();
            },
            () async {
              //profile click
              _overLayEntry?.remove();
              // _removeStack(context);
              SessionManager manager = SessionManager.getInstance();
              navigateToPageWithoutScaffold(
                  context,
                  ProfilePage(
                    user_id: manager.getUserID(),
                    isSelf: true,
                  ));
            },
          );
          Overlay.of(context).insert(_overLayEntry);
        },
        child: Container(
          alignment: AlignmentDirectional.center,
          padding: EdgeInsets.only(left: 4),
          child: FutureBuilder<String>(
            future: _getUserDp(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                String dp = snapshot.data.toString().trim();
                // printToConsole("user dp : $dp");
                if (dp.isNotEmpty) {
                  return CircleAvatar(
                    radius: _sf.scaleSize(15),
                    backgroundImage:
                        AssetImage("assets/images/dp_circular_avatar.png"),
                    backgroundColor: Colors.transparent,
                    child: CircleAvatar(
                      radius: _sf.scaleSize(15),
                      backgroundImage: NetworkImage(
                        dp,
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  );
                }
              }
              return CircleAvatar(
                radius: _sf.scaleSize(15),
                backgroundImage:
                    AssetImage("assets/images/dp_circular_avatar.png"),
                backgroundColor: Colors.transparent,
              );
            },
          ),
        ),
      ),
      Container(
        alignment: AlignmentDirectional.center,
        width: _sf.scaleSize(32),
        child: PopupMenuButton<String>(
          color: Theme.of(context).buttonColor,
          onSelected: (val) {
            handleClick(context, val);
          },
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          itemBuilder: (BuildContext context) {
            return {
              'Seeking',
              'Library',
              'Events',
              'Chats',
              'Live Sessions',
              // 'Search',
              'Followers',
              'Following',
              'Uploads',
              // 'Wallets',
              'Feedback',
            }.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(
                  choice,
                  style: _sf.getMediumStyle(color: Colors.white),
                ),
              );
            }).toList();
          },
        ),
      ),
    ],
  );
}

Future<String> _getUserDp() async {
  SessionManager manager = SessionManager.getInstance();
  String dp = manager.getUserDP();
  if (dp.isEmpty || dp == "null") return "";
  return Server_URL + manager.getDpPath() + dp;
}

void handleClick(BuildContext context, String value) async {
  switch (value) {
    case "Seeking":
      _removeStack(context);
      break;
    case "Library":
      _removeStack(context);
      navigateToPageWithoutScaffold(context, LibrariesPage());
      break;
    case "Events":
      _removeStack(context);
      navigateToPageWithoutScaffold(context, EventList());
      break;
    case "Chats":
      _removeStack(context);
      navigateToPageWithoutScaffold(context, ChatLandingScreen());
      break;
    case "Live Sessions":
      _removeStack(context);
      navigateToPageWithoutScaffold(context, LiveSessionsLandingPage());
      break;
    case "Followers":
      _removeStack(context);
      navigateToPageWithoutScaffold(context, FollowerPage());
      break;
    case "Following":
      _removeStack(context);
      navigateToPageWithoutScaffold(context, FollowingPage());
      break;
    case "Uploads":
      _removeStack(context);
      navigateToPageWithoutScaffold(context, UploadPage());
      break;
    // case "Wallets":
    //   break;
    case "Feedback":
      _removeStack(context);
      navigateToPageWithoutScaffold(context, FeedbackPage());
      break;
  }
}

_removeStack(BuildContext context) {
  Navigator.of(context).popUntil(ModalRoute.withName("/landing"));
}
