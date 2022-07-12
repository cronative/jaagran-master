class StatusOnly {
  bool isSuccess;
  String message;

  StatusOnly({
    this.isSuccess,
    this.message,
  });

  factory StatusOnly.fromJson(Map<String, dynamic> json) {
    return StatusOnly(
      isSuccess: json["status"].toString().trim().toLowerCase() == "success",
      message: json["message"].toString().trim(),
    );
  }
}
