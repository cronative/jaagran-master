import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_functions.dart';
import 'package:jaagran/commons/widgets/list_divider.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/appbar/header_widget.dart';
import 'package:jaagran/pages/landing/landing_controller.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'block_list_model.dart';

class BlockListPage extends StatefulWidget {
  @override
  _BlockListPageState createState() => _BlockListPageState();
}

class _BlockListPageState extends State<BlockListPage> {
  SizeConfig _sf;
  Future<List<BlockListModel>> _post;
  bool _isApiCall = false;
  LandingController _landingController = Get.put(LandingController());

  @override
  void initState() {
    super.initState();
    _post = _callGetBlockList();
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getCommonAppBar(context, _sf),
      body: ModalProgressHUD(
        inAsyncCall: _isApiCall,
        child: ListView(
          children: [
            HeaderWidget(
              title: "Block List",
            ),
            ListDivider(),
            FutureBuilder(
              future: _post,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    height: _sf.getScreenHeight() - 50,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                List<BlockListModel> lstBlockList = snapshot.data;
                if (lstBlockList.isEmpty) {
                  return Container(
                    height: _sf.getScreenHeight() - 200,
                    child: Center(
                      child: Text(
                        "You have no users in block list",
                        style: _sf.getMediumStyle(),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: lstBlockList.length,
                  itemBuilder: (BuildContext context, int index) {
                    BlockListModel userData = lstBlockList[index];
                    return Padding(
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
                              getImagePath(userData.block_dp),
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        title: Text(
                          userData.block_name,
                          style: _sf.getMediumStyle(),
                        ),
                        trailing: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onPressed: () {
                            _callUnBlockAPI(userData.block_user_id);
                          },
                          child: Text(
                            "Unblock",
                            style: _sf.getSmallStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<BlockListModel>> _callGetBlockList() async {
    final result = await callGetAPI("block-user-list", HashMap());
    final response = json.decode(result.toString());
    if (response['status'] == 'success') {
      return BlockListModel.getList(response['data']);
    } else {
      return [];
    }
  }

  void _callUnBlockAPI(String userId) async {
    setState(() {
      _isApiCall = true;
    });
    HashMap params = HashMap();
    params['user_id'] = userId;
    final result = await callPostAPI("block-user-create", params);
    final response = json.decode(result.toString());
    setState(() {
      _isApiCall = false;
    });
    _post = _callGetBlockList();

    if (response['status'] == 'success') {
      _landingController.onBlockUserChange.call();
      showSuccessAlertDialog(
        context,
        response['message'],
      );
    } else {
      showErrorAlertDialog(context, response['message']);
    }
  }
}
