class ProfileModel {
  String id;
  String wallet;
  String books;
  String city;
  String name;
  String mobile;
  String audios;
  String videos;
  String title;
  String dp;
  String posts;
  String email;
  String events;

  bool isFollow;
  String reviews;
  String ratting;
  String solution_given;
  String helpfull_votes;
  String likes;

  String expertise;
  String trained_with;
  bool isExpert;

  ProfileModel({
    this.wallet,
    this.books,
    this.city,
    this.name,
    this.mobile,
    this.audios,
    this.videos,
    this.title,
    this.dp,
    this.posts,
    this.email,
    this.events,
    this.isFollow,
    this.reviews,
    this.ratting,
    this.solution_given,
    this.helpfull_votes,
    this.likes,
    this.isExpert,
    this.expertise,
    this.trained_with,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      wallet: checkNull(json["wallet"].toString().trim()),
      books: checkNull(json["books"].toString().trim()),
      city: checkNull(json["city"].toString().trim()),
      name: checkNull(json["name"].toString().trim()),
      mobile: checkNull(json["mobile"].toString().trim()),
      audios: checkNull(json["audios"].toString().trim()),
      videos: checkNull(json["videos"].toString().trim()),
      title: checkNull(json["title"].toString().trim()),
      dp: checkNull(json["dp"].toString().trim()),
      posts: checkNull(json["posts"].toString().trim()),
      email: checkNull(json["email"].toString().trim()),
      events: checkNull(json["events"].toString().trim()),
      isFollow: json["isFollow"],
      reviews: checkNull(json["reviews"].toString().trim()),
      ratting: checkNull(json["ratting"].toString().trim()),
      solution_given: checkNull(json["solution_given"].toString().trim()),
      helpfull_votes: checkNull(json["helpfull_votes"].toString().trim()),
      likes: checkNull(json["likes"].toString().trim()),
      expertise: checkNull(json["expertise"].toString().trim()),
      trained_with: checkNull(json["trained_with"].toString().trim()),
      isExpert: json["IsExpert"].toString().trim() == 'true',
    );
  }

  static String checkNull(String text) {
    return text.toLowerCase() == 'null' ? '' : text;
  }
}
