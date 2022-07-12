import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/wallet/razor_pay_util.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';

class WalletUtil {
  int _balance;

  static final WalletUtil _instance = WalletUtil._internal();
  SessionManager _manager;

  factory WalletUtil() {
    return _instance;
  }

  WalletUtil._internal() {
    _manager = SessionManager();
    _getWalletBalance();
  }

  void _getWalletBalance() {
    _balance = _manager.getLastWalletBal();
  }

  void updateBal() {
    _balance = _manager.getLastWalletBal();
  }

  bool _paymentInProcess = false;
  void showAddMoneyBottomSheet({BuildContext context,VoidCallback onSuccess}) {
    SizeConfig _sf = SizeConfig.getInstance(context);
    TextEditingController _amtController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
            topEnd: Radius.circular(20),
            topStart: Radius.circular(20),
          )),
      builder: (builder) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8,
              ),
              Text(
                "Add Money",
                style: _sf.getSmallStyle(
                    color: Color(0x00ff8D8AA0), fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 16,
              ),
              TextField(
                controller: _amtController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: "Amount",
                ),
                minLines: 1,
                maxLines: 1,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: false, signed: false),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    onTap: () {
                      _amtController.text = '50';
                      _amtController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _amtController.text.length));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0x00ffF3F2FD),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Text(
                        "+50",
                        style: _sf.getSmallStyle(
                            color: Color(0x00ff3828F5),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    onTap: () {
                      _amtController.text = '100';
                      _amtController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _amtController.text.length));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0x00ffF3F2FD),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Text(
                        "+100",
                        style: _sf.getSmallStyle(
                            color: Color(0x00ff3828F5),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    onTap: () {
                      _amtController.text = '500';
                      _amtController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _amtController.text.length));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0x00ffF3F2FD),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Text(
                        "+500",
                        style: _sf.getSmallStyle(
                            color: Color(0x00ff3828F5),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    onTap: () {
                      _amtController.text = '1000';
                      _amtController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _amtController.text.length));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0x00ffF3F2FD),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Text(
                        "+1000",
                        style: _sf.getSmallStyle(
                            color: Color(0x00ff3828F5),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              SizedBox(
                width: double.infinity,
                child: getNavButton(
                  "Add",
                  _sf.getCaviarDreams(),
                      () {
                    if (!isAddPaymentCall) {
                      isAddPaymentCall = true;
                      double amount =
                          double.parse(_amtController.text.trim()) * 100;

                      RazorPayUtil _util = RazorPayUtil();
                      _util.makePayment(
                          amount: amount.toStringAsFixed(2),
                          desc: "Add Money To Wallet",
                          onSussess: () {
                            updateBal();
                            Navigator.of(context).pop();
                            isAddPaymentCall = false;
                            onSuccess.call();
                          },
                          onError: (res) {
                            printToConsole("res : $res");
                            isAddPaymentCall = false;
                            if (res.isEmpty) {
                              String msg =
                              json.decode(res)['error']['description'];
                              showErrorAlertDialog(context, msg);
                            }
                          });
                    }
                  },
                  padding: EdgeInsets.symmetric(
                    vertical: _sf.scaleSize(12),
                    horizontal: _sf.scaleSize(20),
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
            ],
          ),
        );
      },
    );
  }
  bool isAddPaymentCall =false;
  void showPaymentSheet({
    BuildContext context,
    String title,
    String id,
    String sender_id,
    String type = '',
    String amount,
    VoidCallback onSuccess,
  }) {
    this.activity_id = id;
    this.receiver_id = sender_id;
    this.activity_type = type;
    this.amount = amount;

    SizeConfig _sf = SizeConfig.getInstance(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
        topEnd: Radius.circular(20),
        topStart: Radius.circular(20),
      )),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 8,
                  ),
                  // Text(
                  //   "Pay for",
                  //   style: _sf.getSmallStyle(
                  //       color: Color(0x00ff8D8AA0),
                  //       fontWeight: FontWeight.w600),
                  // ),
                  // SizedBox(
                  //   height: 8,
                  // ),
                  Text(
                    title,
                    style: _sf.getSmallStyle(
                        color: Color(0x00ff8D8AA0),
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    enabled: false,
                    controller: TextEditingController(text: "\u20B9 "+amount),
                    decoration: InputDecoration(
                      enabled: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // hintText: "Amount",
                    ),
                    minLines: 1,
                    maxLines: 1,
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: false, signed: false),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: _sf.scaleSize(45),
                    child: _paymentInProcess
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : getNavButton(
                            "Pay",
                            _sf.getCaviarDreams(),
                            () {
                              setState(() {
                                _paymentInProcess = true;
                              });
                              _callWithDrawWalletAPI(
                                  context, setState, onSuccess);
                            },
                            padding: EdgeInsets.symmetric(
                              vertical: _sf.scaleSize(12),
                              horizontal: _sf.scaleSize(20),
                            ),
                          ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  get balance => _manager.getLastWalletBal();

  String activity_id;
  String amount;
  String activity_type;
  String receiver_id;

  _callWithDrawWalletAPI(BuildContext context, StateSetter setState,
      VoidCallback onSuccess) async {
    // https://swasthyasethu.in/api/withdraw-from-wallet
    // params:- activity_id, amount, activity_type, receiver_id,
    // razorpay_payment_id, razorpay_order_id, razorpay_signature

    HashMap params = HashMap();
    params['activity_id'] = activity_id;
    params['amount'] = amount;
    params['activity_type'] = activity_type;
    params['receiver_id'] = receiver_id;
    final result = await callPostAPI("withdraw-from-wallet", params);
    // {"status":"success","message":"Transaction successfully","user_updated_wallet":430}
    Map<String, dynamic> response = json.decode(result.toString());
    if (response['status'] == 'success') {
      _manager.putLastWalletBal(response['user_updated_wallet']);
      setState(() {
        _paymentInProcess = false;
      });
      onSuccess.call();
    } else {
      showErrorAlertDialog(context, response['message']);
    }
  }
}
