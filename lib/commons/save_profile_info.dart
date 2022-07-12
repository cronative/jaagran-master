import 'package:jaagran/commons/common_functions.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/pages/profile/model/profile_model.dart';

class SaveProfileInfo {
  SaveProfileInfo(String userId) {
    _callSaveProfileInfo(userId);
  }

  void _callSaveProfileInfo(String userId) async {
    SessionManager manager = SessionManager.getInstance();
    ProfileModel model = await getProfileById(userId);
    manager.putContactNumber(model.mobile);
  }
}
