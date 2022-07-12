import 'dart:convert';

WalletHistory walletHistoryFromJson(String str) => WalletHistory.fromJson(json.decode(str));

class WalletHistory {
  WalletHistory({
    this.status,
    this.message,
    this.data,
    this.userUpdatedWallet,
  });

  String status;
  String message;
  Data data;
  int userUpdatedWallet;

  factory WalletHistory.fromJson(Map<String, dynamic> json) => WalletHistory(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
    userUpdatedWallet: json["user_updated_wallet"],
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
  List<WalletHistoryModel> data;
  int lastPage;
  int perPage;
  int total;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentPage: json["current_page"],
    data: List<WalletHistoryModel>.from(json["data"].map((x) => WalletHistoryModel.fromJson(x))),
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
  );
}

class WalletHistoryModel {
  WalletHistoryModel({
    this.id,
    this.userId,
    this.activityId,
    this.activityType,
    this.transectionType,
    this.amount,
    this.title,
    this.createdAt,
  });

  int id;
  int userId;
  int activityId;
  String activityType;
  String title;
  String transectionType;
  int amount;
  DateTime createdAt;

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) => WalletHistoryModel(
    id: json["id"],
    userId: json["user_id"],
    activityId: json["activity_id"],
    activityType: json["activity_type"],
    title: json["title"],
    transectionType: json["transection_type"],
    amount: json["amount"],
    createdAt: DateTime.parse(json["created_at"]),
  );

}
