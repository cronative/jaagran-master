

class LoginModel {
  String status;
  String message;
  LoginData data;


  LoginModel({
    this.status,
    this.message,
    this.data,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json["status"].toString().trim(),
      message: json["message"].toString().trim(),
      data: json["status"].toString().trim() == "success"
          ? LoginData.fromJson(json["data"])
          : null,
    );
  }
}

class LoginData {
  String auth_token;
  String name;
  String id;
  String dp;
  bool isExpert;

  LoginData({
    this.auth_token,
    this.name,
    this.id,
    this.dp,
    this.isExpert,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      auth_token: json["auth_token"].toString().trim(),
      name: json["name"].toString().trim(),
      id: json["id"].toString().trim(),
      dp: json["dp"].toString().trim(),
      isExpert: !json["user_type"].toString().toLowerCase().contains("user"),
    );
  }
}
