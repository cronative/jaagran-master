class UserData {
  String user_id;
  String follower_id;
  String following_ratings;
  String solutions_given;
  String helpful_votes;
  String followers_likes;
  String follower_name;
  String follower_dp;

  UserData({
    this.user_id,
    this.follower_id,
    this.following_ratings,
    this.solutions_given,
    this.helpful_votes,
    this.followers_likes,
    this.follower_name,
    this.follower_dp,
  });

  factory UserData._fromJson(Map<String, dynamic> json) {
    return UserData(
      user_id: json['user_id'].toString().trim(),
      follower_id: json['follower_id'].toString().trim(),
      following_ratings: json['following_ratings'].toString().trim(),
      solutions_given: json['solutions_given'].toString().trim(),
      helpful_votes: json['helpful_votes'].toString().trim(),
      followers_likes: json['followers_likes'].toString().trim(),
      follower_name: json['follower_name'].toString().trim(),
      follower_dp: json['follower_dp'].toString().trim(),
    );
  }

  static List<UserData> getList(List<dynamic> jsonLst) {
    List<UserData> lst = List();
    jsonLst.forEach((element) {
      lst.add(UserData._fromJson(element));
    });
    return lst;
  }
}
