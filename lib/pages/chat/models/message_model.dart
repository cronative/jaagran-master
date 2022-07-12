import 'package:jaagran/pages/chat/models/user_model.dart';

class ChatMessage {
  // {\"command\":\"groupchat\",\"channel\":\"1\","
  // "\"user\":\"Dhana\",\"text\":\"test1\",\"from\":\"6\","
  // "\"to\":9,\"time\":\"10:24 pm\"}..

  String id;
  String reciver_name;
  String receiver_id;
  String reciver_dp;
  String created_at;
  String sender_name;
  String message;
  String sender_dp;
  String sender_id;

  ChatMessage({
    this.id,
    this.reciver_name,
    this.receiver_id,
    this.reciver_dp,
    this.created_at,
    this.sender_name,
    this.message,
    this.sender_dp,
    this.sender_id,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString().trim(),
      reciver_name: json['reciver_name'].toString().trim(),
      receiver_id: json['receiver_id'].toString().trim(),
      reciver_dp: json['reciver_dp'].toString().trim(),
      created_at: getCreatedAtTime(json['created_at'].toString().trim()),
      sender_name: json['sender_name'].toString().trim(),
      message: json['message'].toString().trim(),
      sender_dp: json['sender_dp'].toString().trim(),
      sender_id: json['sender_id'].toString().trim(),
    );
  }

  static getList(List<dynamic> jsonLst) {
    List<ChatMessage> lst = List();
    jsonLst.forEach((element) {
      lst.add(ChatMessage.fromJson(element));
    });
    return lst;
  }

  static String getCreatedAtTime(String str) {
    if (str == null) return '';
    if (str == 'null') return '';
    try {
      List<String> lstDate = str.split(' ');
      return lstDate[2] + ' ' + lstDate[3];
    } on Exception catch (e) {
      return '';
    }
  }
}
