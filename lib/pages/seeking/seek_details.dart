import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/commons/widgets/flag_icon.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/common_functions.dart';
import 'package:jaagran/pages/landing/model/seeking_model.dart';
import 'package:jaagran/pages/profile/profile_page.dart';
import 'package:jaagran/pages/seeking/model/thread_details.dart';
import 'package:jaagran/pages/seeking/parts/comment_field.dart';
import 'package:jaagran/pages/seeking/parts/media_view.dart';
import 'package:jaagran/pages/seeking/parts/thread_view.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class SeekingDetails extends StatefulWidget {
  final SeekingData seekingData;
  final VoidCallback onChange;

  const SeekingDetails(this.seekingData, this.onChange);

  @override
  _SeekingDetailsState createState() => _SeekingDetailsState();
}

class _SeekingDetailsState extends State<SeekingDetails> {
  bool isApiCall = false;

  SizeConfig _sf;
  Future<ThreadDetails> _postThreadList;
  List<ThreadInfo> lstThreadInfo;
  bool isLikeCall = false;
  bool isSeekLock = false;
  bool showReleaseLock = false;

  @override
  void initState() {
    super.initState();
    if (!widget.seekingData.isSeen) {
      callSeekViewLike(widget.seekingData.id, "view");
      widget.seekingData.isSeen = true;
      int totalViews = int.parse(widget.seekingData.total_views);
      totalViews += 1;
      widget.seekingData.total_views = "$totalViews";
      Future.delayed(Duration(seconds: 2), () {
        widget.onChange.call();
      });
    }
    SessionManager sessionManager = SessionManager.getInstance();
    if (widget.seekingData.is_lock) {
      isSeekLock = true;
      if (widget.seekingData.locked_by == sessionManager.getUserID()) {
        isSeekLock = false;
        showReleaseLock = true;
      }
      if (widget.seekingData.user_id == sessionManager.getUserID()) {
        isSeekLock = false;
      }
    } else {
      isSeekLock = false;
      showReleaseLock = false;
    }
    _postThreadList = _getThreadList();
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    Color accentColor = Theme.of(context).accentColor;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: getCommonAppBar(context, _sf),
      body: ModalProgressHUD(
        inAsyncCall: isApiCall,
        child: ListView(
          children: [
            widget.seekingData.media_uploaded == "Q"
                ? _getSeekingView()
                : MediaView(widget.seekingData, widget.onChange),
            isSeekLock
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CommentField(
                      seekId: "${widget.seekingData.id}",
                      threadId: "0",
                      boolCallBack: (apiCall) {
                        setState(() {
                          isApiCall = apiCall;
                        });
                      },
                    ),
                  ),
            FutureBuilder(
              future: _postThreadList,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                ThreadDetails details = snapshot.data;
                if (details == null) {
                  return Container();
                }
                return Column(
                  children: [
                    for (int i = 0; i < lstThreadInfo.length; i++)
                      ThreadView(
                        isSeekLock: isSeekLock,
                        threadInfo: lstThreadInfo[i],
                        seekId: "${widget.seekingData.id}",
                        apiCallBack: (apiCall) {
                          setState(() {
                            isApiCall = apiCall;
                          });
                        },
                      )
                  ],
                );
              },
            ),
            SizedBox(
              height: 8,
            ),
            showReleaseLock
                ? InkWell(
                    onTap: () {
                      _callReleaseLockPopUp();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 10, bottom: 10),
                      child: Text(
                        "Click Here to know more",
                        style: _sf.getSmallStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Future<ThreadDetails> _getThreadList() async {
    HashMap<String, String> params = HashMap();
    params['seek_detail_id'] = "${widget.seekingData.id}";
    params['parent_thread_id'] = "0";
    params['page[number]'] = "1";
    final result = await callPostAPI("thread-list", params);
    final response = json.decode(result.toString());
    if (response['status'] == "success") {
      ThreadDetails details = ThreadDetails.fromJson(response['data']);
      _getAllComments(details);
      lstThreadInfo = details.data;
      return details;
    } else {
      return null;
    }
  }

  void _getAllComments(ThreadDetails details) async {
    try {
      while (details.current_page != details.last_page) {
        if (isDisposed) {
          break;
        }
        details.current_page++;
        HashMap<String, String> params = HashMap();
        params['seek_detail_id'] = "${widget.seekingData.id}";
        params['parent_thread_id'] = "0";
        params['page[number]'] = '${details.current_page}';
        final result = await callPostAPI("thread-list", params);
        final response = json.decode(result.toString());
        if (response['status'] == "success") {
          ThreadDetails details1 = ThreadDetails.fromJson(response['data']);
          if (lstThreadInfo != null) {
            lstThreadInfo.addAll(details1.data);
            setState(() {});
          }
        }
      }
    } on Exception catch (e) {
      // TODO
    }
  }

  bool isDisposed = false;

  @override
  void dispose() {
    super.dispose();
    // widget.onChange.call();
    isDisposed = true;
  }

  Widget _getSeekingView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              widget.seekingData.title,
              style: _sf.getLargeStyle(color: Theme.of(context).accentColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Html(
              data: widget.seekingData.description,
              // style: _sf.getSmallStyle(),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          //   child: Text(
          //     widget.seekingData.description,
          //     style: _sf.getSmallStyle(),
          //   ),
          // ),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  navigateToPageWithoutScaffold(context,
                      ProfilePage(user_id: widget.seekingData.user_id));
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Text(
                    "By: " + widget.seekingData.user_by,
                    style: _sf.getExtraSmallStyle(color: Colors.grey[500]),
                  ),
                ),
              ),
              Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.remove_red_eye,
                      size: _sf.scaleSize(16),
                      color: Colors.grey[500],
                    ),
                    Text("  " + widget.seekingData.total_views),
                    SizedBox(
                      width: 8,
                    ),
                    InkWell(
                      onTap: () async {
                        if (isLikeCall) return;
                        isLikeCall = true;
                        setState(() {
                          widget.seekingData.is_likes =
                              !widget.seekingData.is_likes;
                          int likes = int.parse(widget.seekingData.total_likes);

                          if (widget.seekingData.is_likes) {
                            likes++;
                          } else {
                            likes--;
                          }
                          widget.seekingData.total_likes = "$likes";
                          Future.delayed(Duration(seconds: 2), () {
                            widget.onChange.call();
                          });
                        });
                        await callSeekViewLike(widget.seekingData.id, "like");
                        isLikeCall = false;
                      },
                      child: widget.seekingData.is_likes
                          ? SvgPicture.asset(
                              "assets/images/heart.svg",
                              width: _sf.scaleSize(16),
                              height: _sf.scaleSize(16),
                            )
                          : SvgPicture.asset(
                              "assets/images/heart_outline1.svg",
                              // color: Colors.red,
                              width: _sf.scaleSize(15),
                              height: _sf.scaleSize(15),
                            ),
                    ),
                    Text("  " + widget.seekingData.total_likes),
                    SizedBox(
                      width: 8,
                    ),
                    Icon(
                      Icons.chat_bubble_outline,
                      size: _sf.scaleSize(16),
                      color: Colors.grey[500],
                    ),
                    Text("  " + widget.seekingData.total_comments),
                    FlagIcon(
                      seekId: widget.seekingData.id,
                      sf: _sf,
                      onClick: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: 8,
                    ),
                  ]),
            ],
          ),
          SizedBox(
            height: 4,
          ),
          Container(
            height: 0.5,
            color: Colors.black38,
          ),
        ],
      ),
    );
  }

  void _callReleaseLockPopUp() {
    showYesNoDialog(
      context,
      "You are locked on to this SEEK posting. Only you can reply. Click here to withdraw  yourself and allow some other Expert to start communicating",
      title: 'Release Lock?',
      okText: 'Release Lock',
      okCall: () {
        _callReleaseLock();
      },
      cancelText: 'Cancel',
      cancelCall: () {},
    );
  }

  void _callReleaseLock() async {
    HashMap params = HashMap();
    params['seek_detail_id'] = widget.seekingData.id;
    final res = await callPostAPI("thread-unlock", params);
    final result = json.decode(res.toString());
    if (result['status'] == 'success') {
      widget.seekingData.locked_by = '';
      widget.seekingData.is_lock = false;
      isSeekLock = false;
      showReleaseLock = false;
      setState(() {});
      showSuccessAlertDialog(context, result['message']);
    } else {
      showErrorAlertDialog(context, result['message']);
    }
  }
}
