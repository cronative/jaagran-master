class BlockListModel {
  String id;
  String user_id;
  String block_user_id;
  String block_name;
  String block_dp;

  BlockListModel({
    this.id,
    this.user_id,
    this.block_user_id,
    this.block_name,
    this.block_dp,
  });

  factory BlockListModel._fromJson(Map<String, dynamic> json) {
    return BlockListModel(
      id: json['id'].toString().trim(),
      user_id: json['user_id'].toString().trim(),
      block_user_id: json['block_user_id'].toString().trim(),
      block_name: json['block_name'].toString().trim(),
      block_dp: json['block_dp'].toString().trim(),
    );
  }

  static getList(List<dynamic> jsonLst) {
    List<BlockListModel> lst = List();
    jsonLst.forEach((element) {
      lst.add(BlockListModel._fromJson(element));
    });
    return lst;
  }
}
