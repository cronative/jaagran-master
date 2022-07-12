class EventModel {
  String message;
  String status;
  EventParent data;

  EventModel({
    this.message,
    this.status,
    this.data,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      status: json["status"].toString().trim(),
      message: json["message"].toString().trim(),
      data: EventParent.fromJson(json["data"]),
    );
  }
}

class EventParent {
  int current_page;
  int last_page;
  int per_page;
  int total;
  List<EventData> lstEventData;

  EventParent({
    this.current_page,
    this.last_page,
    this.per_page,
    this.total,
    this.lstEventData,
  });

  factory EventParent.fromJson(Map<String, dynamic> json) {
    return EventParent(
      current_page: json["current_page"],
      last_page: json["last_page"],
      per_page: json["per_page"],
      total: json["total"],
      lstEventData: EventData.getList(json["data"]),
    );
  }
}

class EventData {
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
  String media_cost;
  String emotions_name;

  EventData({
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
  });

  factory EventData._fromJson(Map<String, dynamic> json) {
    return EventData(
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
      media_cost: json["media_cost"].toString().trim(),
      emotions_name: json["emotions_name"].toString().trim(),
      isSeen: json["is_seen"],
    );
  }

  static List<EventData> getList(List<dynamic> jsonList) {
    List<EventData> lst = List();
    jsonList.forEach((element) {
      lst.add(EventData._fromJson(element));
    });
    return lst;
  }
}
