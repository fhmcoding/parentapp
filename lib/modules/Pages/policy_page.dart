import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({Key key}) : super(key: key);

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:SfPdfViewer.network(
          'https://api.sofia-sahara.com/pdf.pdf',
          enableDoubleTapZooming: false),
    );
  }
}
