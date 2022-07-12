class GroupMemberModel {
  String dp;
  String group_id;
  String name;
  String receiver_id;
  bool is_admin;

  GroupMemberModel({
    this.dp,
    this.group_id,
    this.name,
    this.receiver_id,
    this.is_admin,
  });

  factory GroupMemberModel._fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      dp: json['dp'].toString().trim(),
      group_id: json['group_id'].toString().trim(),
      name: json['name'].toString().trim(),
      receiver_id: json['receiver_id'].toString().trim(),
      is_admin: json['is_admin'],
    );
  }

  static List<GroupMemberModel> getList(List<dynamic> jsonList) {
    List<GroupMemberModel> lst = [];
    jsonList.forEach((element) {
      lst.add(GroupMemberModel._fromJson(element));
    });
    return lst;
  }
}
