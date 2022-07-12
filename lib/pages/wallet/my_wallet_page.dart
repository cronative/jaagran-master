import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_functions.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/appbar/header_widget.dart';
import 'package:jaagran/pages/wallet/razor_pay_util.dart';
import 'package:jaagran/pages/wallet/wallet_util.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'model/wallet_history_model.dart';

class MyWalletPage extends StatefulWidget {
  @override
  _MyWalletPageState createState() => _MyWalletPageState();
}

class _MyWalletPageState extends State<MyWalletPage> {
  SizeConfig _sf;
  WalletUtil _walletUtil;
  SessionManager _sessionManager;
  List<WalletHistoryModel> lstWalletHisModel = [];
  bool isAPICall = false;

  int last_page;
  int pageNumber = 1;

  @override
  void initState() {
    super.initState();
    _walletUtil = WalletUtil();
    _sessionManager = SessionManager.getInstance();
    _scrollController.addListener(() {
      if (!isAPICall &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          (pageNumber != last_page)) {
        pageNumber++;
        _callWalletHistory(false);
      }
    });
    _callWalletHistory(true);
  }

  _callWalletHistory(bool isToClear) async {
    isAPICall = true;
    final result =
        await callGetAPI("wallet-history?page[number]=$pageNumber", HashMap());
    WalletHistory walletHistory = walletHistoryFromJson(result.toString());
    _sessionManager.putLastWalletBal(walletHistory.userUpdatedWallet);
    _walletUtil.updateBal();
    if (isToClear) {
      lstWalletHisModel.clear();
    }
    last_page = walletHistory.data.lastPage;
    lstWalletHisModel.addAll(walletHistory.data.data);
    isAPICall = false;
    setState(() {});
  }

  ScrollController _scrollController = ScrollController();

  Widget _view() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: lstWalletHisModel.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _topView();
        } else {
          if (lstWalletHisModel.length == index - 1) {
            return last_page != pageNumber && isAPICall
                ? Container(
                    padding: EdgeInsets.only(top: 16, bottom: 32),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container();
          }
          return _getWalletHistoryItemView(lstWalletHisModel[index - 1]);
        }
      },
    );
  }

  _topView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderWidget(
          title: "Wallet",
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Container(
              padding: EdgeInsets.all(12.0),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Balance",
                    style: _sf.getSmallStyle(
                        color: Color(0x00ff8D8AA0),
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "\u20B9${_sessionManager.getLastWalletBal()}",
                    style: _sf.getExtraExtraLargeStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      _walletUtil.showAddMoneyBottomSheet(
                        context: context,
                        onSuccess: () {
                          pageNumber = 1;
                          _callWalletHistory(true);
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color(0x00ffF3F2FD),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "+ Add Money",
                        style: _sf.getMediumStyle(
                            color: Color(0x00ff3828F5),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        lstWalletHisModel.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Transaction History",
                  textAlign: TextAlign.start,
                  style: _sf.getMediumStyle(
                      color: Color(0x00ff8D8AA0), fontWeight: FontWeight.w600),
                ),
              )
            : Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      appBar: getCommonAppBar(context, _sf),
      body: _view(),
    );
  }

  bool isAddPaymentCall = false;

  _getWalletHistoryItemView(WalletHistoryModel model) {
    bool isDebit = model.transectionType.trim().toLowerCase() == 'debit';
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.only(left: 8, right: 8, bottom: 4),
      child: Padding(
        padding: EdgeInsets.only(
          right: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: _sf.scaleSize(45),
              width: _sf.scaleSize(45),
              color: isDebit ? Colors.red[100] : Colors.green[100],
              child: Center(
                child: Icon(
                  isDebit
                      ? Icons.arrow_back_rounded
                      : Icons.arrow_forward_rounded,
                  color: isDebit ? Colors.red : Colors.green,
                ),
              ),
            ),
            Container(
              width: _sf.getScreenWidth() - _sf.scaleSize(120),
              padding: const EdgeInsets.all(8.0),
              alignment: AlignmentDirectional.centerStart,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.title,
                    maxLines: 3,
                    style: _sf.getSmallMidStyle(
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    getFormattedDateForAPI(model.createdAt) +
                        " " +
                        DateFormat('hh:mm a').format(model.createdAt),
                    maxLines: 3,
                    style: _sf.getSmallStyle(
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: _sf.scaleSize(45),
              child: Center(
                child: Text(
                  '\u20B9${model.amount}',
                  style: _sf.getSmallStyle(
                    color: isDebit ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
