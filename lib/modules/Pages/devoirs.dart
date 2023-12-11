import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:parentapp/modules/Pages/view_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../localization/demo_localization.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Devoirs extends StatefulWidget {
  const Devoirs({Key key}) : super(key: key);

  @override
  State<Devoirs> createState() => _DevoirsState();
}

class _DevoirsState extends State<Devoirs> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String access_token = Cachehelper.getData(key: "token");
  String language = Cachehelper.getData(key: "langugeCode");
  var fbm = FirebaseMessaging.instance;

  bool isloading = true;
  List devoirs = [];

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
        print('announcement');

        devoirs = data['data'].where((e)=>e['type']=='devoir').toList();
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


  @override
  void initState() {
    getActives();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isloading? devoirs.length>0?SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context,index){

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
                                          Text("${devoirs[index]['user']['first_name']} ${devoirs[index]['user']['last_name']}",style: TextStyle(color:Colors.black,fontSize: 14.0,fontWeight: FontWeight.w500)),
                                          width(5),
                                          Container(
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Text('${devoirs[index]['user']['role']}',style: TextStyle(
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
                                      Text('${devoirs[index]['created_at']}',style: TextStyle(
                                          fontSize: 10.5,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500
                                      ),)
                                    ],
                                  ),
                                  height(3),
                                ],
                              ),
                            ],
                          ),
                          height(9),
                          Text(language=='ar'?'المجموعات : ':"Les Groupes : "),
                          height(5),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            children: [
                              Text('${devoirs[index]['groups'].map((item) => item['name']).join(' , ')}',style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12
                              ),)
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child:SelectableText('${devoirs[index]['title']}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child:SelectableText('${devoirs[index]['description']}',
                              style: TextStyle(
                                  height:1.5
                              ),
                            ),
                          ),


                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: <Widget>[
                              ...devoirs[index]['images'].map((image) => GestureDetector(
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
                                                print(image['original_url']);
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
                                  width:devoirs[index]['images'].length==1?double.infinity:175,
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
          }, itemCount: devoirs.length)

        ],
      ),
    ):Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30,right: 30,top: 20),
            child: Text(DemoLocalization.of(context).getTranslatedValue('No_Devoirs_Available'),style: TextStyle(color:Color(0xFF6b7280),fontSize: 16,fontWeight: FontWeight.w500,),textAlign: TextAlign.center,),
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
