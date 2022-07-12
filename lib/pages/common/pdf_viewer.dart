import 'dart:io';

// import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';

class ViewPDFDocument extends StatefulWidget {
  final File file;
  final String url;
  final String title;

  const ViewPDFDocument({Key key, this.title = '', this.url, this.file})
      : super(key: key);

  @override
  _ViewPDFDocumentState createState() => _ViewPDFDocumentState();
}

class _ViewPDFDocumentState extends State<ViewPDFDocument> {
  bool _isLoading = true;
  // PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(child: Container()
              //  PDFViewer(
              //   document: document,
              //   zoomSteps: 1,
              // ),
              ),
    );
  }

  void loadDocument() async {
    // if (widget.url != null) {
    //   document = await PDFDocument.fromURL(widget.url);
    // } else {
    //   document = await PDFDocument.fromFile(widget.file);
    // }
    // setState(() {
    //   _isLoading = false;
    // });
  }
}
