import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/common_functions.dart';
import 'package:jaagran/pages/landing/landing_controller.dart';
import 'package:jaagran/pages/landing/model/seeking_model.dart';
import 'package:jaagran/pages/landing/version_check.dart';
import 'package:jaagran/pages/seeking/create_seek.dart';
import 'package:jaagran/utils/fcm_service.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';

import 'seeking_tab.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  SizeConfig _sf;
  TabController _tabController;
  Future<SeekingModel> _postMe;
  Future<SeekingModel> _postRecent;
  Future<SeekingModel> _postPopular;
  Future<SeekingModel> _postSuggestion;
  LandingController _landingController = Get.put(LandingController());

  @override
  void initState() {
    super.initState();
    registerDeviceToFCM();
    _postMe = _callSeekingApi("me");
    _postRecent = _callSeekingApi("recent");
    _postPopular = _callSeekingApi("popular");
    _postSuggestion = _callSeekingApi("suggestion");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      VersionCheck(context);
      updateWalletBalance();
    });
    _landingController.onBlockUserChangeListener(() {
      printToConsole("_landingController.onBlockUserChangeListener");

      setState(() {});
      _postMe = _callSeekingApi("me");
      _postRecent = _callSeekingApi("recent");
      _postPopular = _callSeekingApi("popular");
      _postSuggestion = _callSeekingApi("suggestion");
    });
  }

  Future<SeekingModel> _callSeekingApi(String type) async {
    HashMap params = HashMap();
    params["type"] = type;
    params["page[number]"] = "1";
    final result = await callPostAPI("seeking", params);
    final response = json.decode(result.toString());
    SeekingModel model = SeekingModel.fromJson(response);
    return model;
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    Color accentColor = Theme.of(context).accentColor;
    return Scaffold(
      appBar: getCommonAppBar(context, _sf),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: AlignmentDirectional.center,
              color: Colors.white,
              padding: EdgeInsets.only(
                  bottom: _sf.scaleSize(4), top: _sf.scaleSize(16)),
              child: Text(
                "Seeking",
                style: _sf.getLargeStyle(color: accentColor),
              ),
            ),
            DefaultTabController(
              length: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      isScrollable: true,
                      indicatorWeight: 5,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: Color(0x00ffC4AAEE),
                      labelPadding: EdgeInsets.symmetric(
                        horizontal: _sf.scaleSize(12),
                        vertical: 0,
                      ),
                      tabs: [
                        Tab(
                          child: Text(
                            " Me ",
                            style: _sf.getCustomStyle(
                                fontSize: 13, color: Colors.black45),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Recent",
                            style: _sf.getCustomStyle(
                                fontSize: 13, color: Colors.black45),
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Popular",
                            style: _sf.getCustomStyle(
                                fontSize: 13, color: Colors.black45),
                          ),
                        ),
                        Container(
                          // width: _sf.scaleSize(90),
                          child: Tab(
                            child: Text(
                              "Suggestion",
                              style: _sf.getCustomStyle(
                                  fontSize: 13, color: Colors.black45),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 0.5,
                    color: Colors.black38,
                  ),
                  Container(
                    height: _sf.getScreenHeight() - _sf.scaleSize(185),
                    child: TabBarView(controller: _tabController, children: [
                      SeekingTab(
                        type: "me",
                        postData: _postMe,
                      ),
                      SeekingTab(
                        type: "recent",
                        postData: _postRecent,
                      ),
                      SeekingTab(
                        type: "popular",
                        postData: _postPopular,
                      ),
                      SeekingTab(
                        type: "suggestion",
                        postData: _postSuggestion,
                      ),
                    ]),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        alignment: AlignmentDirectional.center,
        color: Theme.of(context).buttonColor,
        child: getNavButton(
          "Seek",
          _sf.getCaviarDreams(),
          () => navigateToPageWithoutScaffold(context, CreateSeek()),
          padding: EdgeInsets.symmetric(
            vertical: _sf.scaleSize(8),
            horizontal: _sf.scaleSize(20),
          ),
        ),
      ),
    );
  }
}
