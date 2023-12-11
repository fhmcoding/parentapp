import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../localization/demo_localization.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';
class Students extends StatefulWidget {
  const Students({Key key}) : super(key: key);

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  List students = [];
  bool isloading = true;
  String access_token = Cachehelper.getData(key: "token");

  Future GetStudents()async {
    setState(() {
      isloading = false;
    });
    final response = await http.get(
        Uri.parse('${url}/guardian/students'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        students = data['data'];
        print('-----------------');
        printFullText(data['data'].toString());
        print('-----------------');
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
    GetStudents();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return isloading? students.length>0?SingleChildScrollView(
      child:Column(
        children: [
          height(20),
         ListView.builder(
           shrinkWrap: true,
             itemCount: students.length,
             itemBuilder: (context,index){
           return Padding(
             padding: const EdgeInsets.all(8.0),
             child: Card(
               elevation: 3,
               color: Colors.white,
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          maxRadius: 35,
                          backgroundImage: NetworkImage('${students[index]['avatar']}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${DemoLocalization.of(context).getTranslatedValue('First_Name')} : ${students[index]['first_name']}',style: TextStyle(
                                fontWeight: FontWeight.w500,
                              )),
                              Text('${DemoLocalization.of(context).getTranslatedValue('Last_Name')} : ${students[index]['last_name']}',style: TextStyle(
                                fontWeight: FontWeight.w500,
                              )),
                              Text('${DemoLocalization.of(context).getTranslatedValue('Path_Code')} : ${students[index]['massar_code']}',style: TextStyle(
                                fontWeight: FontWeight.w500
                              )),

                            ],
                          ),
                        )
                      ],
                    )

                   ],
                 ),
               ),
             ),
           );
         })
        ],
      ),
    ):Center(child: buildNodata(context)):Center(
      child: CircularProgressIndicator(color: Colors.purple),
    );
  }
}
