import 'package:flutter/material.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:page_transition/page_transition.dart';

navigateToPage(BuildContext context, Widget page, {String pageName}) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: getCommonAppBar(context, SizeConfig.getInstance(context)),
            body: page,
          )));
}

navigateToPageWithReplacement(BuildContext context, Widget page,
    {String pageName}) {

  Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
              centerTitle: true,
              titleSpacing: 2,
//                  flexibleSpace:Container(
//                    decoration: new BoxDecoration(
//                      gradient: AppColors.color_violet,
//                    ),
//                  ),
              title: Text(
                pageName ?? "",
                textAlign: TextAlign.center,
              ),
            ),
            body: page,
          )));
}

navigateToPageWithoutScaffold(BuildContext context, Widget page,
    {String pageName, VoidCallback onBack, bool isBottomTop = false}) async {
  final result = await Navigator.push(
      context,
      PageTransition(
          type:  PageTransitionType.rightToLeftWithFade,
          child: page));
  if (onBack != null) {
    onBack.call();
    printToConsole("onBack.call()");
  }
}

navigateWithClearStack(BuildContext context, Widget page, {String pageName}) {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => page),
      (Route<dynamic> route) => false);
}
//
//getThemeData(BuildContext context) => ThemeData(
//    primaryColor: StaticConfig.BackGroundColour,
//    accentColor: StaticConfig.BackGroundColour,
//    fontFamily: 'DishCo');

hideKeyBoard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}
