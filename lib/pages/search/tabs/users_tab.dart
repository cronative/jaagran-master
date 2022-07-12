import 'package:flutter/material.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/commons/widgets/common_circular_image.dart';
import 'package:jaagran/pages/profile/profile_page.dart';
import 'package:jaagran/pages/search/model/search_user_model.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';

class UsersTab extends StatefulWidget {
  final Future<SearchUserModel> postData;

  const UsersTab({Key key, this.postData}) : super(key: key);

  @override
  UsersTabState createState() => UsersTabState();
}

class UsersTabState extends State<UsersTab>
    with AutomaticKeepAliveClientMixin<UsersTab> {
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
          SearchUserModel searchUserModel = snapshot.data;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int index = 0;
                  index < searchUserModel.data.data.length;
                  index++)
                _getChild(searchUserModel.data.data[index]),
            ],
          );
        }
      },
    );
  }

  Widget _getChild(Datum data) {
    SessionManager sessionManager = SessionManager.getInstance();
    String dpPath = Server_URL + sessionManager.getDpPath();
    return InkWell(
      onTap: () {
        navigateToPageWithoutScaffold(
          context,
          ProfilePage(
            user_id: data.id,
            isSelf: false,
          ),
        );
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
                    url: dpPath + data.dp ?? "",
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
