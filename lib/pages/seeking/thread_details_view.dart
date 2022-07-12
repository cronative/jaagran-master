import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/common_functions.dart';
import 'package:jaagran/pages/profile/profile_page.dart';
import 'package:jaagran/pages/seeking/model/thread_details.dart';
import 'package:jaagran/pages/seeking/parts/comment_field.dart';
import 'package:jaagran/pages/seeking/parts/thread_view.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ThreadDetailsView extends StatefulWidget {
  final ThreadInfo threadInfo;
  final String seekId;
  final VoidCallback onChange;
  final bool isSeekLock;

  const ThreadDetailsView(
      {Key key, this.threadInfo, this.seekId, this.onChange, this.isSeekLock})
      : super(key: key);

  @override
  _ThreadDetailsViewState createState() => _ThreadDetailsViewState();
}

class _ThreadDetailsViewState extends State<ThreadDetailsView> {
  SizeConfig _sf;
  Future<ThreadDetails> _postThreadList;
  List<ThreadInfo> lstThreadInfo;
  bool isApiCall = false;
  bool isLikeCall = false;

  @override
  void initState() {
    super.initState();
    if (!widget.threadInfo.is_seen) {
      callThreadViewLike(widget.threadInfo.id, "view");
      widget.threadInfo.is_seen = true;
      int totalViews = int.parse(widget.threadInfo.thread_view);
      totalViews += 1;
      widget.threadInfo.thread_view = "$totalViews";
      Future.delayed(Duration(seconds: 2), () {
        widget.onChange.call();
      });
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  //   child: Text(
                  //     widget.threadInfo.,
                  //     style: _sf.getLargeStyle(color: Theme.of(context).accentColor),
                  //   ),
                  // ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(
                      widget.threadInfo.thread_details,
                      style: _sf.getSmallStyle(),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          navigateToPageWithoutScaffold(
                              context,
                              ProfilePage(
                                  user_id: widget.threadInfo.thread_user_id));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          child: Text(
                            "By: " + widget.threadInfo.user_by,
                            style:
                                _sf.getExtraSmallStyle(color: Colors.grey[500]),
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
                            Text("  " + widget.threadInfo.thread_view),
                            SizedBox(
                              width: 8,
                            ),
                            InkWell(
                              onTap: () async {
                                if (isLikeCall) return;
                                isLikeCall = true;
                                setState(() {
                                  widget.threadInfo.is_likes =
                                      !widget.threadInfo.is_likes;
                                  int likes =
                                      int.parse(widget.threadInfo.thread_like);

                                  if (widget.threadInfo.is_likes) {
                                    likes++;
                                  } else {
                                    likes--;
                                  }
                                  widget.threadInfo.thread_like = "$likes";
                                  Future.delayed(Duration(seconds: 2), () {
                                    widget.onChange.call();
                                  });
                                });
                                await callThreadViewLike(
                                    widget.threadInfo.id, "like");
                                isLikeCall = false;
                              },
                              child: widget.threadInfo.is_likes
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
                            Text("  " + widget.threadInfo.thread_like),
                            SizedBox(
                              width: 8,
                            ),
                            Icon(
                              Icons.chat_bubble_outline,
                              size: _sf.scaleSize(16),
                              color: Colors.grey[500],
                            ),
                            Text("  " + widget.threadInfo.thread_comments),
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
            ),
            widget.isSeekLock
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CommentField(
                      seekId: widget.seekId,
                      threadId: '${widget.threadInfo.id}',
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
                        isSeekLock: widget.isSeekLock,
                        threadInfo: lstThreadInfo[i],
                        seekId: widget.seekId,
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
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<ThreadDetails> _getThreadList() async {
    HashMap<String, String> params = HashMap();
    params['seek_detail_id'] = widget.seekId;
    params['parent_thread_id'] = "${widget.threadInfo.id}";
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
        params['seek_detail_id'] = widget.seekId;
        params['parent_thread_id'] = "${widget.threadInfo.id}";
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
    isDisposed = true;
  }
}
