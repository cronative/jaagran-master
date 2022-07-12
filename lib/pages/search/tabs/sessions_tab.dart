// import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:jaagran/commons/common_functions.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/events/event_details.dart';
import 'package:jaagran/pages/liveSessions/agora/call.dart';
import 'package:jaagran/pages/profile/profile_page.dart';
import 'package:jaagran/pages/search/model/search_ls_model.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';

class SessionsTab extends StatefulWidget {
  final Future<SearchLsModel> postData;

  const SessionsTab({Key key, this.postData}) : super(key: key);

  @override
  SessionsTabState createState() => SessionsTabState();
}

class SessionsTabState extends State<SessionsTab>
    with AutomaticKeepAliveClientMixin<SessionsTab> {
  @override
  bool get wantKeepAlive => true;
  SizeConfig _sf;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _sf = SizeConfig.getInstance(context);
    return FutureBuilder(
      future: widget.postData,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 500,
          );
        } else {
          SearchLsModel searchLsModel = snapshot.data;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int index = 0;
                  index < searchLsModel.data.data.length;
                  index++)
                _getChild(searchLsModel.data.data[index]),
            ],
          );
        }
      },
    );
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }

  Widget _getChild(Datum data) {
    return InkWell(
      onTap: () async {
        if (data.eventId == null) {
          String chanelName = 'Swasthyasethu_${data.id}';
          printToConsole("chanelName $chanelName");
          await _handleCameraAndMic(Permission.camera);
          await _handleCameraAndMic(Permission.microphone);
          navigateToPageWithoutScaffold(
            context,
            CallPage(
              channelName: chanelName,
              // role: ClientRole.Broadcaster,
            ),
          );
        } else {
          navigateToPageWithoutScaffold(
              context,
              EventDetails(
                eventId: data.eventId,
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
                data.name,
                style: _sf.getLargeStyle(color: Theme.of(context).accentColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                getShortDesc40Char(data.notes),
                style: _sf.getSmallStyle(),
              ),
            ),
            SizedBox(
              height: 8,
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
}
