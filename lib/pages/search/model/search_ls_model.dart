import 'dart:convert';

SearchLsModel searchLsModelFromJson(String str) => SearchLsModel.fromJson(json.decode(str));

class SearchLsModel {
  SearchLsModel({
    this.status,
    this.message,
    this.data,
  });

  String status;
  String message;
  Data data;

  factory SearchLsModel.fromJson(Map<String, dynamic> json) => SearchLsModel(
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
    this.senderId,
    this.receiverId,
    this.eventId,
    this.notes,
    this.sessionDate,
    this.sessionTime,
    this.confirmDate,
    this.confirmTime,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.dp,
  });

  String id;
  String senderId;
  String receiverId;
  String eventId;
  String notes;
  DateTime sessionDate;
  String sessionTime;
  DateTime confirmDate;
  String confirmTime;
  String status;
  DateTime createdAt;
  DateTime updatedAt;
  String name;
  String dp;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"].toString().trim(),
    senderId: json["sender_id"].toString().trim(),
    receiverId: json["receiver_id"].toString().trim(),
    eventId: json["event_id"] == null ? null : json["event_id"].toString().trim(),
    notes: json["notes"],
    sessionDate: DateTime.parse(json["session_date"]),
    sessionTime: json["session_time"],
    confirmDate: DateTime.parse(json["confirm_date"]),
    confirmTime: json["confirm_time"],
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    name: json["name"],
    dp: json["dp"],
  );


}
