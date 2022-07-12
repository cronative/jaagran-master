import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaagran/commons/notification_controller/notification_controller.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/utils/size_config.dart';

class NotificationIcon extends StatelessWidget {
  // final NotificationController _notificationController =
  //     Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    SizeConfig _sf = SizeConfig.getInstance(context);

    return GetBuilder<NotificationController>(
      builder: (GetxController controller) {
        NotificationController notificationController = controller;
        print(controller);
        bool isNewNotification = controller == null
            ? true
            : notificationController.isNewNotification.isTrue;
        return Container(
          alignment: AlignmentDirectional.center,
          padding: EdgeInsets.only(left: 2, right: 2),
          child: Container(
            height: _sf.scaleSize(26),
            width: _sf.scaleSize(26),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications,
                  size: _sf.scaleSize(26),
                  color: Colors.white,
                ),
                isNewNotification == null
                    ? Container()
                    : isNewNotification
                        ? Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: _sf.scaleSize(10),
                            ),
                          )
                        : Container(),
              ],
            ),
          ),
        );
      },
    );
    // return StreamBuilder(
    //   stream: _notificationController.isNewNotification.stream,
    //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    //     printToConsole("NotificationIcon snapshot.data ${snapshot.data}");
    //     // bool isNewNotification = snapshot.data ?? false;
    //     // printToConsole("isNewNotification $isNewNotification");
    //     return FutureBuilder<bool>(
    //       future: _checkNewNotification(),
    //       builder:
    //           (BuildContext context, AsyncSnapshot<bool> isNewNotification) {
    //         return ;
    //       },
    //     );
    //   },
    // );
  }

  Future<bool> _checkNewNotification() async {
    SessionManager manager = SessionManager.getInstance();
    bool isNewNotification = manager.getIsNewNotification();
    printToConsole("_checkNewNotification call $isNewNotification");

    return isNewNotification;
  }
}
