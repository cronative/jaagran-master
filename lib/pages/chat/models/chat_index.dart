class ChatIndex {
  String group_id;
  String receiver_id;
  String name;
  String id;
  String dp;
  String sender_id;
  bool isRequestAccepted;

  ChatIndex({
    this.group_id,
    this.receiver_id,
    this.name,
    this.id,
    this.dp,
    this.sender_id,
    this.isRequestAccepted,
  });

  factory ChatIndex._fromJson(Map<String, dynamic> json) {
    return ChatIndex(
      group_id: json['group_id'].toString().trim(),
      receiver_id: json['receiver_id'].toString().trim(),
      name: json['name'].toString().trim(),
      id: json['id'].toString().trim(),
      dp: json['dp'].toString().trim(),
      sender_id: json['sender_id'].toString().trim(),
      isRequestAccepted: getBool(json['status']),
    );
  }

  static getList(List<dynamic> jsonLst) {
    List<ChatIndex> lst = List();
    jsonLst.forEach((element) {
      lst.add(ChatIndex._fromJson(element));
    });
    return lst;
  }
}

bool getBool(json) {
  if (json == null) return false;
  if (json == 'null') return false;
  return json.toString().trim().toLowerCase() == 'y';
}
