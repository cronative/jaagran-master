import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:jaagran/commons/common_callbacks.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'model/wallet_history_model.dart';

class RazorPayUtil {
  Razorpay _razorPay;
  String amt;
  SessionManager _sessionManager;
  VoidCallback _onPaymentSuccess;
  StringCallBack _onErrorCall;

  RazorPayUtil() {
    _razorPay = new Razorpay();
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
    _sessionManager = SessionManager.getInstance();
  }

  void makePayment({
    String amount,
    String desc,
    VoidCallback onSussess,
    StringCallBack onError,
  }) async {
    amt = (double.parse(amount) / 100).toStringAsFixed(2);
    _onErrorCall = onError;
    _onPaymentSuccess = onSussess;

    HashMap hmap = HashMap();
    hmap['amount'] = amt;

    final result = await callPostAPI("generate-order", hmap);
    printToConsole("$result");
    String orderID = json.decode(result.toString())['data']['id'];

    var options = {
      "key": _sessionManager.getRazorPayKey(),
      "amount": amount,
      "name": "SwasthyaSethu",
      "description": desc,
      "order_id": orderID,
      "prefill": {
        "contact": _sessionManager.getContactNumber(),
        "email": _sessionManager.getUserEmail()
      },
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      _razorPay.open(options);
    } catch (e) {
      print("Payment expection");
      print(e.toString());
    }
  }

  void handlerPaymentSuccess(PaymentSuccessResponse res) {
    print("Payment success $res");
    _callPaymentSuccess(res.paymentId, res.orderId, res.signature);
  }

  void handlerErrorFailure(PaymentFailureResponse res) {
    print("Payment error $res");
    print("Payment error code ${res.code}");
    _onErrorCall.call(
        res.code == 2 ? "" : res.message); //user cancel payment error code = 2
  }

  void handlerExternalWallet(ExternalWalletResponse res) {
    print("External Wallet $res");
  }

  void _callPaymentSuccess(
    String payment_id,
    String order_id,
    String signature,
  ) async {
    // https://swasthyasethu.in/api/add-to-wallet
    // activity_id, amount, activity_type, receiver_id, razorpay_payment_id, razorpay_order_id, razorpay_signature
    HashMap<String, String> params = HashMap();
    SessionManager manager = SessionManager.getInstance();
    params['activity_id'] = '0';
    params['amount'] = amt;
    params['activity_type'] = 'ADD_TO_WALLET';
    params['receiver_id'] = manager.getUserID();
    params['razorpay_payment_id'] = payment_id;
    params['razorpay_order_id'] = order_id;
    params['razorpay_signature'] = signature;

    final result = await callPostAPI("add-to-wallet", params);
    await _updateBalance();
    _onPaymentSuccess.call();
  }

  clear() {
    _razorPay.clear();
  }

  _updateBalance() async {
    final result = await callGetAPI("wallet-history", HashMap());
    WalletHistory walletHistory = walletHistoryFromJson(result.toString());
    SessionManager manager = SessionManager.getInstance();
    manager.putLastWalletBal(walletHistory.userUpdatedWallet);
  }
}
