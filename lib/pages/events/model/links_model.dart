class LinkModel {
  String name;
  String url;

  LinkModel(this.name, this.url);

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "url": this.url,
    };
  }
}
