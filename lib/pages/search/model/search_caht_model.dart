import 'dart:convert';

SearchChatModel searchChatModelFromJson(String str) => SearchChatModel.fromJson(json.decode(str));
class SearchChatModel {
  SearchChatModel({
    this.status,
    this.message,
    this.data,
  });

  String status;
  String message;
  Data data;

  factory SearchChatModel.fromJson(Map<String, dynamic> json) => SearchChatModel(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );
}

class Data {
  Data({
    this.currentPage,
    this.data,
    this.lastPage,
    this.perPage,
    this.total,
  });

  int currentPage;
  List<Datum> data;
  int lastPage;
  int perPage;
  int total;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentPage: json["current_page"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
  );
}

class Datum {
  Datum({
    this.id,
    this.groupId,
    this.receiverId,
    this.senderId,
    this.requestApprove,
    this.name,
    this.dp,
  });

  String id;
  int groupId;
  int receiverId;
  int senderId;
  String requestApprove;
  String name;
  String dp;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"].toString().trim(),
    groupId: json["group_id"] == null ? null : json["group_id"],
    receiverId: json["receiver_id"],
    senderId: json["sender_id"],
    requestApprove: json["request_approve"] == null ? null : json["request_approve"],
    name: json["name"],
    dp: json["dp"],
  );
}
