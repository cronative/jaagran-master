import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/utils/size_config.dart';

import 'common_theme_functions.dart';

showSuccessAlertDialog(BuildContext context, String err,
    {String title = "Success",
    VoidCallback callback,
    bool isCancelable = true}) {
  // return showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(title),
  //         content: Text(
  //           err,
  //           textAlign: centerMsg ? TextAlign.center : TextAlign.start,
  //         ),
  //         actions: <Widget>[
  //           FlatButton(
  //             color: Theme.of(context).primaryColor,
  //             child: Text(
  //               'Ok',
  //               style: getNormalFont(fontSize: 14, color: Colors.white),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               if (callback != null) {
  //                 callback.call();
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     });

  AwesomeDialog(
    context: context,
    dialogType: DialogType.SUCCES,
    headerAnimationLoop: false,
    animType: AnimType.TOPSLIDE,
    title: title,
    desc: err,
    dismissOnTouchOutside: isCancelable,
    // btnCancelOnPress: () {},
    btnOkOnPress: () {
      if (callback != null) {
        callback.call();
      }
    },
  )..show();
}

// Future<void> showNonCancelAlertDialog(BuildContext context, String err,
//     {String title = "Jaagran", VoidCallback callback}) {
//   // return showDialog<void>(
//   //     context: context,
//   //     barrierDismissible: false,
//   //     builder: (BuildContext context) {
//   //       return AlertDialog(
//   //         title: Text(title),
//   //         content: Text(
//   //           err,
//   //           textAlign: TextAlign.start,
//   //         ),
//   //         actions: <Widget>[
//   //           FlatButton(
//   //             color: Theme.of(context).primaryColor,
//   //             child: Text(
//   //               'Ok',
//   //               style: getNormalFont(fontSize: 14, color: Colors.white),
//   //             ),
//   //             onPressed: () {
//   //               Navigator.of(context).pop();
//   //               if (callback != null) {
//   //                 callback.call();
//   //               }
//   //             },
//   //           ),
//   //         ],
//   //       );
//   //     });
//
//   AwesomeDialog(
//     context: context,
//     dialogType: DialogType.SUCCES,
//     animType: AnimType.BOTTOMSLIDE,
//     title: title,
//     desc: err,
//     dismissOnTouchOutside: false,
//     // btnCancelOnPress: () {},
//     btnOkOnPress: () {
//       if (callback != null) {
//         callback.call();
//       }
//     },
//   )..show();
// }

showErrorAlertDialog(BuildContext context, String err,
    {String title = "Error", VoidCallback callback, bool isCancelable = true}) {
  AwesomeDialog(
    context: context,
    headerAnimationLoop: false,
    dialogType: DialogType.ERROR,
    animType: AnimType.BOTTOMSLIDE,
    title: title,
    desc: err,
    dismissOnTouchOutside: isCancelable,
    // btnCancelOnPress: () {},
    btnOkOnPress: () {
      if (callback != null) {
        callback.call();
      }
    },
  )..show();
}

showWarningDialog(BuildContext context, String err,
    {String title = "Info", VoidCallback callback, bool isCancelable = true}) {
  AwesomeDialog(
    context: context,
    headerAnimationLoop: false,
    dialogType: DialogType.INFO,
    animType: AnimType.BOTTOMSLIDE,
    title: title,
    desc: err,
    dismissOnTouchOutside: isCancelable,
    // btnCancelOnPress: () {},
    btnOkOnPress: () {
      if (callback != null) {
        callback.call();
      }
    },
  )..show();
}

showCustomWarningDialog(
  BuildContext context,
  String desc, {
  String title = "Info",
  VoidCallback okCall,
  VoidCallback cancelCall,
  bool isCancelable = true,
  bool showCancel = true,
  String okText = 'accept',
}) {
  SizeConfig _sf = SizeConfig.getInstance(context);
  AwesomeDialog(
    context: context,
    headerAnimationLoop: false,
    dialogType: DialogType.INFO,
    animType: AnimType.BOTTOMSLIDE,
    title: title,
    desc: desc,
    dismissOnTouchOutside: isCancelable,
    btnCancelOnPress: () {
      if (cancelCall != null) {
        cancelCall.call();
      }
    },
    btnOk: Center(
      child: InkWell(
        onTap: (){
          if (okCall != null) {
            okCall.call();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            okText,
            style: _sf.getMediumStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    ),
    btnCancel: showCancel ? Text("cancel") : Container(),
    btnOkOnPress: () {
      printToConsole(" ok button press call");
      if (okCall != null) {
        okCall.call();
      }
    },
  )..show();
}

showYesNoDialog(
  BuildContext context,
  String content, {
  String title = "Info",
  VoidCallback okCall,
  VoidCallback cancelCall,
  String okText = 'accept',
  String cancelText = 'cancel',
  bool isCancelable = true,
}) {
  // SizeConfig sf = SizeConfig.getInstance(context);

  Widget okButton = FlatButton(
    child: Text(okText),
    onPressed: () {
      Navigator.of(context).pop();
      okCall.call();
    },
  );

  Widget cancelButton = FlatButton(
    child: Text(cancelText),
    onPressed: () {
      Navigator.of(context).pop();
      cancelCall.call();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      okButton,
      cancelButton,
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
