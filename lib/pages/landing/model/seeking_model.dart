class SeekingModel {
  String message;
  String status;
  SeekingParent data;

  SeekingModel({
    this.message,
    this.status,
    this.data,
  });

  factory SeekingModel.fromJson(Map<String, dynamic> json) {
    return SeekingModel(
      status: json["status"].toString().trim(),
      message: json["message"].toString().trim(),
      data: SeekingParent.fromJson(json["data"]),
    );
  }
}

class SeekingParent {
  int current_page;
  int last_page;
  int per_page;
  int total;
  List<SeekingData> lstSeekingData;

  SeekingParent({
    this.current_page,
    this.last_page,
    this.per_page,
    this.total,
    this.lstSeekingData,
  });

  factory SeekingParent.fromJson(Map<String, dynamic> json) {
    return SeekingParent(
      current_page: json["current_page"],
      last_page: json["last_page"],
      per_page: json["per_page"],
      total: json["total"],
      lstSeekingData: SeekingData.getList(json["data"]),
    );
  }
}

class SeekingData {
  String total_comments;
  String user_by;
  String user_id;
  String description;
  String total_views;
  String id;
  String title;
  String total_likes;

  bool is_likes;
  String media_author;
  String media_id;
  String media_thumbnail;
  String media_uploaded;
  bool isSeen;

  String emotions;
  double media_cost;
  String emotions_name;

  bool special_handling; // Y/N
  bool is_lock; // Y/N

  String locked_by;
  bool is_paid;

  SeekingData({
    this.total_comments,
    this.user_by,
    this.user_id,
    this.description,
    this.total_views,
    this.id,
    this.title,
    this.total_likes,
    this.is_likes,
    this.media_author,
    this.media_id,
    this.media_thumbnail,
    this.media_uploaded,
    this.isSeen,
    this.emotions,
    this.media_cost,
    this.emotions_name,
    this.locked_by,
    this.special_handling,
    this.is_lock,
    this.is_paid,
  });

  factory SeekingData.fromJson(Map<String, dynamic> json) {
    return SeekingData(
      total_comments: json["total_comments"].toString().trim(),
      user_by: json["user_by"].toString().trim(),
      user_id: json["user_id"].toString().trim(),
      description: json["description"].toString().trim(),
      total_views: json["total_views"].toString().trim(),
      id: json["id"].toString().trim(),
      title: json["title"].toString().trim(),
      total_likes: json["total_likes"].toString().trim(),
      is_likes: json["is_likes"],
      media_author: json["media_author"].toString().trim(),
      media_id: json["media_id"].toString().trim(),
      media_thumbnail: json["media_thumbnail"].toString().trim(),
      media_uploaded: json["media_uploaded"].toString().trim(),
      emotions: json["emotions"].toString().trim(),
      media_cost: getMediaCost(json["media_cost"].toString().trim()),
      emotions_name: json["emotions_name"].toString().trim(),
      locked_by: json["locked_by"].toString().trim(),
      isSeen: json["is_seen"],
      is_lock: checkYN(json['is_lock']),
      special_handling: checkYN(json['special_handling']),
      is_paid: checkYN(json['is_paid']),
    );
  }

  static List<SeekingData> getList(List<dynamic> jsonList) {
    List<SeekingData> lst = [];
    jsonList.forEach((element) {
      lst.add(SeekingData.fromJson(element));
    });
    return lst;
  }
}

double getMediaCost(String trim) {
  if (trim == 'null' || trim.isEmpty) return 0;
  try {
    if (!trim.contains(".")) {
      trim = trim + '.0';
    }
    double price = double.parse(trim);
    return price;
  } catch (e) {
    return 0;
  }
}

checkYN(json) {
  if (json == null) return false;
  return json.toString().trim().toLowerCase() == "y";
}
