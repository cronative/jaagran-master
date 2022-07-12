import 'dart:convert';

SearchUserModel searchUserModelFromJson(String str) => SearchUserModel.fromJson(json.decode(str));

class SearchUserModel {
  SearchUserModel({
    this.status,
    this.message,
    this.data,
  });

  String status;
  String message;
  Data data;

  factory SearchUserModel.fromJson(Map<String, dynamic> json) => SearchUserModel(
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
    this.title,
    this.name,
    this.roleId,
    this.dp,
    this.roleName,
  });

  String id;
  String title;
  String name;
  int roleId;
  String dp;
  String roleName;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"].toString().trim(),
    title: json["title"].toString().trim(),
    name: json["name"],
    roleId: json["role_id"],
    dp: json["dp"],
    roleName: json["role_name"],
  );

}
