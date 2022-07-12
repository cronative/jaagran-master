// import 'dart:collection';
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:jaagran/commons/common_dialogs.dart';
// import 'package:jaagran/commons/common_theme_functions.dart';
// import 'package:jaagran/pages/profile/review/model/review_model.dart';
// import 'package:jaagran/pages/seeking/parts/comment_field.dart';
// import 'package:jaagran/utils/size_config.dart';
// import 'package:jaagran/utils/web_utils.dart';
// import 'package:modal_progress_hud/modal_progress_hud.dart';
// // import 'package:smooth_star_rating/smooth_star_rating.dart';
//
// class AddReview extends StatefulWidget {
//   final String user_id;
//
//   final ReviewModel lastReview;
//   final BoolCallBack closeCall;
//
//   const AddReview({Key key, this.user_id, this.lastReview, this.closeCall})
//       : super(key: key);
//
//   @override
//   _AddReviewState createState() => _AddReviewState();
// }
//
// class _AddReviewState extends State<AddReview> {
//   bool isApiCall = false;
//   double ratting = 0;
//   SizeConfig _sf;
//
//   TextEditingController _reviewController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.lastReview != null) {
//       ratting = double.parse(widget.lastReview.ratting);
//       _reviewController.text = widget.lastReview.reviews;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     _sf = SizeConfig.getInstance(context);
//     return WillPopScope(
//       onWillPop: ()async{
//         widget.closeCall.call(false);
//         return false;
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SmoothStarRating(
//               rating: ratting,
//               isReadOnly: false,
//               size: _sf.scaleSize(45),
//               filledIconData: Icons.star,
//               halfFilledIconData: Icons.star_half,
//               defaultIconData: Icons.star_border,
//               starCount: 5,
//               allowHalfRating: true,
//               spacing: 2.0,
//               onRated: (value) {
//                 ratting = value;
//               },
//             ),
//             SizedBox(
//               height: _sf.scaleSize(16),
//             ),
//             TextField(
//               controller: _reviewController,
//               textAlign: TextAlign.start,
//               keyboardType: TextInputType.multiline,
//               style: _sf.getMediumStyle(),
//               maxLengthEnforced: true,
//               maxLines: 5,
//               minLines: 1,
//               textCapitalization: TextCapitalization.sentences,
//               inputFormatters: <TextInputFormatter>[
//                 LengthLimitingTextInputFormatter(200),
//               ],
//               decoration: InputDecoration(
//                 hintText: "add review",
//                 hintStyle: _sf.getMediumStyle(
//                     color: Theme.of(context).textSelectionColor),
//               ),
//             ),
//             SizedBox(
//               height: _sf.scaleSize(24),
//             ),
//             isApiCall
//                 ? Center(
//                     child: CircularProgressIndicator(),
//                   )
//                 : getFlatButton(_sf, "Save", Theme.of(context).accentColor, () {
//                     _callAddReview();
//                   }, padding: false),
//           ],
//         ),
//       ),
//     );
//   }
//
//   _callAddReview() async {
//     if (ratting == 0) {
//       showWarningDialog(context, "Please select ratting");
//       return;
//     }
//     String review = _reviewController.text.trim();
//     if (review.isEmpty) {
//       showWarningDialog(context, "Please add review");
//       return;
//     }
//     setState(() {
//       isApiCall = true;
//     });
//     HashMap params = HashMap();
//     params['user_id'] = widget.user_id;
//     params['ratting'] = '$ratting';
//     params['reviews'] = review;
//     final result = await callPostAPI("add-ratting", params);
//     final response = json.decode(result.toString());
//     if (response['status'] == 'success') {
//       showSuccessAlertDialog(context, response['message'], isCancelable: false,
//           callback: () {
//         widget.closeCall.call(true);
//       });
//     } else {
//       showErrorAlertDialog(context, response['message']);
//     }
//     setState(() {
//       isApiCall = false;
//     });
//   }
// }
