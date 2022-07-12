import 'package:flutter/material.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/main.dart';
import 'package:jaagran/pages/common/common_functions.dart';
import 'package:jaagran/pages/settings/settings_page.dart';
import 'package:jaagran/pages/splash/flutter_restart.dart';
import 'package:jaagran/pages/wallet/my_wallet_page.dart';
import 'package:jaagran/pages/wallet/wallet_util.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';

Future<OverlayEntry> createUserOverlayEntry(BuildContext context,
    VoidCallback closeOverlay, VoidCallback onProfileClick) async {
  SizeConfig _sf = SizeConfig.getInstance(context);
  RenderBox renderBox = context.findRenderObject();
  SessionManager manager = SessionManager.getInstance();
  WalletUtil walletUtil = WalletUtil();
  var size = renderBox.size;
  OverlayEntry _overlayEntry = OverlayEntry(
      builder: (context) => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                closeOverlay.call();
              },
              child: Container(
                width: size.width,
                height: size.height,
                color: Colors.transparent,
                alignment: AlignmentDirectional.topEnd,
                child: Stack(
                  children: [
                    Positioned(
                      width: _sf.scaleSize(200),
                      right: 24,
                      top: 70,
                      child: Material(
                        elevation: 4.0,
                        type: MaterialType.card,
                        animationDuration: Duration(seconds: 1),
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.all(16),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: <Widget>[
                                Text(
                                  "Signed in as",
                                  style: _sf.getSmallStyle(
                                      color: Colors.grey[600]),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  manager.getUserName(),
                                  style: _sf.getMediumStyle(
                                      color: Theme.of(context).accentColor),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Container(
                                  height: 1,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                InkWell(
                                  onTap: () {
                                    onProfileClick.call();
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.perm_identity,
                                        size: 20,
                                        color: Colors.grey[800],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "My Profile",
                                          style: _sf.getSmallMidStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    closeOverlay.call();
                                    navigateToPageWithoutScaffold(
                                      context,
                                      MyWalletPage(),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet_outlined,
                                        size: 20,
                                        color: Colors.grey[800],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "My Wallet",
                                          style: _sf.getSmallMidStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: FutureBuilder(
                                            future: getWalletBalance(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<dynamic>
                                                    snapshot) {
                                              SessionManager manger =
                                                  SessionManager.getInstance();
                                              // if (!snapshot.hasData) {
                                              //   return Container();
                                              // }
                                              int bal = snapshot.hasData
                                                  ? snapshot.data
                                                  : manger.getLastWalletBal();
                                              manger.putLastWalletBal(bal);
                                              return Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  color: Theme.of(context)
                                                      .buttonColor,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  "\u20B9$bal",
                                                  style: _sf.getSmallStyle(
                                                      color: Colors.white),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    closeOverlay.call();
                                    navigateToPageWithoutScaffold(
                                      context,
                                      SettingsPage(),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.settings,
                                        size: 20,
                                        color: Colors.grey[800],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Settings",
                                          style: _sf.getSmallMidStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    manager.clearAllData();
                                    closeOverlay.call();
                                    FlutterRestart.restartApp(context);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        size: 20,
                                        color: Colors.grey[800],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Logout",
                                          style: _sf.getSmallMidStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // SizedBox(
                                //   height: 8,
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));
  return _overlayEntry;
}
