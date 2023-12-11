import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:parentapp/shared/components/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../localization/demo_localization.dart';
import '../../shared/components/components.dart';
import '../../shared/remote/cachehelper.dart';

class Receive_message extends StatefulWidget {
  const Receive_message({Key key}) : super(key: key);

  @override
  State<Receive_message> createState() => _Receive_messageState();
}

class _Receive_messageState extends State<Receive_message> {
  bool isShow = false;
  String access_token = Cachehelper.getData(key: "token");
  String language = Cachehelper.getData(key: "langugeCode");

  bool isloading = true;
  List messagesReceive = [];
  List modifiedMessagesReceive = [];
  Future getMessages()async{
    setState(() {
      isloading = false;
    });
    final response = await http.get(
        Uri.parse('${url}/guardian/messages?filter[guardian_messages]=send'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        messagesReceive = data['data'];
        for (var item in messagesReceive) {
          Map<String, dynamic> modifiedItem = {...item}; // Copy the original map
          modifiedItem['isShow'] = false; // Add the new key-value pair
          modifiedMessagesReceive.add(modifiedItem);
        }
        print(messagesReceive);
        setState(() {
          isloading = true;
        });
      }else{
        var data = json.decode(value.body);
        setState(() {
          printFullText(data.toString());
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
    return isloading? modifiedMessagesReceive.length>0?SingleChildScrollView(
      physics:BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          height(20),
          ListView.separated(
              shrinkWrap: true,
              physics:NeverScrollableScrollPhysics(),
              itemBuilder: (context,index){
                String inputDate = "${modifiedMessagesReceive[index]['created_at']}";
                DateTime dateTime = DateTime.parse(inputDate);
                String formattedDate = DateFormat('HH:mm / d MMM').format(dateTime);
                print(formattedDate);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child:Card(
                        elevation: 2,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children:[
                                    CircleAvatar(
                                      backgroundImage: NetworkImage("${modifiedMessagesReceive[index]['sendable']['avatar']}"),
                                    ),
                                    width(8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text("${modifiedMessagesReceive[index]['sendable']['first_name']} ${modifiedMessagesReceive[index]['sendable']['last_name']}",style: TextStyle(color:Colors.black,fontSize: 14.0,fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                        height(3),
                                        Text("$formattedDate",style: TextStyle(color: Colors.grey[400],fontSize: 9.0,fontWeight: FontWeight.w500)),

                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('${modifiedMessagesReceive[index]['title']}',style: TextStyle(color:Colors.black)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("${modifiedMessagesReceive[index]['message']}",style: TextStyle(color:Colors.black)),
                                ),
                                modifiedMessagesReceive[index]['replies'].length>0? Align(
                                 alignment: Alignment.topRight,
                                 child: TextButton(onPressed: (){
                                   setState(() {
                                     modifiedMessagesReceive[index]['isShow'] = !modifiedMessagesReceive[index]['isShow'];
                                   });
                                 },child:!modifiedMessagesReceive[index]['isShow']?Text(language=='ar'?'رؤية الجواب':"Voir la réponse"):
                                 Text(language=='ar'?'اخفاء الجواب':"Cache la réponse")),
                               ):height(0),
                                modifiedMessagesReceive[index]['isShow']?
                                ListView.builder(
                                    itemBuilder:(
                                        context,repl){
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children:[
                                              CircleAvatar(
                                                backgroundImage: NetworkImage("${modifiedMessagesReceive[index]['replies'][repl]['sendable']['avatar']}"),
                                              ),
                                              width(8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text("${modifiedMessagesReceive[index]['replies'][repl]['sendable']['first_name']} ${modifiedMessagesReceive[index]['replies'][repl]['sendable']['last_name']}",style: TextStyle(color:Colors.black,fontSize: 14.0,fontWeight: FontWeight.w500)),
                                                      Container(
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(4.0),
                                                          child: Text('${modifiedMessagesReceive[index]['replies'][repl]['sendable']['role']}',style: TextStyle(
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
                                                  height(3),
                                                  Text(DateFormat('HH:mm / d MMM').format(DateTime.parse("${modifiedMessagesReceive[index]['replies'][repl]['created_at']}")),style: TextStyle(color: Colors.grey[400],fontSize: 9.0,fontWeight: FontWeight.w500)),

                                                ],
                                              ),
                                            ],
                                          ),
                                         Padding(
                                           padding: const EdgeInsets.all(8.0),
                                           child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               Text('${modifiedMessagesReceive[index]['replies'][repl]['title']}'),
                                               Text('${modifiedMessagesReceive[index]['replies'][repl]['message']}'),
                                             ],
                                           ),
                                         )
                                        ],
                                      );
                                    },
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount:modifiedMessagesReceive[index]['replies'].length,
                                ):height(0)

                                
                              ]),
                        ),
                      )
                  ),
                );
              },
              separatorBuilder:(context,index){
                return Divider();
              }, itemCount:modifiedMessagesReceive.length)
        ],
      ),
    ):Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30,right: 30,top: 20),
          child: Text(DemoLocalization.of(context).getTranslatedValue('No_Messages'),style: TextStyle(color:Color(0xFF6b7280),fontSize: 16,fontWeight: FontWeight.w500,),textAlign: TextAlign.center,),
        ),
      ],
    ):Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(color:Colors.purple)
      ],
    );
  }
}
