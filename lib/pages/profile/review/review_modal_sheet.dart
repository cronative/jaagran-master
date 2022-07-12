// import 'dart:collection';
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:jaagran/commons/common_theme_functions.dart';
// import 'package:jaagran/commons/session_manager.dart';
// import 'package:jaagran/commons/strings.dart';
// import 'package:jaagran/pages/profile/review/add_review.dart';
// import 'package:jaagran/utils/size_config.dart';
// import 'package:jaagran/utils/web_utils.dart';
// import 'package:smooth_star_rating/smooth_star_rating.dart';
//
// import 'model/review_model.dart';
//
// openReviewModelSheet(BuildContext context, String user_id, bool isSelf) {
//   printToConsole("openReviewModelSheet called");
//   SizeConfig sf = SizeConfig.getInstance(context);
//   showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
//       isScrollControlled: true,
//       builder: (context) {
//         return Padding(
//           padding: MediaQuery.of(context).viewInsets,
//           child: Container(child: ReviewSheet(sf, user_id, isSelf)),
//         );
//       });
// }
//
// class ReviewSheet extends StatefulWidget {
//   final SizeConfig sf;
//   final String user_id;
//   final bool isSelf;
//
//   ReviewSheet(this.sf, this.user_id, this.isSelf);
//
//   @override
//   _ReviewSheetState createState() => _ReviewSheetState();
// }
//
// class _ReviewSheetState extends State<ReviewSheet> {
//   Future<List<ReviewModel>> _post;
//   ReviewModel lastReview;
//   bool isApiCalled = false;
//   bool addReview = false;
//   double sheetHeight = 400;
//
//   @override
//   void initState() {
//     super.initState();
//     sheetHeight = widget.sf.getScreenHeight() / 2;
//     _post = _callGetAllReviews();
//   }
//
//   Future<String> _getUserDp(String dp) async {
//     SessionManager manager = SessionManager.getInstance();
//     if (dp.isEmpty || dp == "null") return "";
//     return Server_URL + manager.getDpPath() + dp;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.grey[200],
//       padding: const EdgeInsets.all(16.0),
//       child: addReview ? _addReview() : _getReviewList(),
//     );
//   }
//
//   Future<List<ReviewModel>> _callGetAllReviews() async {
//     HashMap params = HashMap();
//     params['user_id'] = widget.user_id;
//     final result = await callPostAPI("review-list", params);
//     final response = json.decode(result.toString());
//     List<ReviewModel> lst = List();
//     if (response['status'] == 'success') {
//       lst = ReviewModel.getList(response['data']);
//     }
//     SessionManager manager = SessionManager.getInstance();
//     String currentUserID = manager.getUserID();
//     lst.forEach((element) {
//       if (element.rated_user_id == currentUserID) {
//         lastReview = element;
//       }
//     });
//     setState(() {
//       if (lst.length > 8) {
//         sheetHeight = widget.sf.getScreenHeight() / 1.3;
//       } else if (lst.length > 6) {
//         sheetHeight = widget.sf.getScreenHeight() / 1.5;
//       } else if (lst.length > 4) {
//         sheetHeight = widget.sf.getScreenHeight() / 1.8;
//       }
//       isApiCalled = true;
//     });
//     return lst;
//   }
//
//   _checkAddReview() {
//     if (widget.isSelf) return Container();
//     return getFlatButton(
//         widget.sf,
//         lastReview == null ? "Add Review" : "Edit Review",
//         Theme.of(context).accentColor, () {
//       setState(() {
//         addReview = true;
//       });
//     });
//   }
//
//   _getReviewList() {
//     return Container(
//       height: sheetHeight,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           FutureBuilder(
//             future: _post,
//             builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
//               if (!snapshot.hasData) {
//                 return Container(
//                   height: 200,
//                   child: Center(child: CircularProgressIndicator()),
//                 );
//               }
//               List<ReviewModel> listReview = snapshot.data;
//               printToConsole("${snapshot.data.toString()}");
//               if (listReview.isEmpty) {
//                 return Expanded(
//                   child: Center(
//                     child: Text(
//                       "No reviews found!",
//                       style: widget.sf.getMediumStyle(color: Colors.grey[700]),
//                     ),
//                   ),
//                 );
//               }
//               return Expanded(
//                 child: ListView.builder(
//                   itemCount: listReview.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     ReviewModel model = listReview[index];
//                     // ReviewModel model = listReview[0];
//                     return Padding(
//                       padding: const EdgeInsets.all(4.0),
//                       child: ListTile(
//                         tileColor: Colors.white,
//                         contentPadding: EdgeInsets.all(8),
//                         leading: FutureBuilder<String>(
//                           future: _getUserDp(model.rated_user.dp),
//                           builder: (BuildContext context,
//                               AsyncSnapshot<dynamic> snapshot) {
//                             if (snapshot.hasData) {
//                               String dp = snapshot.data.toString().trim();
//                               if (dp.isNotEmpty) {
//                                 return CircleAvatar(
//                                   radius: widget.sf.scaleSize(20),
//                                   backgroundImage: AssetImage(
//                                       "assets/images/dp_circular_avatar.png"),
//                                   backgroundColor: Colors.transparent,
//                                   child: CircleAvatar(
//                                     radius: widget.sf.scaleSize(20),
//                                     backgroundImage: NetworkImage(
//                                       dp,
//                                     ),
//                                     backgroundColor: Colors.transparent,
//                                   ),
//                                 );
//                               }
//                             }
//                             return CircleAvatar(
//                               radius: widget.sf.scaleSize(50),
//                               backgroundImage: AssetImage(
//                                   "assets/images/dp_circular_avatar.png"),
//                               backgroundColor: Colors.transparent,
//                             );
//                           },
//                         ),
//                         title: SmoothStarRating(
//                           rating: double.parse(model.ratting),
//                           isReadOnly: true,
//                           size: widget.sf.scaleSize(30),
//                           filledIconData: Icons.star,
//                           halfFilledIconData: Icons.star_half,
//                           defaultIconData: Icons.star_border,
//                           starCount: 5,
//                           allowHalfRating: true,
//                           spacing: 2.0,
//                           onRated: (value) {},
//                         ),
//                         subtitle: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                           child: Text(
//                             model.reviews,
//                             style: widget.sf.getMediumStyle(),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//           isApiCalled ? _checkAddReview() : Container(),
//         ],
//       ),
//     );
//   }
//
//   _addReview() {
//     return AddReview(
//       user_id: widget.user_id,
//       lastReview: lastReview,
//       closeCall: (flag) {
//         if (flag) {
//           setState(() {
//             addReview = false;
//             isApiCalled = false;
//           });
//           _post = _callGetAllReviews();
//         } else {
//           setState(() {
//             addReview = false;
//           });
//         }
//       },
//     );
//   }
// }
