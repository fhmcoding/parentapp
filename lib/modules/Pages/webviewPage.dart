import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebviewPage extends StatefulWidget {
 final link;
  const WebviewPage({Key key,this.link}) : super(key: key);

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  bool _isLoading = true;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,color: Colors.black),
          ),
        ),
        body: Stack(
          children: [
            WebView(
              initialUrl: '${widget.link}',
              javascriptMode: JavascriptMode.unrestricted, // Enable JavaScript
              onPageFinished: (_) {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
            Visibility(
              visible: _isLoading,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
    );
  }
}
