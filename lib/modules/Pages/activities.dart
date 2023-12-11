import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parentapp/modules/Pages/view_image.dart';
import 'package:parentapp/modules/Pages/webviewPage.dart';
import 'package:parentapp/shared/components/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../Layout/HomeLayout/home.dart';
import '../../localization/demo_localization.dart';
import '../../shared/components/components.dart';
import '../../shared/remote/cachehelper.dart';

class Activites extends StatefulWidget {
  const Activites({Key key}) : super(key: key);

  @override
  State<Activites> createState() => _ActivitesState();
}

class _ActivitesState extends State<Activites> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;


  String access_token = Cachehelper.getData(key: "token");
  String language = Cachehelper.getData(key: "langugeCode");

  var fbm = FirebaseMessaging.instance;

  bool isloading = true;
  List actives = [];

  Future getActives()async{
    setState(() {
      isloading = false;
    });
    final response = await http.get(
        Uri.parse('${url}/guardian/publications?include=groups'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        print(data);
        actives = data['data'];
        setState(() {
          isloading = true;
        });
      }else{
        setState(() {
          var data = json.decode(value.body);
          print(data);
          isloading = true;
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }

  int maxline = 2;

  @override
  void initState() {
    messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    getActives();
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessage.listen((message){
      if (message.notification!=null){
        if (message.data != null){
          if(message.notification.title=='منشور جديد'){
            Fluttertoast.showToast(
                msg: "${message.notification.title}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                webShowClose:false,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
            );
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => HomeScreen(index:0)),
                    (route) => false);
          }
          if(message.notification.title=='خبر جديد'){
            Fluttertoast.showToast(
                msg: "${message.notification.title}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                webShowClose:false,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
            );
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => HomeScreen(index:0)),
                    (route) => false);
          }
          if(message.notification.title=='واجب منزلي جديد'){
            Fluttertoast.showToast(
                msg: "${message.notification.title}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                webShowClose:false,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
            );
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => HomeScreen(index:1)),
                    (route) => false);
          }
          if(message.notification.title=='رسالة جديد'){
            Fluttertoast.showToast(
                msg: "${message.notification.title}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                webShowClose:false,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
            );
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => HomeScreen(index:7)),
                    (route) => false);
          }

          if(message.notification.title=='نشاط جديد'){
            Fluttertoast.showToast(
                msg: "${message.notification.title}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                webShowClose:false,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
            );
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => HomeScreen(index:0)),
                    (route) => false);
          }
          if(message.notification.title=='نتائج جديدة'){
            Fluttertoast.showToast(
                msg: "${message.notification.title}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                webShowClose:false,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
            );
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => HomeScreen(index:5)),
                    (route) => false);
          }
          if(message.notification.title=='غياب جديد'){
            Fluttertoast.showToast(
                msg: "${message.notification.title}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                webShowClose:false,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
            );
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => HomeScreen(index:4)),
                    (route) => false);
          }
          if(message.notification.title=='تأخير جديد'){
            Fluttertoast.showToast(
                msg: "${message.notification.title}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                webShowClose:false,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
            );
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => HomeScreen(index:4)),
                    (route) => false);
          }
        }
      }
    },);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data != null){
        if(message.notification.title=='منشور جديد'){
          Fluttertoast.showToast(
              msg: "${message.notification.title}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              webShowClose:false,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomeScreen(index:0)),
                  (route) => false);
        }
        if(message.notification.title=='خبر جديد'){
          Fluttertoast.showToast(
              msg: "${message.notification.title}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              webShowClose:false,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomeScreen(index:0)),
                  (route) => false);
        }
        if(message.notification.title=='واجب منزلي جديد'){
          Fluttertoast.showToast(
              msg: "${message.notification.title}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              webShowClose:false,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomeScreen(index:1)),
                  (route) => false);
        }
        if(message.notification.title=='رسالة جديد'){
          Fluttertoast.showToast(
              msg: "${message.notification.title}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              webShowClose:false,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomeScreen(index:7)),
                  (route) => false);
        }
        if(message.notification.title=='نشاط جديد'){
          Fluttertoast.showToast(
              msg: "${message.notification.title}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              webShowClose:false,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomeScreen(index:0)),
                  (route) => false);
        }
        if(message.notification.title=='نتائج جديدة'){
          Fluttertoast.showToast(
              msg: "${message.notification.title}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              webShowClose:false,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomeScreen(index:5)),
                  (route) => false);
        }
        if(message.notification.title=='غياب جديد'){
          Fluttertoast.showToast(
              msg: "${message.notification.title}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              webShowClose:false,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomeScreen(index:4)),
                  (route) => false);
        }
        if(message.notification.title=='تأخير جديد'){
          Fluttertoast.showToast(
              msg: "${message.notification.title}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              webShowClose:false,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomeScreen(index:4)),
                  (route) => false);
        }
      }
    });

    fbm.getToken().then((value){
      printFullText(value.toString());
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return isloading? actives.length>0?SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context,index){
           print(actives[index]['groups']);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color:Colors.grey[300],width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[200],
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                child:Padding(
                  padding: const EdgeInsets.all(15.0),
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment:MainAxisAlignment.start,
                                crossAxisAlignment:CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text("${actives[index]['user']['first_name']} ${actives[index]['user']['last_name']}",style: TextStyle(color:Colors.black,fontSize: 14.0,fontWeight: FontWeight.w500)),
                                      width(5),
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text('${actives[index]['user']['role']}',style: TextStyle(
                                              fontSize: 9.5,
                                              color: Colors.white
                                          )),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color:Colors.purple,
                                          // border: Border.all(color: Colors.purple,width: 1.5)
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text('${actives[index]['created_at']}',style: TextStyle(
                                    fontSize: 10.5,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500
                                  ),)
                                ],
                              ),
                              height(3),
                            ],
                          ),
                          language!='ar'?Text("${actives[index]['type']=='activity'?"activité":"annonce"}",style: TextStyle(color: Colors.blue,fontSize: 10.0,fontWeight: FontWeight.bold)):
                          Text("${actives[index]['type']=='activity'?"نشاط":"إعلان"}",style: TextStyle(color: Colors.blue,fontSize: 10.0,fontWeight: FontWeight.bold)),
                        ],
                      ),
                      height(9),
                      Text(language=='ar'?'المجموعات : ':"Les Groupes : "),
                      height(5),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: [
                          Text('${actives[index]['groups'].map((item) => item['name']).join(' , ')}',style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12
                          ),)
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child:SelectableText('${actives[index]['title']}',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child:SelectableText('${actives[index]['description']}',
                          style: TextStyle(
                              height:1.5
                          ),
                        ),
                      ),
                      actives[index]['links']!=null?Column(
                        children:[
                          ...actives[index]['links'].map((e)=>TextButton(
                            child: Text('${e}',style: TextStyle(
                              color: Colors.blue,fontWeight: FontWeight.w500,decoration: TextDecoration.underline
                            ),overflow: TextOverflow.ellipsis),
                            onPressed:(){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>WebviewPage(link:e)));
                            },
                           ),
                          )
                        ],
                      ):height(0),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: <Widget>[
                          ...actives[index]['images'].map((image) => GestureDetector(
                            onTap:()async{
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewImage(image:image['original_url'],type:image['mime_type'],)));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if(image['mime_type']=="image/png"||image['mime_type']=="image/jpeg")
                                    Column(
                                      children:[
                                        Padding(
                                          padding:const EdgeInsets.all(4.0),
                                          child:ClipRRect(
                                            child:Image.network('${image['original_url']}',fit: BoxFit.cover,),
                                            borderRadius:BorderRadius.circular(5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if(image['mime_type']=="application/pdf")
                                     Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children:[
                                        ClipRRect(
                                          child:Image.network('https://img.freepik.com/vecteurs-premium/fichier-au-format-pdf-modele-pour-votre-conception_97886-11001.jpg',fit:BoxFit.cover,height: 200),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ],

                                    ),
                                  if(image['mime_type']=="application\/vnd.openxmlformats-officedocument.wordprocessingml.document")
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children:[
                                        GestureDetector(
                                          onTap:()async{
                                            await launch(image['original_url']);
                                          },
                                          child: ClipRRect(
                                            child:Image.network('https://1000logos.net/wp-content/uploads/2020/08/Microsoft-Word-Logo-2013.png',fit:BoxFit.cover,height: 200),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              width:actives[index]['images'].length==1?double.infinity:175,
                            ),
                          ),
                          ).take(4).toList(),

                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          }, separatorBuilder: (context,index){
            return Divider();
          }, itemCount: actives.length)

        ],
      ),
    ):Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30,right: 30,top: 20),
            child: Text(DemoLocalization.of(context).getTranslatedValue('No_Activities_Available'),style: TextStyle(color:Color(0xFF6b7280),fontSize: 16,fontWeight: FontWeight.w500,),textAlign: TextAlign.center,),
          ),
        ],
      ),
    ):Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(color:Colors.purple)
        ],
      ),
    );
  }
}
