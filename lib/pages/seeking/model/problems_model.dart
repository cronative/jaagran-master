class ProblemsModel {
  String status;
  String message;
  List<ProblemData> lstProblemsData;

  ProblemsModel({
    this.status,
    this.message,
    this.lstProblemsData,
  });

  factory ProblemsModel.fromJSON(Map<String, dynamic> json) {
    return ProblemsModel(
      status: json["status"].toString().trim(),
      message: json["message"].toString().trim(),
      lstProblemsData: ProblemData.getList(json["data"]),
    );
  }
}

class ProblemData {
  int id;
  String problems;

  ProblemData({
    this.id,
    this.problems,
  });

  factory ProblemData._fromJSON(Map<String, dynamic> json) {
    return ProblemData(
      id: json['id'],
      problems: json['problems'].toString().trim(),
    );
  }

  static List<ProblemData> getList(List<dynamic> jsonList) {
    List<ProblemData> lst = List();
    jsonList.forEach((element) {
      lst.add(ProblemData._fromJSON(element));
    });
    return lst;
  }
}
