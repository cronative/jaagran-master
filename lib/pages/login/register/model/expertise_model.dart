
import 'package:jaagran/commons/strings.dart';

class ExpertiseModel {
  String status;
  String message;
  List<LstExpertise> lstExpertise;

  ExpertiseModel({
    this.status,
    this.message,
    this.lstExpertise,
  });

  factory ExpertiseModel.fromJSON(Map<String, dynamic> json) {
    return ExpertiseModel(
      status: json["status"].toString().trim(),
      message: json["message"].toString().trim(),
      lstExpertise: LstExpertise.getList(json["data"]),
    );
  }
}

class LstExpertise {
  int id;
  String expertise;

  LstExpertise({
    this.id,
    this.expertise,
  });

  factory LstExpertise._fromJSON(Map<String, dynamic> json) {
    return LstExpertise(
      id: json["id"],
      expertise: json["expertise"].toString().trim(),
    );
  }

  static List<LstExpertise> getList(List<dynamic> jsonList) {
    List<LstExpertise> lst = List();
    printToConsole("${jsonList.length}");
    jsonList.forEach((element) {
      lst.add(LstExpertise._fromJSON(element));
    });
    return lst;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'expertise': expertise,
      };
}
