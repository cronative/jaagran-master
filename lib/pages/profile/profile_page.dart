import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/chat/chat_screen.dart';
import 'package:jaagran/pages/chat/models/chat_index.dart';
import 'package:jaagran/pages/chat/models/user_model.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/landing/landing_controller.dart';
import 'package:jaagran/pages/landing/landing_page.dart';
import 'package:jaagran/pages/landing/model/seeking_model.dart';
import 'package:jaagran/pages/liveSessions/live_session_request_page.dart';
import 'package:jaagran/pages/profile/review/review_modal_sheet.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../landing/seeking_tab.dart';
import 'model/profile_model.dart';

class ProfilePage extends StatefulWidget {
  final String user_id;
  final bool isSelf;

  const ProfilePage({Key key, this.user_id, this.isSelf = false})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  SizeConfig _sf;
  TabController _controller_tab;
  Future<ProfileModel> _post;
  Color accentColor;
  bool isSelf;
  bool isFollow = false;
  bool followAPICall = false;
  bool isAPICall = false;

  Future<SeekingModel> _postBooks;
  Future<SeekingModel> _postVideo;
  Future<SeekingModel> _postAudio;
  Future<SeekingModel> _postSeeking;
  // LandingController _landingController = Get.put(LandingController());

  @override
  void initState() {
    super.initState();
    isSelf = widget.isSelf;
    _checkIsSelf();
    _post = _getUserData();
    _postBooks = _callSeekingApi("B");
    _postVideo = _callSeekingApi("V");
    _postAudio = _callSeekingApi("A");
    _postSeeking = _callSeekingApi("Q");
    _controller_tab = TabController(length: 4, vsync: this);
  }

  Future<SeekingModel> _callSeekingApi(String type) async {
    HashMap params = HashMap();
    // params["user_id"] = widget.user_id;
    // params["list_type"] = type;
    // params["page[number]"] = "1";
    // final result = await callPostAPI("seeking", params);
    params["user_id"] = widget.user_id;
    params["list_type"] = type;
    params["page[number]"] = "1";
    final result = await callPostAPI("profile-activities", params);
    final response = json.decode(result.toString());
    SeekingModel model = SeekingModel.fromJson(response);
    return model;
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    accentColor = Theme.of(context).accentColor;
    return ModalProgressHUD(
      inAsyncCall: isAPICall,
      child: FutureBuilder(
        future: _post,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: getCommonAppBar(context, _sf),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          ProfileModel profile = snapshot.data;
          // return Scaffold(
          //     appBar: getCommonAppBar(context, _sf),
          //     body: DefaultTabController(
          //       length: 4,
          //       child: extend.NestedScrollView(
          //           headerSliverBuilder: (c, f) {
          //             return <Widget>[
          //               SliverAppBar(
          //                 backgroundColor: Colors.white,
          //                 floating: false,
          //                 pinned: true,
          //                 primary: true,
          //                 forceElevated: true,
          //                 leading: Icon(
          //                   Icons.ac_unit,
          //                   size: 0,
          //                 ),
          //                 centerTitle: false,
          //                 expandedHeight: _sf.scaleSize(isSelf ? 270 : 300),
          //                 flexibleSpace: FlexibleSpaceBar(
          //                   collapseMode: CollapseMode.pin,
          //                   background: PreferredSize(
          //                     preferredSize: Size.fromHeight(30),
          //                     child: _getProfileView(profile),
          //                   ),
          //                 ),
          //                 bottom: _tabBar(profile),
          //               ),
          //             ];
          //           },
          //
          //           body: Column(
          //             children: <Widget>[
          //               // _tabBar(profile),
          //               Expanded(
          //                 child: _tabs(),
          //               )
          //             ],
          //           )),
          //     ));

          return DefaultTabController(
            length: 4,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: getCommonAppBar(context, _sf),
              body: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                      sliver: SliverAppBar(
                        backgroundColor: Colors.white,
                        floating: true,
                        pinned: true,
                        primary: true,
                        forceElevated: true,
                        leading: Icon(
                          Icons.ac_unit,
                          size: 0,
                        ),
                        centerTitle: false,
                        expandedHeight: _sf.scaleSize(isSelf
                            ? profile.isExpert
                                ? 200
                                : 175
                            : profile.isExpert
                                ? 230
                                : 190),
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          background: PreferredSize(
                            preferredSize: Size.fromHeight(30),
                            child: _getProfileView(profile),
                          ),
                        ),
                        bottom: _tabBar(profile),
                      ),
                    ),
                  ];
                },
                body: _tabs(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getProfileView(ProfileModel profile) {
    printToConsole("screen size ${_sf.scaleSize(100)}");
    return Padding(
      padding: EdgeInsets.all(_sf.scaleSize(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: _sf.scaleSize(6),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: AlignmentDirectional.center,
                    padding: EdgeInsets.only(left: 4),
                    child: FutureBuilder<String>(
                      future: _getUserDp(profile.dp),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasData) {
                          String dp = snapshot.data.toString().trim();
                          // printToConsole("user dp : $dp");
                          if (dp.isNotEmpty) {
                            return CircleAvatar(
                              radius: _sf.scaleSize(45),
                              backgroundImage: AssetImage(
                                  "assets/images/dp_circular_avatar.png"),
                              backgroundColor: Colors.transparent,
                              child: CircleAvatar(
                                radius: _sf.scaleSize(45),
                                backgroundImage: NetworkImage(
                                  dp,
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                            );
                          }
                        }
                        return CircleAvatar(
                          radius: _sf.scaleSize(45),
                          backgroundImage: AssetImage(
                              "assets/images/dp_circular_avatar.png"),
                          backgroundColor: Colors.transparent,
                        );
                      },
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                         crossAxisAlignment: CrossAxisAlignment.center,
                         mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // _getReviewBtn(),
                          widget.isSelf
                              ? Container()
                              : InkWell(
                                  onTap: _callBlockAPI,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      "Block",
                                      style: _sf.getSmallMidStyle(
                                        color: Theme.of(context).accentColor,
                                        // decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                          if (profile.isExpert && !isSelf)
                            _getSeekSessionBtn(profile)
                          else
                            Container(),
                        ],
                      )),
                ],
              ),
              SizedBox(
                width: _sf.scaleSize(8),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: _sf.getScreenWidth() / 2,
                    padding: EdgeInsets.all(_sf.scaleSize(8)),
                    child: Text(
                      _getName(profile),
                      style: _sf.getLargeStyle(
                          color: const Color(0x00ff805B97),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  profile.isExpert
                      ? Container(
                          width: _sf.getScreenWidth() / 2,
                          padding: EdgeInsets.all(_sf.scaleSize(6)),
                          child: Text(
                            "Expertise : ${profile.expertise}",
                            style: _sf.getMediumStyle(color: Colors.black87),
                          ),
                        )
                      : Container(),
                  profile.isExpert
                      ? Container(
                          width: _sf.getScreenWidth() / 2,
                          padding: EdgeInsets.all(_sf.scaleSize(6)),
                          child: Text(
                            "Trained from : ${profile.trained_with == 'null' ? "" : profile.trained_with}",
                            style: _sf.getMediumStyle(color: Colors.black87),
                          ),
                        )
                      : Container(),

                  // Padding(
                  //   padding: EdgeInsets.all(_sf.scaleSize(6)),
                  //   child: Text(
                  //     "Solution Given  :  ${profile.solution_given}",
                  //     style: _sf.getMediumStyle(color: Colors.black87),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.all(_sf.scaleSize(6)),
                  //   child: Text(
                  //     "Helpful Votes :  ${profile.helpfull_votes}",
                  //     style: _sf.getMediumStyle(color: Colors.black87),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.all(_sf.scaleSize(6)),
                  //   child: Text(
                  //     "Likes  :  ${profile.likes}",
                  //     style: _sf.getMediumStyle(color: Colors.black87),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.all(_sf.scaleSize(6)),
                  //   child: Text(
                  //     "Reviews  :  ${profile.reviews}",
                  //     style: _sf.getMediumStyle(color: Colors.black87),
                  //   ),
                  // ),
                  isSelf
                      ? Container(
                          height: 12,
                        )
                      : Padding(
                          padding: EdgeInsets.all(8.0),
                          child: _getButtons(profile)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Future<ProfileModel> _getUserData() async {
    HashMap params = HashMap();
    params['user_id'] = widget.user_id;
    final result = await callPostAPI("profile", params);
    final response = json.decode(result.toString());
    if (response['status'] == 'success') {
      ProfileModel model = ProfileModel.fromJson(response['data']);
      model.id = widget.user_id;
      isFollow = model.isFollow;
      return model;
    } else {
      showErrorAlertDialog(context, response['message']);
      return null;
    }
  }

  Future<String> _getUserDp(String dp) async {
    SessionManager manager = SessionManager.getInstance();
    if (dp.isEmpty || dp == "null") return "";
    return Server_URL + manager.getDpPath() + dp;
  }

  _getSeekSessionBtn(ProfileModel profile) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () {
        navigateToPageWithoutScaffold(
          context,
          LiveSessionRequestPage(
            profile: profile,
          ),
        );
      },
      child: Text(
        "Seek Session",
        style: _sf.getSmallStyle(color: Colors.white),
      ),
    );
  }

  // _getReviewBtn() {
  //   return RaisedButton(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  //     onPressed: () {
  //       openReviewModelSheet(context, widget.user_id, isSelf);
  //     },
  //     child: Text(
  //       "Reviews",
  //       style: _sf.getSmallStyle(color: Colors.white),
  //     ),
  //   );
  // }

  _getButtons(ProfileModel profile) {

    return isSelf
        ? Container()
        : Row(
            children: [
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () {
                  _checkInChatIndex(profile);
                },
                child: Text(
                  "Chat",
                  style: _sf.getSmallStyle(color: Colors.white),
                ),
              ),
              SizedBox(
                width: _sf.scaleSize(8),
              ),
              followAPICall
                  ? Container(
                      width: 80,
                      child: Center(
                        child: Container(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator()),
                      ),
                    )
                  : RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: () {
                        _callFollowingApi();
                      },
                      child: Text(
                        isFollow ? "Unfollow" : "Follow",
                        style: _sf.getSmallStyle(color: Colors.white),
                      ),
                    ),
            ],
          );
  }

  void _checkIsSelf() async {
    SessionManager manager = SessionManager.getInstance();
    String currentUserID = manager.getUserID();
    if (currentUserID == widget.user_id) {
      isSelf = true;
    }
  }

  void _callFollowingApi() async {
    setState(() {
      followAPICall = true;
    });
    HashMap params = HashMap();
    params['user_id'] = widget.user_id;
    final result = await callPostAPI("create-follow", params);
    final response = json.decode(result.toString());
    if (response['status'] == 'success') {
      setState(() {
        isFollow = !isFollow;
      });
    } else {
      showErrorAlertDialog(context, response['message']);
    }
    setState(() {
      followAPICall = false;
    });
  }

  _tabs() {
    return TabBarView(
      controller: _controller_tab,
      dragStartBehavior: DragStartBehavior.start,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Builder(
          builder: (BuildContext context) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context)),
                SliverList(
                  delegate: SliverChildBuilderDelegate((_, index) {
                    return SeekingTab(
                      type: "B",
                      postData: _postBooks,
                      user_id: widget.user_id,
                    );
                  }, childCount: 1),
                ),
              ],
            );
          },
        ),
        Builder(
          builder: (BuildContext context) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context)),
                SliverList(
                  delegate: SliverChildBuilderDelegate((_, index) {
                    return SeekingTab(
                      type: "V",
                      postData: _postVideo,
                      user_id: widget.user_id,
                    );
                  }, childCount: 1),
                ),
              ],
            );
          },
        ),
        Builder(
          builder: (BuildContext context) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context)),
                SliverList(
                  delegate: SliverChildBuilderDelegate((_, index) {
                    return SeekingTab(
                      type: "A",
                      postData: _postAudio,
                      user_id: widget.user_id,
                    );
                  }, childCount: 1),
                ),
              ],
            );
          },
        ),
        Builder(
          builder: (BuildContext context) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context)),
                SliverList(
                  delegate: SliverChildBuilderDelegate((_, index) {
                    return SeekingTab(
                      type: "Q",
                      postData: _postSeeking,
                      user_id: widget.user_id,
                    );
                  }, childCount: 1),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  _tabBar(profile) {
    return TabBar(
        isScrollable: true,
        indicatorWeight: 5,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: Color(0x00ffC4AAEE),
        controller: _controller_tab,
        labelPadding: EdgeInsets.symmetric(
          horizontal: _sf.scaleSize(8),
          vertical: 0,
        ),
        tabs: [
          Tab(
            child: Text(
              "eBooks(${profile.books})",
              style: _sf.getExtraSmallStyle(color: accentColor),
            ),
          ),
          Tab(
            child: Text(
              "Videos(${profile.videos})",
              style: _sf.getExtraSmallStyle(color: accentColor),
            ),
          ),
          Tab(
            child: Text(
              "Audios(${profile.audios})",
              style: _sf.getExtraSmallStyle(color: accentColor),
            ),
          ),
          Tab(
            child: Text(
              "Seeking(${profile.posts})",
              style: _sf.getExtraSmallStyle(color: accentColor),
            ),
          ),
        ]);
  }

  void _checkInChatIndex(ProfileModel profile) async {
    SessionManager sessionManager = SessionManager.getInstance();
    setState(() {
      isAPICall = true;
    });
    final result = await callGetAPI("chat-index", HashMap());
    final response = json.decode(result.toString());
    List<ChatIndex> lstChatIndex = [];
    setState(() {
      isAPICall = false;
    });
    if (response['status'] == 'success') {
      lstChatIndex = ChatIndex.getList(response['message']);
    } else {
      showErrorAlertDialog(context, someThingWentWrong);
      return;
    }
    bool isFound = false;
    for (int i = 0; i < lstChatIndex.length; i++) {
      if (widget.user_id == lstChatIndex[i].sender_id) {
        isFound = true;
        break;
      }
    }
    if (!isFound) {
      showErrorAlertDialog(context,
          "${profile.name} is not in your chat, send chat request first.");
    } else {
      navigateToPageWithoutScaffold(
          context,
          ChatScreen(
            user: ChatUser(
              id: widget.user_id,
              name: profile.name,
              imageUrl: getImageUrl(sessionManager.getDpPath() + profile.dp),
            ),
          ));
    }
  }

  String _getName(ProfileModel profile) {
    String name = profile.title;
    name += name.isEmpty ? "" : " ";
    name += profile.name;
    return name;
  }

  void _callBlockAPI() async {
    setState(() {
      isAPICall = true;
    });
    HashMap params = HashMap();
    params['user_id'] = widget.user_id;
    final result = await callPostAPI("block-user-create", params);
    final response = json.decode(result.toString());
    setState(() {
      isAPICall = false;
    });
    if (response['status'] == 'success') {
      showSuccessAlertDialog(context, response['message'], isCancelable: false,
          callback: () {
        Navigator.of(context).popUntil(ModalRoute.withName("/landing"));
            // _landingController.onBlockUserChange.call();
            Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            settings: RouteSettings(name: "/landing"),
            builder: (context) => LandingPage(),
          ),
        );
      });
    } else {
      showErrorAlertDialog(context, response['message']);
    }
  }
}
