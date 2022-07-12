class NotificationModel {
  String id;
  String message_text;
  String created_date;
  String activity_detail_id;
  String sender_id;
  String notification_type;
  List<NotificationData> lstNotificationData;

  NotificationModel({
    this.id,
    this.message_text,
    this.created_date,
    this.activity_detail_id,
    this.sender_id,
    this.notification_type,
    this.lstNotificationData,
  });

  factory NotificationModel._fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString().trim(),
      message_text: json['message_text'].toString().trim(),
      created_date: json['created_date'].toString().trim(),
      activity_detail_id: json['activity_detail_id'].toString().trim(),
      sender_id: json['sender_id'].toString().trim(),
      notification_type: json['notification_type'].toString().trim(),
      lstNotificationData: NotificationData.getList(json['data']),
    );
  }

  static getList(List<dynamic> jsonLst) {
    List<NotificationModel> lst = List();
    jsonLst.forEach((element) {
      lst.add(NotificationModel._fromJson(element));
    });
    return lst;
  }
}

class NotificationData {
  String notes;
  String event_id;
  String receiver_id;
  String session_date;
  String confirm_date;
  String id;
  String sender_id;
  String session_time;
  String confirm_time;
  String status;

  NotificationData({
    this.notes,
    this.event_id,
    this.receiver_id,
    this.session_date,
    this.confirm_date,
    this.id,
    this.sender_id,
    this.session_time,
    this.confirm_time,
    this.status,
  });

  factory NotificationData._fromJson(Map<String, dynamic> json) {
    return NotificationData(
      notes: json['notes'].toString().trim(),
      event_id: json['event_id'].toString().trim(),
      receiver_id: json['receiver_id'].toString().trim(),
      session_date: json['session_date'].toString().trim(),
      confirm_date: json['confirm_date'].toString().trim(),
      id: json['id'].toString().trim(),
      sender_id: json['sender_id'].toString().trim(),
      session_time: json['session_time'].toString().trim(),
      confirm_time: json['confirm_time'].toString().trim(),
      status: json['status'].toString().trim(),
    );
  }

  static getList(List<dynamic> jsonLst) {
    List<NotificationData> lst = List();
    jsonLst.forEach((element) {
      lst.add(NotificationData._fromJson(element));
    });
    return lst;
  }
}
