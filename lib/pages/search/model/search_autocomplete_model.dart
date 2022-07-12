class SearchAutoCompleteModel {
  int id;
  String type;
  String name;

  SearchAutoCompleteModel({
    this.id,
    this.type,
    this.name,
  });

  factory SearchAutoCompleteModel._fromJson(Map<String, dynamic> json) {
    return SearchAutoCompleteModel(
      id: json['id'],
      type: json['type'].toString().trim(),
      name: json['name'].toString().trim(),
    );
  }

  static getList(List<dynamic> jsonLst) {
    List<SearchAutoCompleteModel> lst = List();
    jsonLst.forEach((element) {
      lst.add(SearchAutoCompleteModel._fromJson(element));
    });
    return lst;
  }
}
