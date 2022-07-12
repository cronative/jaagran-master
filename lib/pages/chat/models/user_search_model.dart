class UserSearchModel {
  String id;
  String title;
  String name;
  String role_id;
  String dp;
  String role_name;

  UserSearchModel({
    this.id,
    this.title,
    this.name,
    this.role_id,
    this.dp,
    this.role_name,
  });

  factory UserSearchModel._fromJson(Map<String, dynamic> json) {
    return UserSearchModel(
      id: json['id'].toString().trim(),
      title: json['title'].toString().trim(),
      name: json['name'].toString().trim(),
      role_id: json['role_id'].toString().trim(),
      dp: json['dp'].toString().trim(),
      role_name: json['role_name'].toString().trim(),
    );
  }

  static getList(List<dynamic> jsonLst) {
    List<UserSearchModel> lst = List();
    jsonLst.forEach((element) {
      lst.add(UserSearchModel._fromJson(element));
    });
    return lst;
  }
}
