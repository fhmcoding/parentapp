import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:parentapp/shared/components/components.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


class ViewImage extends StatefulWidget {
  final image;
  final type;
  const ViewImage({Key key,this.image,this.type}) : super(key: key);

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  bool isSaved = true;
  void _saveImage() async {
    setState(() {
      isSaved = false;
    });
      String path = '${widget.image}';
      GallerySaver.saveImage(path, albumName: 'Flutter').then((bool success) {
        setState(() {
          isSaved = true;
          Fluttertoast.showToast(
              msg: "تم حفظ الصورة",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              webShowClose:false,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
        });
      });
    }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions:[
          widget.type=="image/png"||widget.type=='image/jpeg'? Padding(
            padding:EdgeInsets.only(right: 10,top:isSaved==true?15: 25,bottom: 5),
            child:isSaved==false?SpinKitFadingCircle(
              color: Colors.grey[400],
              size: 33.0,
            ):IconButton(onPressed: _saveImage, icon:Icon(Icons.download,color: Colors.black,)),
          ):height(0)
        ],
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back,color: Colors.black),
        ),
      ),
      body:widget.type=="image/png"||widget.type=='image/jpeg'?Center(child: Image.network('${widget.image}')):SfPdfViewer.network(
          '${widget.image}',
          enableDoubleTapZooming: false)
    );
  }
}
