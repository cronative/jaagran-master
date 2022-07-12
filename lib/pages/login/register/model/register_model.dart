class RegisterModel {
  String status;
  String message;

  RegisterModel({
    this.status,
    this.message,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      status: json["status"].toString().trim(),
      message: json["message"].toString().trim(),
    );
  }
}
