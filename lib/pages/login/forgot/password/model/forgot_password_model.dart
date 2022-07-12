class ForgotPasswordModel {
  String status;
  String message;

  ForgotPasswordModel({
    this.status,
    this.message,
  });

  factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordModel(
      status: json["status"].toString().trim(),
      message: json["message"].toString().trim(),
    );
  }
}
