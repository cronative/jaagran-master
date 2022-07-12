class VCIndexModel {
  String receiver_id;
  String confirm_date;
  String name;
  String id;
  String dp;
  String confirm_time;
  String sender_id;
  String event_id;

  int event_cost;
  int event_booking_amount;
  bool is_booking_amout_paid;
  bool is_event_cost_paid;

  String session_date;
  String session_time;
  String notes;
  String status;

  VCIndexModel({
    this.receiver_id,
    this.confirm_date,
    this.name,
    this.id,
    this.dp,
    this.confirm_time,
    this.sender_id,
    this.event_id,
    this.event_cost,
    this.event_booking_amount,
    this.is_booking_amout_paid,
    this.is_event_cost_paid,
    this.session_date,
    this.session_time,
    this.notes,
    this.status,
  });

  factory VCIndexModel._fromJSON(Map<String, dynamic> json) {
    return VCIndexModel(
      receiver_id: json['receiver_id'].toString().trim(),
      confirm_date: json['confirm_date'].toString().trim(),
      name: json['name'].toString().trim(),
      id: json['id'].toString().trim(),
      dp: json['dp'].toString().trim(),
      confirm_time: json['confirm_time'].toString().trim(),
      sender_id: json['sender_id'].toString().trim(),
      event_id: json['event_id'].toString().trim(),
      event_cost: getCost(json['event_cost']),
      event_booking_amount: getCost(json['event_booking_amount']),
      is_booking_amout_paid: checkYN(json['is_booking_amout_paid']),
      is_event_cost_paid: checkYN(json['is_event_cost_paid']),
      session_date: json['session_date'].toString().trim(),
      session_time: json['session_time'].toString().trim(),
      notes: json['notes'].toString().trim(),
      status: json['status'].toString().trim(),
    );
  }

  static List<VCIndexModel> getList(List<dynamic> jsonList) {
    List<VCIndexModel> lst = [];
    jsonList.forEach((element) {
      lst.add(VCIndexModel._fromJSON(element));
    });
    return lst;
  }
}

int getCost(json) {
  if (json == null) return 0;
  try {
    int val = int.parse(json.toString());
    return val;
  } on Exception catch (e) {
    return 0;
  }
}

bool checkYN(json) {
  if (json == null) return false;
  return json.toString().trim().toLowerCase() == "y";
}
