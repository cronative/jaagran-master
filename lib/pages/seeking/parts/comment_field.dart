import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/web_utils.dart';

typedef BoolCallBack = void Function(bool isApiCall);

class CommentField extends StatefulWidget {
  final String seekId;
  final String threadId;
  final BoolCallBack boolCallBack;

  const CommentField({
    Key key,
    this.seekId,
    this.threadId,
    this.boolCallBack,
  }) : super(key: key);

  @override
  _CommentFieldState createState() => _CommentFieldState();
}

class _CommentFieldState extends State<CommentField> {
  TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SizeConfig _sf = SizeConfig.getInstance(context);
    return Container(
      padding: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor,
        border: Border.all(color: Colors.white, width: 0.0),
        borderRadius: BorderRadius.all(Radius.circular(8.0)), //
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              textAlign: TextAlign.left,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(1000),
              ],
              style: _sf.getSmallStyle(),
              decoration: InputDecoration(
                hintText: 'Type your advice and join the discussion',
                filled: true,
                fillColor: Theme.of(context).hintColor,
                hintStyle: _sf.getExtraSmallStyle(
                    color: Theme.of(context).accentColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(4),
              ),
              minLines: 1,
              maxLines: 5,
            ),
          ),
          InkWell(
            onTap: () {
              _callCreateThread();
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Icon(
                Icons.send,
                size: _sf.scaleSize(24),
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _callCreateThread() async {
    try {
      String comment = _commentController.text.trim();
      if (comment.isEmpty) return;
      FocusScope.of(context).unfocus();
      widget.boolCallBack.call(true);
      HashMap<String, String> params = HashMap();
      params['seek_detail_id'] = widget.seekId;
      params['parent_thread_id'] = widget.threadId;
      params['thread_details'] = comment;
      final result = await callPostAPI("create-thread", params);
      final response = json.decode(result.toString());
      if (response['status'] == 'success') {
        _commentController.text = "";
        showSuccessAlertDialog(context, response['message']);
      } else {
        showErrorAlertDialog(context, response['message']);
      }
      widget.boolCallBack.call(false);
    } on Exception catch (e) {
      widget.boolCallBack.call(false);
    }
  }
}
