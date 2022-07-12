class EmotionsModel {
  String status;
  String message;
  List<EmotionsData> lstEmotionsData;

  EmotionsModel({
    this.status,
    this.message,
    this.lstEmotionsData,
  });

  factory EmotionsModel.fromJSON(Map<String, dynamic> json) {
    return EmotionsModel(
      status: json["status"].toString().trim(),
      message: json["message"].toString().trim(),
      lstEmotionsData: EmotionsData.getList(json["data"]),
    );
  }
}

class EmotionsData {
  int id;
  String emotion;
  bool isHappyEmotion;

  EmotionsData({
    this.id,
    this.emotion,
    this.isHappyEmotion,
  });

  factory EmotionsData._fromJSON(Map<String, dynamic> json) {
    return EmotionsData(
      id: json['id'],
      emotion: json['emotion'].toString().trim(),
      isHappyEmotion:
          json['isHappyEmotion'].toString().trim().toUpperCase() == "Y",
    );
  }

  static List<EmotionsData> getList(List<dynamic> jsonList) {
    List<EmotionsData> lst = List();
    jsonList.forEach((element) {
      lst.add(EmotionsData._fromJSON(element));
    });
    return lst;
  }
}
