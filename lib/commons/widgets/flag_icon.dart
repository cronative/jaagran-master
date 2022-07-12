import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';

class FlagIcon extends StatefulWidget {
  final SizeConfig sf;
  final VoidCallback onClick;
  final String seekId;

  const FlagIcon({
    this.seekId,
    this.sf,
    this.onClick,
  });

  @override
  _FlagIconState createState() => _FlagIconState();
}

class _FlagIconState extends State<FlagIcon> {
  bool isFlagClick = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        setState(() {
          isFlagClick = true;
        });
        await callSeekFlagAPI();
        setState(() {
          isFlagClick = false;
        });
        widget.onClick.call();
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              "assets/images/flag.svg",
              width: widget.sf.scaleSize(16),
              height: widget.sf.scaleSize(16),
              color: isFlagClick ? Colors.red : Colors.grey[600],
            ),
          ),
          isFlagClick
              ? Container(
                  width: widget.sf.scaleSize(16),
                  height: widget.sf.scaleSize(16),
                  child: CircularProgressIndicator(),
                )
              : Container(),
        ],
      ),
    );
  }

  Future<bool> callSeekFlagAPI() async {
    HashMap<String, String> params = HashMap();
    params['seek_detail_id'] = widget.seekId;
    params['type'] = 'flag';
    final result = await callPostAPI("seek-view-like", params);
    return true;
  }
}
