import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaagran/utils/size_config.dart';

Color getBackgroundColor() {
  return const Color(0xffEDEAE9);
}

Color getDividerColor() {
  return const Color(0xff2a2c2d).withOpacity(0.3);
}

Color getDarkDividerColor() {
  return const Color(0xff2a2c2d).withOpacity(0.5);
}

Color getWhiteDividerColor() {
  return const Color(0xffffffff).withOpacity(0.9);
}

Color getTextColor() {
  return const Color(0xff2a2c2d);
}

Widget getActionButton(String text, VoidCallback callback) {
  return FlatButton(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: Color(0x00ffaca29b),
    onPressed: () {
      callback.call();
    },
    child: Text(
      text,
      style: TextStyle(fontSize: 17, color: Color(0x00fff7f7f7)),
    ),
  );
}

WhitelistingTextInputFormatter getWhitelistingTextInputFormatter() {
  return WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9(),/:'. \-]"));
}

Widget getNavButton(String text, TextStyle style, VoidCallback callback,
    {EdgeInsets padding =
        const EdgeInsets.symmetric(vertical: 10, horizontal: 8)}) {
  return RaisedButton(
    elevation: 5,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[500], width: 0.5)),
    color: Color(0x00ff430468),
    onPressed: () {
      callback.call();
    },
    child: Padding(
      padding: padding,
      child: Text(
        text,
        style: style,
      ),
    ),
  );
}

Widget getNavText(String text, TextStyle style,
    {EdgeInsets padding =
        const EdgeInsets.symmetric(vertical: 10, horizontal: 8)}) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey[500], width: 0.5)),
    color: Color(0x00ff430468),
    child: Padding(
      padding: padding,
      child: Text(
        text,
        style: style,
      ),
    ),
  );
}

getFlatButton(SizeConfig _sf, String text, Color color, VoidCallback onClick,
    {bool padding = true}) {
  return Padding(
    padding: padding
        ? EdgeInsets.only(top: 8.0, left: 16, right: 16)
        : EdgeInsets.all(0),
    child: Container(
      width: double.infinity,
      child: FlatButton(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color, width: 1),
        ),
        onPressed: onClick,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            text,
            style: _sf.getMediumStyle(color: color),
          ),
        ),
      ),
    ),
  );
}
