class ThreadDetails {
  int current_page;
  int last_page;
  int per_page;
  int total;
  List<ThreadInfo> data;

  ThreadDetails({
    this.current_page,
    this.last_page,
    this.per_page,
    this.total,
    this.data,
  });

  factory ThreadDetails.fromJson(Map<String, dynamic> json) {
    return ThreadDetails(
      current_page: json["current_page"],
      last_page: json["last_page"],
      per_page: json["per_page"],
      total: json["total"],
      data: ThreadInfo.getList(json['data']),
    );
  }
}

class ThreadInfo {
  int id;
  String activity_detail_id;
  String thread_user_id;
  String parent_thread_id;
  String thread_like;
  String thread_view;
  String thread_comments;
  String thread_details;
  String user_by;
  bool is_likes;
  bool is_seen;

  ThreadInfo({
    this.id,
    this.activity_detail_id,
    this.thread_user_id,
    this.parent_thread_id,
    this.thread_like,
    this.thread_view,
    this.thread_comments,
    this.thread_details,
    this.user_by,
    this.is_likes,
    this.is_seen,
  });

  factory ThreadInfo.fromJson(Map<String, dynamic> json) {
    return ThreadInfo(
      id: json["id"],
      activity_detail_id: json['activity_detail_id'].toString().trim(),
      thread_user_id: json['thread_user_id'].toString().trim(),
      parent_thread_id: json['parent_thread_id'].toString().trim(),
      thread_like: json['thread_like'].toString().trim(),
      thread_view: json['thread_view'].toString().trim(),
      thread_comments: json['thread_comments'].toString().trim(),
      thread_details: json['thread_details'].toString().trim(),
      user_by: json['user_by'].toString().trim(),
      is_likes: json['is_likes'],
      is_seen: json['is_seen'],
    );
  }

  static List<ThreadInfo> getList(List<dynamic> json) {
    List<ThreadInfo> lst = List();
    json.forEach((element) {
      lst.add(ThreadInfo.fromJson(element));
    });
    return lst;
  }
}
