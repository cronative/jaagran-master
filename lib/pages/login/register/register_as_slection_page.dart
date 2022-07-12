import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/model/help_model.dart';
import 'package:jaagran/pages/login/register/terms_and_conditions_page.dart';
import 'package:jaagran/pages/login/register/user_sign_in_page.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:page_transition/page_transition.dart';

import 'expert_sign_in_page.dart';

class RegisterAsSelection extends StatefulWidget {
  @override
  _RegisterAsSelectionState createState() => _RegisterAsSelectionState();
}

class _RegisterAsSelectionState extends State<RegisterAsSelection> {
  SizeConfig _sf;
  int _selectedValue = 0;

  // Future<List<HelpModel>> _post;
  // List<HelpModel> lstHelpModel;
  bool isDisclaimerAccepted = false;

  @override
  void initState() {
    super.initState();
    // _post = _callGetHelpDetails();
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.only(right: _sf.scaleSize(65)),
          child: Image.asset(
            "assets/images/banner_logo.jpeg",
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
      // body: FutureBuilder(
      //   future: _post,
      //   builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      //     if (!snapshot.hasData) {
      //       return Center(child: CircularProgressIndicator());
      //     } else {
      //       lstHelpModel = snapshot.data;
      //       return
      //     }
      //   },
      // ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Center(
          //   child: Column(
          //     // children: [
          //       Container(
          //         width: double.infinity,
          //         height: _sf.scaleSize(25),
          //         color: Theme.of(context).primaryColor,
          //       ),
          //       Container(
          //         height: 100,
          //         width: double.infinity,
          //         color: Theme.of(context).primaryColor,
          //       ),
          //     ],
          //   ),
          // ),
          SizedBox(
            height: 16,
          ),
          Text(
            "Sign Up As",
            style: _sf.getExtraExtraLargeStyle(
                color: Theme.of(context).accentColor),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
                width: 30,
                child: Radio(
                  value: 0,
                  groupValue: _selectedValue,
                  onChanged: (val) {
                    setState(() {
                      _selectedValue = val;
                    });
                  },
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedValue = 0;
                  });
                },
                child: Text(
                  'User',
                  style: _sf.getLargeStyle(),
                ),
              ),
              SizedBox(
                width: _sf.scaleSize(32),
              ),
              SizedBox(
                height: 30,
                width: 30,
                child: Radio(
                  value: 1,
                  groupValue: _selectedValue,
                  onChanged: (val) {
                    setState(() {
                      _selectedValue = val;
                    });
                  },
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedValue = 1;
                  });
                },
                child: Text(
                  'Expert',
                  style: _sf.getLargeStyle(),
                ),
              ),
            ],
          ),
          _getExtraClickLinks(),
        ],
      ),
    );
  }

  Widget _getExtraClickLinks() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Text(
        //   "FAQ's",
        //   style: _sf.getLargeStyle(
        //       fontWeight: FontWeight.bold, color: Colors.black54),
        // ),
        SizedBox(
          height: _sf.scaleSize(64),
        ),
        // Row(
        //   mainAxisSize: MainAxisSize.min,
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     InkWell(
        //       onTap: () async {
        //         isDisclaimerAccepted = await  _navigateToDisclaimer();
        //       },
        //       child: Padding(
        //         padding: const EdgeInsets.all(16.0),
        //         child: Text(
        //           "Disclaimer",
        //           style: _sf.getSmallStyle(color: Colors.black54),
        //         ),
        //       ),
        //     ),
        //     SizedBox(
        //       width: _sf.scaleSize(50),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.all(16.0),
        //       child: Text(
        //         "(c) Copyright",
        //         style: _sf.getSmallStyle(color: Colors.black54),
        //       ),
        //     ),
        //   ],
        // ),
        SizedBox(
          height: _sf.scaleSize(32),
        ),
        Container(
          width: double.infinity,
          height: _sf.scaleSize(50),
          color: Theme.of(context).buttonColor,
          child: Center(
              child: getNavButton(
            "Continue",
            _sf.getCaviarDreams(
                fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
            () async {
              if (isDisclaimerAccepted == null) {
                isDisclaimerAccepted = false;
              }
              if (!isDisclaimerAccepted) {
                isDisclaimerAccepted = await _navigateToDisclaimer();
              }
              printToConsole("214");
              if (isDisclaimerAccepted) {
                if (_selectedValue == 0) {
                  navigateToPageWithoutScaffold(context, UserSignInPage());
                } else {
                  navigateToPageWithoutScaffold(context, ExpertSignInPage());
                }
              }
              printToConsole("222");
            },
          )),
        )
      ],
    );
  }

  Future<bool> _navigateToDisclaimer() async {
    try {
      bool res = await Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              child: TermsAndConditionPage()));
      if (res == null) return false;
      return res;
    } catch (e) {
      printToConsole("error $e");
    }
  }

// Future<List<HelpModel>> _callGetHelpDetails() async {
//   final result = await callGetAPI("help-details", HashMap());
//   final response = json.decode(result.toString());
//   List<HelpModel> lst = HelpModel.getList(response['data']);
//   return lst;
// }

// Future<bool> showDisclaimerPopUp() async {
//   printToConsole("showDisclaimerPopUp");
//   bool isAccept = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return Dialog(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       height: 16,
//                     ),
//                     Center(
//                       child: Text(
//                         "Disclaimer",
//                         style: _sf.getLargeStyle(
//                             color: Theme.of(context).accentColor),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 16,
//                     ),
//                     Html(data: _getDisclaimer()),
//                     SizedBox(
//                       height: 16,
//                     ),
//                     Row(
//                       mainAxisSize: MainAxisSize.max,
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         FlatButton(
//                           child: Text(
//                             "accept",
//                             style: _sf.getSmallStyle(
//                                 color: Theme.of(context).accentColor),
//                           ),
//                           onPressed: () {
//                             Navigator.of(dialogContext).pop(true);
//                           },
//                         ),
//                         FlatButton(
//                           child: Text(
//                             "cancel",
//                             style: _sf.getSmallStyle(
//                                 color: Theme.of(context).accentColor),
//                           ),
//                           onPressed: () {
//                             Navigator.of(dialogContext).pop(false);
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       });
//   return isAccept;
// }

// String _getDisclaimer() {
//   String details;
//   lstHelpModel.forEach((element) {
//     if (element.helpheader.toLowerCase().contains("disclaimer")) {
//       details = element.detail;
//     }
//   });
//   return details;
// }
}
