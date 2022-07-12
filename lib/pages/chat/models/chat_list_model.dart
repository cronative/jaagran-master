import 'package:jaagran/pages/chat/models/message_model.dart';

class ChatListModel {
  int current_page;
  int last_page;
  int per_page;
  int total;
  List<ChatMessage> data;

  ChatListModel({
    this.current_page,
    this.last_page,
    this.per_page,
    this.total,
    this.data,
  });

  factory ChatListModel.fromJson(Map<String, dynamic> json){
    return ChatListModel(
        current_page :json['current_page'],
        last_page :json['last_page'],
        per_page :json['per_page'],
        total :json['total'],
      data: ChatMessage.getList(json['data']),
    );
  }
}
