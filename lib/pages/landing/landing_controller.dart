import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:get/state_manager.dart';

class LandingController extends GetxController {
  changeValue() async {
    update();
  }

  VoidCallback onBlockUserChange;

  onBlockUserChangeListener(VoidCallback call) {
    this.onBlockUserChange = call;
  }
}
