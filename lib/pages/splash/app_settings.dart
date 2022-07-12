class AppSettings {
  String dp_storage_path;
  String video_storage_path;
  String audio_storage_path;
  String ebook_storage_path;
  String events_storage_path;
  String feedback_category;
  String agora_appid;
  String adverts_storage_path;
  String razorpay_key;

  AppSettings({
    this.dp_storage_path,
    this.video_storage_path,
    this.audio_storage_path,
    this.ebook_storage_path,
    this.feedback_category,
    this.agora_appid,
    this.events_storage_path,
    this.adverts_storage_path,
    this.razorpay_key,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      dp_storage_path: json['dp_storage_path'].toString().trim(),
      video_storage_path: json['video_storage_path'].toString().trim(),
      audio_storage_path: json['audio_storage_path'].toString().trim(),
      ebook_storage_path: json['ebook_storage_path'].toString().trim(),
      feedback_category: json['feedback_category'].toString().trim(),
      agora_appid: json['agora_appid'].toString().trim(),
      events_storage_path: json['events_storage_path'].toString().trim(),
      adverts_storage_path: json['adverts_storage_path'].toString().trim(),
      razorpay_key: json['razorpay_key'].toString().trim(),
    );
  }
}
