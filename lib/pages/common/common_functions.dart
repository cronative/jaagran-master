import 'dart:collection';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/seeking/parts/comment_field.dart';
import 'package:jaagran/pages/wallet/model/wallet_history_model.dart';
import 'package:jaagran/utils/web_utils.dart';

Future<bool> callSeekViewLike(String seek_id, String type) async {
  HashMap<String, String> params = HashMap();
  params['seek_detail_id'] = seek_id;
  params['type'] = type;
  final result = await callPostAPI("seek-view-like", params);
  return true;
}

Future<bool> callThreadViewLike(int threadID, String type) async {
  HashMap<String, String> params = HashMap();
  params['seek_thread_id'] = "$threadID";
  params['type'] = type;
  final result = await callPostAPI("thread-view-like", params);
  return true;
}

Future<File> compressImage(File file) async {
  String path = file.path;
  int fileLength = await file.length();
  fileLength = (fileLength / 1024).round();
  if (fileLength < 200) {
    return file;
  }
  int qlty = 80;
  printToConsole("SizeBefore compress ${fileLength}");

  if (fileLength > 10000) {
    qlty = 25;
  } else if (fileLength > 7500) {
    qlty = 35;
  } else if (fileLength > 5000) {
    qlty = 40;
  } else if (fileLength > 3000) {
    qlty = 50;
  } else if (fileLength > 2000) {
    qlty = 60;
  } else if (fileLength > 1000) {
    qlty = 70;
  }

  printToConsole("SizeBefore qty ${qlty}");

  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    _getTargetPath(path),
    quality: qlty,
  );

  printToConsole("Sizeafter compress ${result.lengthSync() / 1024}");

  return result;
}

String _getTargetPath(String path) {
  List<String> lstStr = path.split(".");
  String ext = lstStr[lstStr.length - 1];
  return path.replaceAll(".$ext", "_com.$ext");
}

void updateWalletBalance() async {
  int bal = await getWalletBalance();
  SessionManager manager = SessionManager.getInstance();
  manager.putLastWalletBal(bal);
}

Future<int> getWalletBalance() async {
  final result = await callGetAPI("wallet-history", HashMap());
  WalletHistory walletHistory = walletHistoryFromJson(result.toString());
  return walletHistory.userUpdatedWallet;
}
