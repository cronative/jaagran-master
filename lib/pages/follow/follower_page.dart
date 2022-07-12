import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_functions.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/profile/profile_page.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:jaagran/utils/web_utils.dart';

import 'model/user_data.dart';

class FollowerPage extends StatefulWidget {
  @override
  _FollowerPageState createState() => _FollowerPageState();
}

class _FollowerPageState extends State<FollowerPage> {
  SizeConfig _sf;
  Future<List<UserData>> _post;

  @override
  void initState() {
    super.initState();
    _post = _getList();
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: getCommonAppBar(context, _sf),
      body: Column(
        children: [
          Container(
            alignment: AlignmentDirectional.center,
            color: Colors.white,
            padding: EdgeInsets.only(
                bottom: _sf.scaleSize(16), top: _sf.scaleSize(16)),
            child: Text(
              "Followers",
              style: _sf.getLargeStyle(color: Theme.of(context).accentColor),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _post,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                List<UserData> lstUserData = snapshot.data;
                return ListView.builder(
                  itemCount: lstUserData.length,
                  itemBuilder: (BuildContext context, int index) {
                    UserData userData = lstUserData[index];
                    return InkWell(
                      onTap: () {
                        navigateToPageWithoutScaffold(
                            context,
                            ProfilePage(
                              user_id: userData.follower_id,
                            ),
                            isBottomTop: true);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          tileColor: Colors.white,
                          leading: CircleAvatar(
                            radius: _sf.scaleSize(20),
                            backgroundImage: AssetImage(
                                "assets/images/dp_circular_avatar.png"),
                            backgroundColor: Colors.transparent,
                            child: CircleAvatar(
                              radius: _sf.scaleSize(20),
                              backgroundImage: NetworkImage(
                                getImagePath(userData.follower_dp),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          title: Text(
                            userData.follower_name,
                            style: _sf.getMediumStyle(),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<UserData>> _getList() async {
    List<UserData> lst;
    final result = await callGetAPI("user-follow/follower", HashMap());
    final response = json.decode(result.toString());
    if (response['status'] == "success") {
      lst = UserData.getList(response['data']);
    } else {
      showErrorAlertDialog(context, response['message']);
    }
    return lst;
  }
}
