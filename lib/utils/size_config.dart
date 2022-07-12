import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jaagran/commons/strings.dart';

class SizeConfig {
  MediaQueryData _mediaQueryData;
  double _screenWidth;
  double _screenHeight;
  double _blockSizeHorizontal;
  double _blockSizeVertical;

  double _pixelSize;
  double extraLargeFont;
  double extraExtraLargeFont;
  double largeFont;
  double midFont;
  double smallFont;
  double smallMid;
  double extraSmallFont;
  double extraExtraSmallFont;

  static SizeConfig _instance;

  static getInstance(BuildContext context) {
    if (_instance == null) {
      _instance = SizeConfig(context);
    }
    return _instance;
  }

  SizeConfig(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height ;
    // printToConsole("ratio ${_mediaQueryData.devicePixelRatio}");
    var padding = MediaQuery.of(context).padding;
    _screenHeight = _screenHeight - padding.top - padding.bottom;
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;
    _pixelSize = (_screenWidth + _screenHeight) / 1000;
    if (_pixelSize >= 1.3) {
      _pixelSize = 1.3;
    }

    extraExtraLargeFont = 21 * _pixelSize;
    extraLargeFont = 18 * _pixelSize;
    largeFont = 15 * _pixelSize;
    midFont = 13.5 * _pixelSize;
    smallMid = 12.5 * _pixelSize;
    smallFont = 12 * _pixelSize;
    extraSmallFont = 11 * _pixelSize;
    extraExtraSmallFont = 10 * _pixelSize;

    bool isTablet = isTab();
    if (isTablet) {
      _pixelSize = 1.4;
    }
  }

  double width(double size) {
    return _blockSizeHorizontal * size;
  }

  double height(double size) {
    return _blockSizeVertical * size;
  }

  double getScreenHeight() {
    return _screenHeight;
  }

  double getScreenWidth() {
    return _screenWidth;
  }

  double scaleSize(double size) {
    return _pixelSize * size;
  }

  bool isTab() {
    var size = _mediaQueryData.size;
    var diagonal =
        sqrt((size.width * size.width) + (size.height * size.height));

    var isTablet = diagonal > 1100.0;
    return isTablet;
  }

  bool isMobile() {
    return !isTab();
  }

  TextStyle getCustomStyle({
    double fontSize,
    Color color,
    TextDecoration decoration,
    FontWeight fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize == null ? midFont : scaleSize(fontSize),
      color: color ?? Colors.black87,
      decoration: decoration ?? TextDecoration.none,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  TextStyle getExtraExtraLargeStyle({
    Color color,
    TextDecoration decoration,
    FontWeight fontWeight,
  }) {
    return TextStyle(
      fontSize: extraExtraLargeFont,
      color: color ?? Colors.black87,
      decoration: decoration ?? TextDecoration.none,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  TextStyle getExtraLargeStyle({
    Color color,
    TextDecoration decoration,
    FontWeight fontWeight,
  }) {
    return TextStyle(
      fontSize: extraLargeFont,
      color: color ?? Colors.black87,
      decoration: decoration ?? TextDecoration.none,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  TextStyle getLargeStyle({
    double fontSize,
    Color color,
    TextDecoration decoration,
    FontWeight fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? largeFont,
      color: color ?? Colors.black87,
      decoration: decoration ?? TextDecoration.none,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  TextStyle getMediumStyle({
    Color color,
    TextDecoration decoration,
    FontWeight fontWeight,
  }) {
    return TextStyle(
      fontSize: midFont,
      color: color ?? Colors.black87,
      decoration: decoration ?? TextDecoration.none,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  TextStyle getSmallStyle({
    Color color,
    TextDecoration decoration,
    FontWeight fontWeight,
  }) {
    return TextStyle(
      fontSize: smallFont,
      color: color ?? Colors.black87,
      decoration: decoration ?? TextDecoration.none,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  TextStyle getSmallMidStyle({
    Color color,
    TextDecoration decoration,
    FontWeight fontWeight,
  }) {
    return TextStyle(
      fontSize: smallMid,
      color: color ?? Colors.black87,
      decoration: decoration ?? TextDecoration.none,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  TextStyle getExtraSmallStyle({
    Color color,
    TextDecoration decoration,
    FontWeight fontWeight,
  }) {
    return TextStyle(
      fontSize: extraSmallFont,
      color: color ?? Colors.black87,
      decoration: decoration ?? TextDecoration.none,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

// TextStyle getExtraExtraSmallStyle({
//     Color color,
//     TextDecoration decoration,
//     FontWeight fontWeight,
//   }) {
//     return TextStyle(
//       fontSize: extraExtraSmallFont,
//       color: color ?? Colors.black87,
//       decoration: decoration ?? TextDecoration.none,
//       fontWeight: fontWeight ?? FontWeight.normal,
//     );
//   }

  TextStyle getExtraExtraSmallStyle({
    double fontSize,
    Color color,
    TextDecoration decoration,
    FontWeight fontWeight,
  }) {
    return TextStyle(
      fontSize: fontSize ?? extraExtraSmallFont,
      color: color ?? Colors.black87,
      decoration: decoration ?? TextDecoration.none,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  TextStyle getCaviarDreams({
    double fontSize = 14,
    Color color = Colors.white,
    TextDecoration decoration,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return TextStyle(
      fontSize: scaleSize(fontSize),
      fontFamily: 'caviar_dreams',
      color: color ?? Colors.black87,
      decoration: decoration ?? TextDecoration.none,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }
}
