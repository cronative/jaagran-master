import 'package:flutter/material.dart';
import 'package:jaagran/commons/widgets/list_divider.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/appbar/header_widget.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';

import 'block_list_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SizeConfig _sf;

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getCommonAppBar(context, _sf),
      body: ListView(
        children: [
          HeaderWidget(
            title: "Settings",
          ),
          ListDivider(),
          InkWell(
            onTap: () {
              navigateToPageWithoutScaffold(context, BlockListPage());
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Block List',
                style: _sf.getMediumStyle(),
              ),
            ),
          ),
          ListDivider(),
        ],
      ),
    );
  }
}


