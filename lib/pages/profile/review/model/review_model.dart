class ReviewModel {
  String reviews;
  String user_id;
  String ratting;
  String id;
  String rated_user_id;
  Rated_user rated_user;

  ReviewModel({
    this.reviews,
    this.user_id,
    this.ratting,
    this.id,
    this.rated_user_id,
    this.rated_user,
  });

  factory ReviewModel._fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviews: json["reviews"].toString().trim(),
      user_id: json["user_id"].toString().trim(),
      ratting: json["ratting"].toString().trim(),
      id: json["id"].toString().trim(),
      rated_user_id: json["rated_user_id"].toString().trim(),
      rated_user: Rated_user.fromJson(json["rated_user"]),
    );
  }

  static List<ReviewModel> getList(List<dynamic> jsonList) {
    List<ReviewModel> lst = List();
    jsonList.forEach((element) {
      lst.add(ReviewModel._fromJson(element));
    });
    return lst;
  }
}

class Rated_user {
  String name;
  String id;
  String dp;

  Rated_user({
    this.name,
    this.id,
    this.dp,
  });

  factory Rated_user.fromJson(Map<String, dynamic> json) {
    return Rated_user(
      name: json["name"].toString().trim(),
      id: json["id"].toString().trim(),
      dp: json["dp"].toString().trim(),
    );
  }
}
