import 'package:flutter/material.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/commons/widgets/common_circular_image.dart';
import 'package:jaagran/pages/chat/chat_screen.dart';
import 'package:jaagran/pages/chat/models/user_model.dart';
import 'package:jaagran/pages/search/model/search_caht_model.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';

class ChatTab extends StatefulWidget {
  final Future<SearchChatModel> postData;

  const ChatTab({Key key, this.postData}) : super(key: key);

  @override
  ChatTabState createState() => ChatTabState();
}

class ChatTabState extends State<ChatTab>
    with AutomaticKeepAliveClientMixin<ChatTab> {
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
          SearchChatModel searchChatModel = snapshot.data;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int index = 0;
                  index < searchChatModel.data.data.length;
                  index++)
                _getChild(searchChatModel.data.data[index]),
            ],
          );
        }
      },
    );
  }

  Widget _getChild(Datum data) {
    SessionManager sessionManager = SessionManager.getInstance();
    String dpPath = Server_URL + sessionManager.getDpPath();
    String dp = data.dp ?? "";

    return InkWell(
      onTap: () {
        navigateToPageWithoutScaffold(
            context,
            ChatScreen(
              user: ChatUser(
                id: data.id,
                imageUrl: getImageUrl(sessionManager.getDpPath() + data.dp),
                name: data.name,
              ),
            ));
      },
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  CommonCircularAvatar(
                    url: dpPath + dp,
                    size: 24,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    data.name ?? "",
                    style: _sf.getMediumStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ],
              ),
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
