import 'package:get_storage/get_storage.dart';
import 'package:jaagran/pages/common/model/login_model.dart';

class SessionManager {
  static SessionManager _manager;

  // static SharedPreferences _prefs;
  static GetStorage _storage;

  static SessionManager getInstance() {
    // if (_manager == null || _prefs == null) {
    // _prefs = await SharedPreferences.getInstance();

    if (_manager == null || _storage == null) {
      _manager = SessionManager();
      _storage = GetStorage();
    }
    return _manager;
  }

  void saveUserData(String email, String pass, LoginData data) {
    _storage.write("KEY_IS_USER_LOGIN", true);
    _storage.write("KEY_USER_NAME", data.name);
    _storage.write("KEY_AUTH_TOKEN", "Bearer " + data.auth_token);
    _storage.write("KEY_DP", data.dp);
    _storage.write("KEY_USER_ID", data.id);
    _storage.write("KEY_IS_EXPERT", data.isExpert);
    _storage.write("KEY_USER_EMAIL", email);
    _storage.write("KEY_USER_PASS", pass);
  }

  String getUserEmail() {
    return _storage.read("KEY_USER_EMAIL") ?? "";
  }

  bool getIsExpert() {
    return _storage.read("KEY_IS_EXPERT") ?? false;
  }

  String getUserPassword() {
    return _storage.read("KEY_USER_PASS") ?? "";
  }

  bool getIsUserLogin() {
    return _storage.read("KEY_IS_USER_LOGIN") ?? false;
  }

  String getUserName() {
    return _storage.read("KEY_USER_NAME") ?? "";
  }

  String getAuthToken() {
    return _storage.read("KEY_AUTH_TOKEN") ?? "";
  }

  String getUserDP() {
    return _storage.read("KEY_DP") ?? "";
  }

  String getUserID() {
    return _storage.read("KEY_USER_ID") ?? "0";
  }

  void setExpertiseResponse(String response) {
    _storage.write("KEY_EXPERTISE_RES", response);
  }

  String getExpertiseResponse() {
    return _storage.read("KEY_EXPERTISE_RES") ?? "";
  }

  void clearAllData() {
    _storage.erase();
  }

  void putDpPath(String path) {
    _storage.write("KEY_DP_STORAGE", path);
  }

  String getDpPath() {
    return _storage.read("KEY_DP_STORAGE") ?? "";
  }

  void putEventPath(String path) {
    _storage.write("KEY_EVENT_STORAGE", path);
  }

  String getEventPath() {
    return _storage.read("KEY_EVENT_STORAGE") ?? "";
  }

  void putAddsPath(String path) {
    _storage.write("KEY_Adds_STORAGE", path);
  }

  String getAddsPath() {
    return _storage.read("KEY_Adds_STORAGE") ?? "";
  }

  void putVideoPath(String path) {
    _storage.write("KEY_VIDEO_STORAGE", path);
  }

  String getVideoPath() {
    return _storage.read("KEY_VIDEO_STORAGE") ?? "";
  }

  void putAudioPath(String path) {
    _storage.write("KEY_AUDIO_STORAGE", path);
  }

  String getAudioPath() {
    return _storage.read("KEY_AUDIO_STORAGE") ?? "";
  }

  void putEBookPath(String path) {
    _storage.write("KEY_EBOOK_STORAGE", path);
  }

  void putFeedbackCategory(String feedback_category) {
    _storage.write("KEY_FEEDBACK_CATEGORY", feedback_category);
  }

  void putDummyData(String data) {
    _storage.write("putDummyData", data);
  }

  List<String> getFeedbackCategories() {
    List<String> lst = List();
    String cat = _storage.read("KEY_FEEDBACK_CATEGORY") ?? "";
    lst = cat.split(",");
    return lst;
  }

  String getEBookPath() {
    return _storage.read("KEY_EBOOK_STORAGE") ?? "";
  }

  void putVCAppId(String appId) {
    _storage.write("KEY_VC_APP_ID", appId);
  }

  String getVCAppId() {
    return _storage.read("KEY_VC_APP_ID") ?? "037249b399e74d45bacad142a2778270";
  }

  bool getIsNewNotification() {
    return _storage.read("KEY_NEW_NOTIFICATION") ?? false;
  }

  void setIsNewNotification(bool val) {
    _storage.write("KEY_NEW_NOTIFICATION", val);
  }

  void putRazorPayKey(String key) {
    _storage.write("KEY_Razor_Pay", key);
  }

  String getRazorPayKey() {
    return _storage.read("KEY_Razor_Pay") ?? "rzp_live_wciasRjJtTH7OQ";
  }

  void putContactNumber(String mobile) {
    _storage.write("KEY_MOBILE", mobile);
  }

  String getContactNumber() {
    return _storage.read("KEY_MOBILE") ?? "";
  }

  void putLastWalletBal(int bal) {
    _storage.write("KEY_WALLET_BAL", bal);
  }

  int getLastWalletBal() {
    return _storage.read("KEY_WALLET_BAL") ?? 0;
  }
}
