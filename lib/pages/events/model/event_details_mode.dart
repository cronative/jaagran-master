import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/landing/model/seeking_model.dart';

class EventDetailsModel {
  String id;
  String venue;
  String event_mobile;
  String course_hours;
  String media_author;
  String event_end_date;
  String description;
  String title;
  String event_footnotes;
  String event_email;
  String event_end_time;
  String user_by;
  String event_virtual;
  String event_booking_amount;
  String user_id;
  String event_cost;
  String media_id;
  String event_start_time;
  String media_thumbnail;
  String event_start_date;
  String media_uploaded;
  List<EventLink> links;

  bool is_booking_amout_paid;
  bool is_event_cost_paid;

  EventDetailsModel({
    this.id,
    this.venue,
    this.event_mobile,
    this.course_hours,
    this.media_author,
    this.event_end_date,
    this.description,
    this.title,
    this.event_footnotes,
    this.event_email,
    this.event_end_time,
    this.user_by,
    this.event_virtual,
    this.event_booking_amount,
    this.user_id,
    this.event_cost,
    this.media_id,
    this.event_start_time,
    this.media_thumbnail,
    this.event_start_date,
    this.media_uploaded,
    this.links,
    this.is_booking_amout_paid,
    this.is_event_cost_paid,
  });

  factory EventDetailsModel.fromJson(Map<String, dynamic> json) {
    return EventDetailsModel(
      id: json['id'].toString().trim(),
      venue: json['venue'].toString().trim(),
      event_mobile: json['event_mobile'].toString().trim(),
      course_hours: json['course_hours'].toString().trim(),
      media_author: json['media_author'].toString().trim(),
      event_end_date: json['event_end_date'].toString().trim(),
      description: json['description'].toString().trim(),
      title: json['title'].toString().trim(),
      event_footnotes: json['event_footnotes'].toString().trim(),
      event_email: json['event_email'].toString().trim(),
      event_end_time: json['event_end_time'].toString().trim(),
      user_by: json['user_by'].toString().trim(),
      event_virtual: json['event_virtual'].toString().trim(),
      event_booking_amount: json['event_booking_amount'].toString().trim(),
      user_id: json['user_id'].toString().trim(),
      event_cost: json['event_cost'].toString().trim(),
      media_id: json['media_id'].toString().trim(),
      event_start_time: json['event_start_time'].toString().trim(),
      media_thumbnail: json['media_thumbnail'].toString().trim(),
      event_start_date: json['event_start_date'].toString().trim(),
      media_uploaded: json['media_uploaded'].toString().trim(),
      is_booking_amout_paid: checkYN(json['is_booking_amout_paid']),
      is_event_cost_paid: checkYN(json['is_event_cost_paid']),
      links: _getList(json['links']),
    );
  }

  static List<EventLink> _getList(List<dynamic> lst) {
    printToConsole("_getList $lst");
    List<EventLink> list = List();
    if (lst != null) {
      lst.forEach((element) {
        list.add(EventLink.fromJson(element));
      });
    }
    return list;
  }
}

class EventLink {
  String name;
  String url;

  EventLink({
    this.name,
    this.url,
  });

  factory EventLink.fromJson(Map<String, dynamic> json) {
    return EventLink(
      name: json['attachment_name'].toString().trim(),
      url: json['attachment_url'].toString().trim(),
    );
  }
}
