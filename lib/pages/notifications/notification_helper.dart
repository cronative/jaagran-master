import 'dart:collection';
import 'dart:convert';

import 'package:jaagran/pages/chat/models/chat_index.dart';
import 'package:jaagran/pages/landing/model/seeking_model.dart';
import 'package:jaagran/pages/profile/model/profile_model.dart';
import 'package:jaagran/utils/web_utils.dart';

class NotificationHelper {
  Future<ProfileModel> getUserDataByUserId(String userId) async {
    HashMap params = HashMap();
    params['user_id'] = userId;
    final result = await callPostAPI("profile", params);
    final response = json.decode(result.toString());
    if (response['status'] == 'success') {
      ProfileModel model = ProfileModel.fromJson(response['data']);
      model.id = userId;
      return model;
    } else {
      // showErrorAlertDialog(context, response['message']);
      return null;
    }
  }

  Future<List<ChatIndex>> callChatIndex() async {
    final result = await callGetAPI("chat-index", HashMap());
    final response = json.decode(result.toString());
    List<ChatIndex> lstChatIndex = [];
    if (response['status'] == 'success') {
      lstChatIndex = ChatIndex.getList(response['message']);
    }
    return lstChatIndex;
  }

  Future<SeekingData> getSeekDetailsById(String seekID) async {
    final result = await callGetAPI("seek-detail/$seekID", HashMap());
    final response = json.decode(result.toString());
    if (response['status'] == 'success') {
      SeekingData seekingData = SeekingData.fromJson(response['data']['seek_details']);
      return seekingData;
    } else {
      return null;
    }
  }
}
