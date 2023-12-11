import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../../localization/demo_localization.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';

class Message_envoie extends StatefulWidget {
  const Message_envoie({Key key}) : super(key: key);

  @override
  State<Message_envoie> createState() => _Message_envoieState();
}

class _Message_envoieState extends State<Message_envoie> {
  String language = Cachehelper.getData(key: "langugeCode");

  TextEditingController Messagecontroller = TextEditingController();
  TextEditingController Titrecontroller = TextEditingController();
  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
  String access_token = Cachehelper.getData(key: "token");
  List _groups = [];
  bool isloadingdata = true;
  bool isloading = true;


  Future getUsers()async {
    setState(() {
      isloadingdata = false;
    });
    final response = await http.get(
        Uri.parse('${url}/guardian/users'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        printFullText(data.toString());
        _groups = data['data'];
        setState(() {
          isloadingdata = true;
        });
      }else{
        setState(() {
          var data = json.decode(value.body);
          isloadingdata = true;
          print(data);
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }
  String selectedOption;

  List _selectedItems = [];
  List _selectedNames = [];

  void _toggleItembyName(item) {
    print('---------------->');
    print(item);
    print('---------------->');
    setState(() {
      if (_selectedNames.contains(item['full_name'])){
        _selectedNames.remove(item['full_name']);
      } else {
        _selectedNames.add(item['full_name']);
      }
    });
  }

  void _toggleItem(item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  Future<void> _showAlertDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, stateState){
              return AlertDialog(
                title: Text(DemoLocalization.of(context).getTranslatedValue('To')),
                content: SingleChildScrollView(
                  child:isloadingdata?Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _groups.map((item) {
                      return item['role']!='autre'?Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.purple,
                              width: 0.3
                            )
                          ),
                        ),
                        child: CheckboxListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(item['full_name']),
                              item['role']!=null?Text('${item['role']}',style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13
                              ),):height(0),
                              item['subjects'].length>0?Text('(${item['subjects'].map((e) => e['name']).join(' , ')})',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500,color: Colors.black)):height(0),
                              Text('${item['groups'].map((e) => e['name']).join(' , ')}',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500,color: Colors.blueGrey)),
                            ],
                          ),
                          value:_selectedItems.contains(item['id']),
                          onChanged: (bool value) {
                            stateState(() {
                              _toggleItembyName(item);
                              _toggleItem(item['id']);
                            });
                          },
                        ),
                      ):height(0);
                    }).toList(),
                  ):Padding(
                    padding: const EdgeInsets.only(right: 80,left:80),
                    child: Container(height: 50,width: 10,color: Colors.white,child: Center(child: CircularProgressIndicator()),),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(DemoLocalization.of(context).getTranslatedValue('Confirm')),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
        );
      },
    );
  }


  Future postMessage() async {
    var data = {
      "message": "${Messagecontroller.text}",
      "title":"${Titrecontroller.text}",
      "recipients":_selectedItems
    };
    setState(() {
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
        print(data);
        Fluttertoast.showToast(
            msg: DemoLocalization.of(context).getTranslatedValue('Message_Successfully_Sent'),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            webShowClose:false,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Messagecontroller.clear();
        _selectedNames.clear();
        Titrecontroller.clear();
        _selectedItems.clear();


        setState(() {
          isloading = true;
        });
      }else{
        setState(() {
          print(value.body);
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
     selectedOption = language=="ar"? 'الى':"À";
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(right: 15,left: 15,top: 20),
        child: Form(
          key: fromkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              height(20),
              Text(DemoLocalization.of(context).getTranslatedValue('To'),style: TextStyle(
                fontSize: 16,
                fontWeight:FontWeight.w500,
              ),),
              height(15),
              GestureDetector(
                onTap: (){
                  _showAlertDialog(context,);
                },
                child: Container(
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 1,
                        color: Color(0xff9BABB8),
                      )
                  ),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:_selectedNames.length>0?Text('${_selectedNames.map((e) => e).join(' , ')}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                            ),

                            maxLines:2,
                          ):Text('${DemoLocalization.of(context).getTranslatedValue('To')}'),
                        ),
                      ),
                      isloadingdata?IconButton(
                          splashRadius:10,
                          onPressed: (){
                            isloadingdata?_showAlertDialog(context):null;
                          }, icon:Icon(Icons.arrow_drop_down)):Padding(
                        padding: const EdgeInsets.only(left:10),
                        child: CircularProgressIndicator(),
                      )
                    ],
                  ) ,
                ),
              ),
              height(20),
              Text(DemoLocalization.of(context).getTranslatedValue('Title'),style: TextStyle(
                fontSize: 16,
                fontWeight:FontWeight.w500,
              ),),
              height(15),
              DefaultTextfiled(
                  maxLines: 1,
                  label: DemoLocalization.of(context).getTranslatedValue('Type_Your_Title_Here'),
                  controller:Titrecontroller,
                  hintText:DemoLocalization.of(context).getTranslatedValue('Type_Your_Title_Here'),
                  keyboardType:TextInputType.text,
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
              height(25),
              Padding(
                padding: const EdgeInsets.only(
                    left: 0,
                    right: 0
                ),
                child: GestureDetector(
                  onTap:(){
                    if (fromkey.currentState.validate()) {
                    fromkey.currentState.save();
                    if(_selectedItems.isEmpty){
                      Fluttertoast.showToast(
                        msg:DemoLocalization.of(context).getTranslatedValue('Select_Recipient'),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        webShowClose:false,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }else{
                      postMessage();
                    }

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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
