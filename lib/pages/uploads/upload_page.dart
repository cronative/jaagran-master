import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:jaagran/commons/common_dialogs.dart';
import 'package:jaagran/commons/common_theme_functions.dart';
import 'package:jaagran/commons/session_manager.dart';
import 'package:jaagran/commons/strings.dart';
import 'package:jaagran/pages/common/appbar/common_appbar.dart';
import 'package:jaagran/pages/common/custom/cuatom_audio_player.dart';
import 'package:jaagran/pages/common/custom/custom_video_player.dart';
import 'package:jaagran/pages/common/pdf_viewer.dart';
import 'package:jaagran/utils/size_config.dart';
import 'package:jaagran/utils/utils.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:video_player/video_player.dart';
import 'dart:io' show Platform;

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  SizeConfig _sf;
  String _selectedFileType = "V";
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _authorController = TextEditingController();
  TextEditingController _tagController = TextEditingController();
  TextEditingController _tagCharges = TextEditingController();
  bool isApiCall = false;

  @override
  Widget build(BuildContext context) {
    _sf = SizeConfig.getInstance(context);
    Color accentColor = Theme.of(context).accentColor;
    return Scaffold(
      appBar: getCommonAppBar(context, _sf),
      bottomNavigationBar: Container(
        height: 60,
        alignment: AlignmentDirectional.center,
        color: Theme.of(context).buttonColor,
        child: getNavButton(
          "Post",
          _sf.getCaviarDreams(),
          () {
            if (isApiCall) return;
            _callApi();
          },
          padding: EdgeInsets.symmetric(
            vertical: _sf.scaleSize(8),
            horizontal: _sf.scaleSize(20),
          ),
        ),
        // child: Text(
        //   "Post",
        //   style: _sf.getLargeStyle(color: accentColor),
        // ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: isApiCall,
        child: ListView(
          children: [
            Container(
              alignment: AlignmentDirectional.center,
              color: Colors.white,
              padding: EdgeInsets.only(
                  bottom: _sf.scaleSize(12), top: _sf.scaleSize(12)),
              child: Text(
                "Library Uploads",
                style: _sf.getLargeStyle(color: accentColor),
              ),
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Uploading : ",
                  style: _sf.getMediumStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).accentColor),
                ),
                SizedBox(
                  width: 4,
                ),
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Radio<String>(
                    value: "V",
                    groupValue: _selectedFileType,
                    onChanged: _changeVal,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                InkWell(
                  onTap: () {
                    _changeVal("V");
                  },
                  child: Text(
                    "Video",
                    style: _sf.getMediumStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).accentColor),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Radio<String>(
                      value: "A",
                      groupValue: _selectedFileType,
                      onChanged: _changeVal),
                ),
                SizedBox(
                  width: 2,
                ),
                InkWell(
                  onTap: () {
                    _changeVal("A");
                  },
                  child: Text(
                    "Audio",
                    style: _sf.getMediumStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).accentColor),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Radio<String>(
                      value: "B",
                      groupValue: _selectedFileType,
                      onChanged: _changeVal),
                ),
                SizedBox(
                  width: 2,
                ),
                InkWell(
                  onTap: () {
                    _changeVal("B");
                  },
                  child: Text(
                    "eBook",
                    style: _sf.getMediumStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).accentColor),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
              child: TextField(
                controller: _titleController,
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                style: _sf.getMediumStyle(),
                maxLengthEnforced: true,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(50),
                ],
                decoration: InputDecoration(
                  hintText: 'Title*',
                  hintStyle:
                      _sf.getSmallStyle(color: Theme.of(context).accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).hintColor,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
              child: TextField(
                controller: _descController,
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                style: _sf.getMediumStyle(),
                maxLengthEnforced: true,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(1000),
                ],
                minLines: 4,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Description*',
                  hintStyle:
                      _sf.getSmallStyle(color: Theme.of(context).accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).hintColor,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
              child: TextField(
                controller: _authorController,
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                style: _sf.getMediumStyle(),
                maxLengthEnforced: true,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(100),
                ],
                decoration: InputDecoration(
                  hintText: 'Author*',
                  hintStyle:
                      _sf.getSmallStyle(color: Theme.of(context).accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).hintColor,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 32, right: 32),
              child: TextField(
                controller: _tagController,
                textAlign: TextAlign.start,
                keyboardType: TextInputType.text,
                style: _sf.getMediumStyle(),
                maxLengthEnforced: true,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(100),
                ],
                decoration: InputDecoration(
                  hintText: 'Tags*',
                  hintStyle:
                      _sf.getSmallStyle(color: Theme.of(context).accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).hintColor,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 36, right: 32, top: 4, bottom: 8),
              child: Text(
                "e.g #tag1 #tag2 #tag3 ......",
                style: _sf.getSmallStyle(color: Colors.black38),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 8, left: 32, right: 32, bottom: 16),
              child: TextField(
                controller: _tagCharges,
                textAlign: TextAlign.start,
                keyboardType: TextInputType.number,
                style: _sf.getMediumStyle(),
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(7),
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                decoration: InputDecoration(
                  hintText: 'Charges',
                  hintStyle:
                      _sf.getSmallStyle(color: Theme.of(context).accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).hintColor,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 36, right: 32, bottom: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: _pickFile,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(
                            color: Colors.black26, // set border color
                            width: 1.0), // set border width
                        borderRadius: BorderRadius.all(
                            Radius.circular(2.0)), // set rounded corner radius
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Browse file",
                          style: _sf.getSmallStyle(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _getFileName(),
                        maxLines: 2,
                        style: _sf.getExtraSmallStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _selectedFile != null
                ? Container()
                : Padding(
                    padding:
                        const EdgeInsets.only(left: 36, right: 32, bottom: 16),
                    child: Text(
                      _getValidationText(),
                      style: _sf.getExtraSmallStyle(color: Colors.red),
                    )),
            _previewWidget(),
          ],
        ),
      ),
    );
  }

  void _changeVal(String val) {
    if (_selectedFileType != val) {
      setState(() {
        _selectedFile = null;
        _selectedFileType = val;
      });
    }
  }

  File _selectedFile;

  void _pickFile() async {
    String _lastSelectedFilePath;

    FileType type = _selectedFileType == "V"
        ? FileType.video
        : _selectedFileType == "A"
            ? FileType.audio
            : FileType.custom;
    // setState(() {
    if (_selectedFile != null) {
      _lastSelectedFilePath = _selectedFile.path;
      _selectedFile = null;
    }
    // });
    FilePickerResult selectedFile;
    if (Platform.isAndroid) {
      selectedFile = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: _selectedFileType == "B" ? ["pdf"] : null,
      );
    } else {
      if (_selectedFileType == 'A') {
        selectedFile = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions:  ["mp3"] ,
        );
      } else {
        selectedFile = await FilePicker.platform.pickFiles(
          type: type,
          allowedExtensions: _selectedFileType == "B" ? ["pdf"] : null,
        );
      }
    }

    if (selectedFile != null) {
      _selectedFile = File(selectedFile.files.single.path);
    }
    // getFile(
    //   type: type,
    //   allowedExtensions: _selectedFileType == "B" ? ["pdf"] : null,
    // );

    setState(() {
      if (_selectedFile == null && _lastSelectedFilePath != null) {
        _selectedFile = File(_lastSelectedFilePath);
      }
    });
  }

  String _getFileName() {
    if (_selectedFile == null) return "No file selected.";
    List<String> file = _selectedFile.path.split("/");
    return file[file.length - 1];
  }

  Widget _previewWidget() {
    if (_selectedFile == null) return Container();
    if (_selectedFileType == "V")
      return _loadVideo();
    else if (_selectedFileType == "A")
      return _loadAudio();
    else
      return _loadPDF();
  }

  Widget _loadVideo() {
    return Container(
      // height: 700,
      // width: 400,
      child: CustomVideoPlayer(
        videoPlayerController: VideoPlayerController.file(_selectedFile),
      ),
    );
  }

  Widget _loadAudio() {
    // return PlayerWidget(
    //   url: _selectedFile.path,
    // );
    printToConsole("load audio call");
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomAudioPlayer(
        filePath: _selectedFile.path,
        isLocal: true,
      ),
    );
  }

  Widget _loadPDF() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: RaisedButton(
        onPressed: () {
          navigateToPageWithoutScaffold(
              context,
              ViewPDFDocument(
                file: _selectedFile,
              ));
        },
        child: Text(
          "View PDF",
          style: _sf.getSmallStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _callApi() async {
    // HashMap<String, String> params = HashMap();
    String title = _titleController.text.toString().trim();
    String description = _descController.text.toString().trim();
    String author = _descController.text.toString().trim();
    String tags = _tagController.text.toString().trim();
    String charges = _tagCharges.text.toString().trim();

    if (title.isEmpty) {
      showWarningDialog(context, "Please Enter Title");
      return;
    }
    if (description.isEmpty) {
      showWarningDialog(context, "Please Enter Description");
      return;
    }
    if (author.isEmpty) {
      showWarningDialog(context, "Please Enter Author");
      return;
    }
    if (tags.isEmpty) {
      showWarningDialog(context, "Please Add Some Tags");
      return;
    }
    if (_selectedFile == null) {
      showWarningDialog(context, "Please select media file");
    }
    setState(() {
      isApiCall = true;
    });

    try {
      var postUri = Uri.parse(API_URL + "create-media");
      var request = new http.MultipartRequest("POST", postUri);

      // var request = new http.MultipartRequest("POST", "url");

      request.fields["type"] = _selectedFileType;
      request.fields["title"] = title;
      request.fields["description"] = description;
      request.fields["author"] = author;
      request.fields["tags"] = _getCommaSeparatedTags(tags);
      request.fields["cost"] = charges;

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _selectedFile.path,
        contentType: MediaType(_getMediaType(), _getType(_selectedFile.path)),
      ));
      Map<String, String> map = HashMap();
      SessionManager manager = SessionManager.getInstance();

      map["Authorization"] = manager.getAuthToken();
      map["Accept"] = "application/json";
      request.headers.addAll(map);

      request.send().then((response) async {
        String res = await response.stream.bytesToString();
        printToConsole("responce : ${res}");
        final result = json.decode(res);
        if (result['status'] == 'success') {
          showSuccessAlertDialog(context, result['message'],
              isCancelable: false, callback: () {
            Navigator.of(context).pop();
            // _titleController.text = "";
            // _descController.text = "";
            // _descController.text = "";
            // _tagController.text = "";
            // _tagCharges.text = "";
            // _selectedFile = null;
          });
        } else {
          showErrorAlertDialog(
            context,
            result['message'],
            isCancelable: false,
          );
        }
        setState(() {
          isApiCall = false;
        });
      });
    } on Exception catch (e) {
      showErrorAlertDialog(
        context,
        "Something went wrong, please try again.",
        isCancelable: false,
      );
      setState(() {
        isApiCall = false;
      });
    }
  }

  String _getValidationText() {
    if (_selectedFileType == "V") {
      return "Upload Video * (Size-50 Mb, Quality-720p, Format-mp4,3gp)";
    } else if (_selectedFileType == "A") {
      return "Upload Audio * (Size-50 Mb, Format-mp3)";
    } else {
      return "Upload eBook * (Size-50 Mb, Format-pdf)";
    }
  }

  String _getType(String path) {
    List<String> lstStr = path.split(".");
    return lstStr[lstStr.length - 1];
  }

  String _getMediaType() {
    if (_selectedFileType == "V") {
      return "video";
    } else if (_selectedFileType == "A") {
      return "audio";
    } else {
      return "application";
    }
  }

  String _getCommaSeparatedTags(String t) {
    List<String> tags = t.split("#");
    String tag = "";
    tags.forEach((element) {
      String obj = element.replaceAll(",", "").trim();
      if (obj.isNotEmpty) {
        tag += " " + obj + ",";
      }
    });
    tag = tag.trim();
    tag = tag.substring(0, tag.length - 1);
    return tag;
  }
}

// class PlayVideo extends StatefulWidget {
//   final File file;
//
//   PlayVideo({this.file});
//
//   @override
//   PlayVideoState createState() => PlayVideoState();
// }
//
// class PlayVideoState extends State<PlayVideo> {
//   VideoPlayerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.file(widget.file);
//
//     _controller.addListener(() {
//       setState(() {});
//     });
//     _controller.setLooping(true);
//     _controller.initialize().then((_) => setState(() {}));
//     _controller.play();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: <Widget>[
//         Container(
//           padding: const EdgeInsets.all(16),
//           child: AspectRatio(
//             aspectRatio: _controller.value.aspectRatio,
//             child: Stack(
//               alignment: Alignment.bottomCenter,
//               children: <Widget>[
//                 VideoPlayer(_controller),
//                 _PlayPauseOverlay(controller: _controller),
//                 VideoProgressIndicator(_controller, allowScrubbing: true),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _PlayPauseOverlay extends StatelessWidget {
//   const _PlayPauseOverlay({this.controller});
//
//   final VideoPlayerController controller;
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         AnimatedSwitcher(
//           duration: Duration(milliseconds: 50),
//           reverseDuration: Duration(milliseconds: 200),
//           child: controller.value.isPlaying
//               ? SizedBox.shrink()
//               : Container(
//                   color: Colors.black26,
//                   child: Center(
//                     child: Icon(
//                       Icons.play_arrow,
//                       color: Colors.white,
//                       size: 100.0,
//                     ),
//                   ),
//                 ),
//         ),
//         InkWell(
//           onTap: () {
//             controller.value.isPlaying ? controller.pause() : controller.play();
//           },
//         ),
//       ],
//     );
//   }
// }
