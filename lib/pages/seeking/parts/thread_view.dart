import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaagran/pages/profile/profile_page.dart';
import 'package:jaagran/pages/seeking/model/thread_details.dart';
import 'package:jaagran/pages/seeking/parts/comment_field.dart';
import 'package:jaagran/pages/seeking/thread_details_view.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';

class ThreadView extends StatefulWidget {
  final ThreadInfo threadInfo;
  final String seekId;
  final BoolCallBack apiCallBack;
  final bool isSeekLock;

  const ThreadView(
      {Key key,
      this.threadInfo,
      this.seekId,
      this.apiCallBack,
      this.isSeekLock = false})
      : super(key: key);

  @override
  _ThreadViewState createState() => _ThreadViewState();
}

class _ThreadViewState extends State<ThreadView> {
  SizeConfig _sf;

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    Color accentColor = Theme.of(context).accentColor;

    return InkWell(
      onTap: () {
        navigateToPageWithoutScaffold(
            context,
            ThreadDetailsView(
                isSeekLock: widget.isSeekLock,
                threadInfo: widget.threadInfo,
                seekId: widget.seekId,
                onChange: () {
                  setState(() {});
                }),
            isBottomTop: true);
      },
      child: Column(
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
                          // InkWell(
                          //   onTap: () {},
                          // child: widget.threadInfo.is_likes
                          //     ?
                          SvgPicture.asset(
                            "assets/images/heart.svg",
                            width: _sf.scaleSize(16),
                            height: _sf.scaleSize(16),
                          ),
                          // : SvgPicture.asset(
                          //     "assets/images/heart_outline1.svg",
                          //     // color: Colors.red,
                          //     width: _sf.scaleSize(16),
                          //     height: _sf.scaleSize(16),
                          //   ),
                          // ),
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
         widget.isSeekLock?Container(): Padding(
            padding: const EdgeInsets.all(8.0),
            child: CommentField(
              seekId: widget.seekId,
              threadId: '${widget.threadInfo.id}',
              boolCallBack: widget.apiCallBack,
            ),
          ),
        ],
      ),
    );
  }
}
