import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jaagran/commons/common_functions.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/commons/widgets/list_divider.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/events/create_event.dart';
import 'package:jaagran/pages/events/event_details.dart';
import 'package:jaagran/pages/events/model/event_model.dart';
import 'package:jaagran/pages/profile/profile_page.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';

class EventList extends StatefulWidget {
  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  bool isApiCall = false;
  int pageNumber = 1;

  SizeConfig _sf;

  List<EventData> lstEventData = List();

  int totalPages = 10;
  ScrollController _scrollController = ScrollController();
  bool isAPICall = false;

  @override
  void initState() {
    super.initState();
    _callSeekingApi();
    _scrollController.addListener(() {
      if (!isAPICall &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          (pageNumber != totalPages)) {
        pageNumber++;
        _callSeekingApi();
      }
    });
  }

  _callSeekingApi() async {
    isApiCall = true;
    HashMap params = HashMap();
    params["type"] = "recent";
    params["list_type"] = "E";
    params["page[number]"] = "${pageNumber}";
    final result = await callPostAPI("seeking", params);
    final response = json.decode(result.toString());
    EventModel model = EventModel.fromJson(response);
    pageNumber = model.data.current_page;
    totalPages = model.data.total;
    lstEventData.addAll(model.data.lstEventData);
    setState(() {
      isApiCall = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: getCommonAppBar(context, SizeConfig.getInstance(context)),
        bottomNavigationBar: Container(
          height: 60,
          alignment: AlignmentDirectional.center,
          color: Theme.of(context).buttonColor,
          child: getNavButton(
            "Create Event",
            _sf.getCaviarDreams(),
            () => navigateToPageWithoutScaffold(context, CreateEvent()),
            padding: EdgeInsets.symmetric(
              vertical: _sf.scaleSize(8),
              horizontal: _sf.scaleSize(20),
            ),
          ),
        ),
        body: isApiCall
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    alignment: AlignmentDirectional.center,
                    color: Colors.white,
                    padding: EdgeInsets.only(
                        bottom: _sf.scaleSize(16), top: _sf.scaleSize(16)),
                    child: Text(
                      "Events",
                      style: _sf.getLargeStyle(
                          color: Theme.of(context).accentColor),
                    ),
                  ),
                  ListDivider(),
                  if (lstEventData.isEmpty)
                    _noEventData()
                  else
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(top: 4.0, bottom: 16),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: lstEventData.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (lstEventData.length == index) {
                              return isAPICall
                                  ? Container(
                                      // height: _sf.scaleSize(120),
                                      padding:
                                          EdgeInsets.only(top: 16, bottom: 32),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    )
                                  : Container();
                            }
                            EventData data = lstEventData[index];
                            return InkWell(
                              onTap: () {
                                navigateToPageWithoutScaffold(
                                    context,
                                    EventDetails(
                                      eventId: data.id,
                                    ),
                                    isBottomTop: true);
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      child: Text(
                                        data.title,
                                        style: _sf.getLargeStyle(
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      child: Text(
                                        getShortDesc40Char(data.description),
                                        style: _sf.getSmallStyle(),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            navigateToPageWithoutScaffold(
                                                context,
                                                ProfilePage(
                                                    user_id: data.user_id));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0, vertical: 8),
                                            child: Text(
                                              "By: " + data.user_by,
                                              style: _sf.getExtraSmallStyle(
                                                  color: Colors.grey[500]),
                                            ),
                                          ),
                                        ),
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
                          },
                        ),
                      ),
                    ),
                ],
              ));
  }

  _noEventData() {
    return Expanded(
      child: Center(
        child: Text(
          "No new Events!",
          style: _sf.getMediumStyle(),
        ),
      ),
    );
  }
}
