import 'package:get/state_manager.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';

class NotificationController extends GetxController {
  RxBool isNewNotification = false.obs;

  changeValue() async {
    isNewNotification.toggle();
    SessionManager manager = SessionManager.getInstance();
    manager.setIsNewNotification(isNewNotification.isTrue);
    printToConsole("changeValue : ${isNewNotification.isTrue}");
    update();
  }
}
