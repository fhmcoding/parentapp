import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../../localization/demo_localization.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';

class Reception extends StatefulWidget {
  const Reception({Key key}) : super(key: key);

  @override
  State<Reception> createState() => _ReceptionState();
}

class _ReceptionState extends State<Reception> {
  String access_token = Cachehelper.getData(key: "token");
  String language = Cachehelper.getData(key: "langugeCode");

  TextEditingController Titrecontroller = TextEditingController();
  TextEditingController Messagecontroller = TextEditingController();
  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();


  bool isloading = true;
  List messages = [];
  Future getMessages()async{
    setState(() {
      isloading = false;
    });
    final response = await http.get(
        Uri.parse('${url}/guardian/messages?filter[guardian_messages]=receive'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        messages = data['data'];
        printFullText(data.toString());
        setState(() {
          isloading = true;
        });
      }else{
        setState(() {
          print('error');
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
    getMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(messages.length>0);
    return isloading?messages.length>0?SingleChildScrollView(
      physics:BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          height(20),
          ListView.separated(
              shrinkWrap: true,
              physics:NeverScrollableScrollPhysics(),
              itemBuilder: (context,index){
                String inputDate = "${messages[index]['created_at']}";
                DateTime dateTime = DateTime.parse(inputDate);
                String formattedDate = DateFormat('HH:mm / d MMM').format(dateTime);
                print(messages[index]);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
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
                                            Text("${messages[index]['sendable']['first_name']} ${messages[index]['sendable']['last_name']}",style: TextStyle(color:Colors.black,fontSize: 14.0,fontWeight: FontWeight.w500)),
                                            width(5),
                                            Container(
                                              child: Padding(
                                                padding: const EdgeInsets.all(4.0),
                                                child: Text('${messages[index]['sendable']['role']}',style: TextStyle(
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
                                        Text('${formattedDate}',style: TextStyle(
                                            fontSize: 10.5,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500
                                        ),)
                                      ],
                                    ),
                                    height(3),
                                  ],
                                ),
                                TextButton(onPressed: (){
                                   showModalBottomSheet(
                                       isScrollControlled: true,
                                       context: context, builder: (context){
                                     return Container(
                                       color: Colors.white,
                                       child: Padding(
                                         padding: const EdgeInsets.all(8.0),
                                         child: Form(
                                           key: fromkey,
                                           child: Column(
                                             mainAxisSize: MainAxisSize.max,
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               height(50),
                                               Text(DemoLocalization.of(context).getTranslatedValue('Title'),style: TextStyle(
                                                 fontSize: 16,
                                                 fontWeight:FontWeight.w500,
                                               ),),
                                               height(15),
                                               DefaultTextfiled(
                                                   maxLines: 1,
                                                   label: DemoLocalization.of(context).getTranslatedValue('Type_Your_Title_Here'),
                                                   controller: Titrecontroller,
                                                   hintText:DemoLocalization.of(context).getTranslatedValue('Type_Your_Title_Here'),
                                                   keyboardType: TextInputType.text,
                                                   obscureText: false
                                               ),
                                               height(20),
                                               Text(DemoLocalization.of(context).getTranslatedValue('Message'),style: TextStyle(
                                                 fontSize: 16,
                                                 fontWeight:FontWeight.w500,
                                               ),),
                                               height(15),
                                               DefaultTextfiled(
                                                   maxLines: 5,
                                                   label: DemoLocalization.of(context).getTranslatedValue('Type_Your_Message_Here'),
                                                   controller: Messagecontroller,
                                                   hintText:DemoLocalization.of(context).getTranslatedValue('Type_Your_Message_Here'),
                                                   keyboardType: TextInputType.text,
                                                   obscureText: false
                                               ),
                                               height(20),
                                               StatefulBuilder(
                                                 builder: (context,SetState){
                                                   return GestureDetector(
                                                     onTap: ()async{
                                                          if (fromkey.currentState.validate()) {
                                                              fromkey.currentState.save();
                                                       var data = {
                                                         "message": "${Messagecontroller.text}",
                                                         "title":"${Titrecontroller.text}",
                                                         "message_id":messages[index]['id']
                                                       };
                                                       SetState(() {
                                                         isloading = false;
                                                       });
                                                       print(data);
                                                       final response = await http.post(
                                                           Uri.parse('${url}/guardian/messages'),
                                                           body:jsonEncode(data),
                                                           headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
                                                       ).then((value){
                                                         if(value.statusCode==200){
                                                           var data = json.decode(value.body);
                                                           printFullText(data.toString());
                                                           Fluttertoast.showToast(
                                                               msg:DemoLocalization.of(context).getTranslatedValue('Message_Successfully_Sent'),
                                                               toastLength: Toast.LENGTH_SHORT,
                                                               gravity: ToastGravity.BOTTOM,
                                                               webShowClose:false,
                                                               backgroundColor: Colors.green,
                                                               textColor: Colors.white,
                                                               fontSize: 16.0
                                                           );
                                                           Messagecontroller.clear();
                                                           Titrecontroller.clear();
                                                           Navigator.pop(context);
                                                           SetState(() {
                                                             isloading = true;
                                                           });
                                                         }else{
                                                           SetState(() {
                                                             Messagecontroller.clear();
                                                             Titrecontroller.clear();
                                                             Fluttertoast.showToast(
                                                                 msg: 'error',
                                                                 toastLength: Toast.LENGTH_SHORT,
                                                                 gravity: ToastGravity.BOTTOM,
                                                                 webShowClose:false,
                                                                 backgroundColor: Colors.green,
                                                                 textColor: Colors.white,
                                                                 fontSize: 16.0
                                                             );
                                                             Navigator.pop(context);
                                                             isloading = true;
                                                           });
                                                         }

                                                       }).onError((error,stackTrace){
                                                         SetState(() {
                                                           isloading = true;
                                                           Navigator.pop(context);
                                                           Messagecontroller.clear();
                                                           Titrecontroller.clear();
                                                           Fluttertoast.showToast(
                                                               msg: 'error',
                                                               toastLength: Toast.LENGTH_SHORT,
                                                               gravity: ToastGravity.BOTTOM,
                                                               webShowClose:false,
                                                               backgroundColor: Colors.green,
                                                               textColor: Colors.white,
                                                               fontSize: 16.0
                                                           );
                                                         });
                                                         print(error);
                                                       });
                                                       }
                                                     },
                                                     child: Container(
                                                       height: 60,
                                                       width: double.infinity,
                                                       decoration: BoxDecoration(
                                                         color:Colors.purple,
                                                         borderRadius:BorderRadius.circular(5),
                                                       ),
                                                       child:Center(child: isloading?Text(DemoLocalization.of(context).getTranslatedValue('Send'),style: TextStyle(
                                                           color: Colors.white,
                                                           fontWeight: FontWeight.bold,
                                                           fontSize: 17
                                                       ),):CircularProgressIndicator(color: Colors.white,)),
                                                     ),
                                                   );
                                                 },
                                               ),
                                             ],
                                           ),
                                         ),
                                       ),
                                     );
                                   });
                                 },child:Text(language!='ar'?'Répondre':"رد",style: TextStyle(color: Colors.lightBlue,
                                     fontWeight: FontWeight.bold,fontSize: 14),))
                              ],
                            ),

                            messages[index]['title']!=''? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${messages[index]['title']}',style: TextStyle(color:Colors.black)),
                            ):height(0),

                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${messages[index]['message']}",style: TextStyle(color:Colors.black)),
                            ),

                          ]),
                    ),
                  ),
                );
              },
              separatorBuilder:(context,index){
                return Divider();
              }, itemCount:messages.length)
        ],
      ),
    ):Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30,right: 30,top: 20),
          child: Text(DemoLocalization.of(context).getTranslatedValue('No_Inbox_Messages'),style: TextStyle(color:Color(0xFF6b7280),fontSize: 16,fontWeight: FontWeight.w500,),textAlign: TextAlign.center,),
        ),
      ],
    ):Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Colors.purple)
      ],
    );
  }
}
