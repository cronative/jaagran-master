class HelpModel {
  int id;
  String helpheader;
  String detail;

  HelpModel({
    this.id,
    this.helpheader,
    this.detail,
  });

  factory HelpModel._fromJson(Map<String, dynamic> json) {
    return HelpModel(
      id: json['id'],
      helpheader: json['helpheader'].toString().trim(),
      detail: json['detail'].toString().trim(),
    );
  }

  static List<HelpModel> getList(List<dynamic> jsonList) {
    List<HelpModel> lst = List();
    jsonList.forEach((element) {
      lst.add(HelpModel._fromJson(element));
    });
    return lst;
  }
}
