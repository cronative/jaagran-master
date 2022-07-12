import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jaagran/commons/common_functions.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/commons/widgets/flag_icon.dart';
import 'package:jaagran/pages/events/event_details.dart';
import 'package:jaagran/pages/landing/model/seeking_model.dart';
import 'package:jaagran/pages/profile/profile_page.dart';
import 'package:jaagran/pages/seeking/seek_details.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';

import 'landing_controller.dart';

class SeekingTab extends StatefulWidget {
  final String type;
  final Future<SeekingModel> postData;
  final String user_id;
  final String searchText;
  final bool isLibrariesPage;

  SeekingTab({
    Key key,
    this.type,
    this.postData,
    this.user_id = "",
    this.searchText = "",
    this.isLibrariesPage = false,
  }) : super(key: key);

  @override
  SeekingTabState createState() => SeekingTabState();
}

class SeekingTabState extends State<SeekingTab>
    with AutomaticKeepAliveClientMixin<SeekingTab> {
  @override
  bool get wantKeepAlive => true;

  List<SeekingData> lstSeekingData;
  int pageNumber = 1;
  int totalPages = 1;
  SizeConfig _sf;
  ScrollController _scrollController = ScrollController();
  bool isAPICall = false;
  bool getAllDataCalled = false;

  @override
  void initState() {
    super.initState();
    if (widget.user_id.isNotEmpty && widget.searchText.isNotEmpty) {
      _scrollController.addListener(() {
        if (!isAPICall &&
            _scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent &&
            (pageNumber != totalPages)) {
          pageNumber++;
          _callSeekingApi(widget.type);
        }
      });
    }
  }

  _callSeekingApi(String type) async {
    isAPICall = true;
    HashMap params = HashMap();
    var result;
    if (widget.searchText.isNotEmpty) {
      params["search"] = widget.searchText;
      params["list_type"] = type;
      params["page[number]"] = "${pageNumber}";
      result = await callPostAPI("search", params);
    } else if (widget.user_id.isNotEmpty) {
      params["user_id"] = widget.user_id;
      params["list_type"] = type;
      params["page[number]"] = "${pageNumber}";
      result = await callPostAPI("profile-activities", params);
    } else {
      params["type"] = type;
      params["page[number]"] = "${pageNumber}";
      result = await callPostAPI("seeking", params);
    }
    final response = json.decode(result.toString());
    SeekingModel model = SeekingModel.fromJson(response);
    lstSeekingData.addAll(model.data.lstSeekingData);
    setState(() {
      isAPICall = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    printToConsole("Build call type ${widget.type}");
    _sf = SizeConfig.getInstance(context);

    return FutureBuilder(
      future: widget.postData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        SeekingModel model = snapshot.data;
        if (lstSeekingData == null) {
          lstSeekingData = model.data.lstSeekingData;
          totalPages = model.data.last_page;
          if ((widget.user_id.isNotEmpty || widget.searchText.isNotEmpty) &&
              !getAllDataCalled) {
            getAllDataCalled = true;
            _getAllData();
          }
        }
        if (lstSeekingData.isEmpty) {
          lstSeekingData = model.data.lstSeekingData;
          totalPages = model.data.last_page;
          if ((widget.user_id.isNotEmpty || widget.searchText.isNotEmpty) &&
              !getAllDataCalled) {
            getAllDataCalled = true;
            _getAllData();
          }
        }
        // lstSeekingData.addAll(model.data.lstSeekingData);

        return widget.user_id.isNotEmpty || widget.searchText.isNotEmpty
            ? _getList()
            : Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 16),
                child: RefreshIndicator(
                  onRefresh: () async {
                    pageNumber = 1;
                    await _callSeekingApi(widget.type);
                    return;
                  },
                  child: _getList(),
                ),
              );
      },
    );
  }

  _getList() {
    if (widget.isLibrariesPage) {
      lstSeekingData.removeWhere((element) => !(element.media_uploaded == 'A' ||
          element.media_uploaded == 'B' ||
          element.media_uploaded == 'V'));
    }

    if (lstSeekingData == null) {
      return Container(
          height: _sf.scaleSize(300),
          child: Center(
            child: Text("No record found!"),
          ));
    }
    if (lstSeekingData.isEmpty) {
      return Container(
          height: _sf.scaleSize(300),
          child: Center(
            child: Text("No record found!"),
          ));
    }

    if (widget.user_id.isEmpty && widget.searchText.isEmpty) {
      return ListView.builder(
        controller: _scrollController,
        itemCount: lstSeekingData.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (lstSeekingData.length == index) {
            return totalPages != pageNumber && isAPICall
                ? Container(
                    // height: _sf.scaleSize(120),
                    padding: EdgeInsets.only(top: 16, bottom: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Container();
          }
          return _getChild(lstSeekingData[index]);
        },
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < lstSeekingData.length; i++)
            _getChild(lstSeekingData[i])
        ],
      );
    }
  }

  Widget _getContentWidget(String type) {
    switch (type) {
      case "B":
        return Icon(
          Icons.book,
          size: _sf.scaleSize(16),
          color: Theme.of(context).accentColor,
        );
        break;
      case "V":
        return Icon(
          Icons.video_collection_rounded,
          size: _sf.scaleSize(16),
          color: Theme.of(context).accentColor,
        );
        break;
      case "A":
        return Icon(
          Icons.audiotrack,
          size: _sf.scaleSize(16),
          color: Theme.of(context).accentColor,
        );
        break;
      default:
        return Container();
    }
  }

  _getChild(SeekingData data) {
    return InkWell(
      onTap: () {
        if (data.media_uploaded != "E") {
          navigateToPageWithoutScaffold(
              context,
              SeekingDetails(data, () {
                setState(() {});
              }),
              isBottomTop: true);
        } else {
          navigateToPageWithoutScaffold(
              context,
              EventDetails(
                eventId: data.id,
              ),
              isBottomTop: true);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                data.title,
                style: _sf.getLargeStyle(color: Theme.of(context).accentColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Html(
                data: getShortDesc40Char(data.description),
                // style: _sf.getSmallStyle(),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            //   child: Text(
            //     data.description,
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
                    navigateToPageWithoutScaffold(
                        context, ProfilePage(user_id: data.user_id));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: Text(
                      "By: " + data.user_by,
                      style: _sf.getExtraSmallStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _getContentWidget(data.media_uploaded),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(
                        Icons.remove_red_eye,
                        size: _sf.scaleSize(16),
                        color: Colors.grey[600],
                      ),
                      Text("  " + data.total_views),
                      SizedBox(
                        width: 8,
                      ),
                      SvgPicture.asset(
                        "assets/images/heart.svg",
                        width: _sf.scaleSize(16),
                        height: _sf.scaleSize(16),
                      ),
                      Text("  " + data.total_likes),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(
                        Icons.chat_bubble_outline,
                        size: _sf.scaleSize(16),
                        color: Colors.grey[600],
                      ),
                      Text("  " + data.total_comments),
                      FlagIcon(
                        seekId: data.id,
                        sf: _sf,
                        onClick: () {
                          lstSeekingData.remove(data);
                          setState(() {});
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
      ),
    );
  }

  void _getAllData() async {
    while (pageNumber != totalPages) {
      pageNumber++;
      await _callSeekingApi(widget.type);
    }
  }
}
