import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/commons/widgets/flag_icon.dart';
import 'package:jaagran/pages/common/common_functions.dart';
import 'package:jaagran/pages/common/custom/cuatom_audio_player.dart';
import 'package:jaagran/pages/common/custom/custom_video_player.dart';
import 'package:jaagran/pages/common/pdf_viewer.dart';
import 'package:jaagran/pages/landing/model/seeking_model.dart';
import 'package:jaagran/pages/profile/profile_page.dart';
import 'package:jaagran/pages/wallet/razor_pay_util.dart';
import 'package:jaagran/pages/wallet/wallet_util.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:video_player/video_player.dart';

class MediaView extends StatefulWidget {
  final SeekingData seekingData;
  final VoidCallback onChange;

  MediaView(this.seekingData, this.onChange);

  @override
  _MediaViewState createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  SizeConfig _sf;
  bool isLikeCall = false;
  WalletUtil _walletUtils;

  @override
  void initState() {
    super.initState();
    _walletUtils = WalletUtil();
  }

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  widget.seekingData.title,
                  style:
                      _sf.getLargeStyle(color: Theme.of(context).accentColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  widget.seekingData.description,
                  style: _sf.getSmallStyle(),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  "Author : " + widget.seekingData.media_author,
                  style: _sf.getSmallStyle(),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              //   child: Text(
              //     "Key Words : " + widget.seekingData.emotions,
              //     style: _sf.getSmallStyle(),
              //   ),
              // ),
              // SizedBox(
              //   height: 8,
              // ),
              _getMedia(),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      navigateToPageWithoutScaffold(context,
                          ProfilePage(user_id: widget.seekingData.user_id));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Text(
                        "By: " + widget.seekingData.user_by,
                        style: _sf.getExtraSmallStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: _sf.scaleSize(16),
                          color: Colors.grey[500],
                        ),
                        Text("  " + widget.seekingData.total_views),
                        SizedBox(
                          width: 8,
                        ),
                        InkWell(
                          onTap: () async {
                            if (isLikeCall) return;
                            isLikeCall = true;
                            setState(() {
                              widget.seekingData.is_likes =
                                  !widget.seekingData.is_likes;
                              int likes =
                                  int.parse(widget.seekingData.total_likes);

                              if (widget.seekingData.is_likes) {
                                likes++;
                              } else {
                                likes--;
                              }
                              widget.seekingData.total_likes = "$likes";
                              Future.delayed(Duration(seconds: 2), () {
                                widget.onChange.call();
                              });
                            });
                            await callSeekViewLike(
                                widget.seekingData.id, "like");
                            isLikeCall = false;
                          },
                          child: widget.seekingData.is_likes
                              ? SvgPicture.asset(
                                  "assets/images/heart.svg",
                                  width: _sf.scaleSize(16),
                                  height: _sf.scaleSize(16),
                                )
                              : SvgPicture.asset(
                                  "assets/images/heart_outline1.svg",
                                  // color: Colors.red,
                                  width: _sf.scaleSize(15),
                                  height: _sf.scaleSize(15),
                                ),
                        ),
                        Text("  " + widget.seekingData.total_likes),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(
                          Icons.chat_bubble_outline,
                          size: _sf.scaleSize(16),
                          color: Colors.grey[500],
                        ),
                        Text("  " + widget.seekingData.total_comments),
                        FlagIcon(
                          seekId: widget.seekingData.id,
                          sf: _sf,
                          onClick: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        SizedBox(
                          width: 8,
                        ),
                      ]),
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
      ],
    );
  }

  _getMedia() {
    if (widget.seekingData.media_uploaded == "V") return _loadVideo();
    if (widget.seekingData.media_uploaded == "A") return _loadAudio();
    return _loadBook();
  }

  Widget _loadVideo() {
    return FutureBuilder(
      future: _getVideoUrl(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return _checkIsPaid()
            ? CustomVideoPlayer(
                videoPlayerController:
                    VideoPlayerController.network(snapshot.data),
              )
            : InkWell(
                onTap: () {
                  _showPaymentSheet(() {
                    Navigator.of(context).pop();
                    widget.seekingData.is_paid = true;
                    setState(() {});
                  });
                },
                child: AbsorbPointer(
                  absorbing: true,
                  child: CustomVideoPlayer(
                    videoPlayerController:
                        VideoPlayerController.network(snapshot.data),
                  ),
                ),
              );
      },
    );
  }

  Future<String> _getVideoUrl() async {
    SessionManager sessionManager = SessionManager.getInstance();
    String videoUrl =
        sessionManager.getVideoPath() + widget.seekingData.media_id;
    printToConsole("Video url : $videoUrl");
    return videoUrl;
  }

  Widget _loadAudio() {
    return FutureBuilder(
      future: _getAudioUrl(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        return _checkIsPaid()
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomAudioPlayer(
                  filePath: snapshot.data,
                ),
              )
            : InkWell(
                onTap: () {
                  _showPaymentSheet(() {
                    Navigator.of(context).pop();
                    widget.seekingData.is_paid = true;
                    setState(() {});
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AbsorbPointer(
                    absorbing: true,
                    child: CustomAudioPlayer(
                      filePath: snapshot.data,
                    ),
                  ),
                ),
              );
      },
    );
  }

  _getAudioUrl() async {
    SessionManager sessionManager = SessionManager.getInstance();
    String audioUrl =
        sessionManager.getAudioPath() + widget.seekingData.media_id;
    printToConsole("Audio url : $audioUrl");
    return audioUrl;
  }

  Widget _loadBook() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: RaisedButton(
        onPressed: () async {
          if (_checkIsPaid()) {
            _showEBook();
          } else {
            _showPaymentSheet(() {
              Navigator.of(context).pop();
              widget.seekingData.is_paid = true;
              _showEBook();
            });
          }
        },
        child: Text(
          "View Book",
          style: _sf.getSmallStyle(color: Colors.white),
        ),
      ),
    );
  }

  bool _checkIsPaid() {
    if (widget.seekingData.media_cost != 0) {
      SessionManager sessionManager = SessionManager.getInstance();
      if (sessionManager.getUserID() == widget.seekingData.user_id) {
        return true;
      }
      return widget.seekingData.is_paid;
    } else {
      return true;
    }
  }

  void _showPaymentSheet(VoidCallback onSuccess) {
    // String type = widget.seekingData.media_uploaded == "A"
    //     ? "Audio"
    //     : widget.seekingData.media_uploaded == "V"
    //         ? "Video"
    //         : "eBook";
    printToConsole(
        "widget.seekingData.media_cost ${widget.seekingData.media_cost}");
    if (_walletUtils.balance >= widget.seekingData.media_cost) {
      String type = widget.seekingData.media_uploaded;
      _walletUtils.showPaymentSheet(
        context: context,
        type: type,
        title: widget.seekingData.title,
        amount: widget.seekingData.media_cost.toStringAsFixed(2),
        id: widget.seekingData.id,
        sender_id: widget.seekingData.user_id,
        onSuccess: onSuccess,
      );
    } else {
      showYesNoDialog(
        context,
        "Insufficient Wallet Balance",
        title: "Wallet",
        okText: "Add Money",
        okCall: () {
          _walletUtils.showAddMoneyBottomSheet(
            context: context,
            onSuccess: () {},
          );
        },
      );
    }
  }

  void _showEBook() {
    SessionManager sessionManager = SessionManager.getInstance();
    String bookUrl =
        sessionManager.getEBookPath() + widget.seekingData.media_id;
    navigateToPageWithoutScaffold(
        context,
        ViewPDFDocument(
          title: widget.seekingData.title,
          url: bookUrl,
        ),
        isBottomTop: true);
  }
}
