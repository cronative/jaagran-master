import 'package:flutter/material.dart';
import 'package:jaagran/utils/size_config.dart';

class HeaderWidget extends StatelessWidget {
  final String title;

  const HeaderWidget({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig _sf = SizeConfig.getInstance(context);
    return Container(
      alignment: AlignmentDirectional.center,
      color: Colors.white,
      padding:
          EdgeInsets.only(bottom: _sf.scaleSize(16), top: _sf.scaleSize(16)),
      child: Text(
        title,
        style: _sf.getLargeStyle(color: Theme.of(context).accentColor),
      ),
    );
  }
}
