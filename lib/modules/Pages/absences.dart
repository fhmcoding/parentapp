import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:parentapp/shared/components/components.dart';
import 'package:http/http.dart' as http;
import '../../localization/demo_localization.dart';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';

class Absences extends StatefulWidget {
   Absences({Key key}) : super(key: key);

  @override
  State<Absences> createState() => _AbsencesState();
}

class _AbsencesState extends State<Absences> {
  String language = Cachehelper.getData(key: "langugeCode");

  List students = [];

  String access_token = Cachehelper.getData(key: "token");
  bool isAbsenceloading = true;
  bool isloading = true;

  List<String> _students = [];
  int studentId;
  String selectedOption;
  String selectedExam;
  void getStudent({first_name}){
    var student = students.where((element) => element['first_name']==first_name).first;
    setState(() {
      studentId = student['id'];
      getAbsences(id:studentId);
    });
  }
  Future GetStudents() async{
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
        _students.add(language=="ar"?'اختر التلميذ':"sélectionner l'élève");
        students.forEach((element){
          _students.add(element['first_name']);
        });
        print('-----------------');
        print(data['data']);
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
  List absences = [];

  Future getAbsences({id}) async {
    print(id);
    setState(() {
      isAbsenceloading = false;
    });
    final response = await http.get(
        Uri.parse('${url}/guardian/attendance_records?filter[student_id]=${id}'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        absences = data['data'];
        print('-----------------------------------');
        printFullText(data.toString());
        print('-----------------------------------');
        setState(() {
          isAbsenceloading = true;
        });
      }else{
        setState(() {
          print(value.body);
          isAbsenceloading = true;
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }

  @override
  void initState() {
    selectedOption = language=="ar"?'اختر التلميذ':"sélectionner l'élève";
    GetStudents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var WithoutJustification = absences.where((element) => element['justification']==null).toList();
    var WithJustification = absences.where((element) => element['justification']!=null).toList();
    return isloading?SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Padding(
            padding: const EdgeInsets.only(right: 20,left: 20,top: 20),
            child: Text(DemoLocalization.of(context).getTranslatedValue('Please_Select_Person_To_Login_As'),style: TextStyle(fontSize: 15,fontWeight:FontWeight.w500,color: Colors.grey[600]),),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 10),
            child: Container(
              height: 50,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color:Color(0xff9BABB8),),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedOption,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.grey[600],),
                  onChanged: (String newValue) {
                    setState(() {
                      selectedOption = newValue;
                      getStudent(first_name:newValue);
                    });
                  },
                  items:_students.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(Icons.person_2_outlined,color:Color(0xff9BABB8)),
                          SizedBox(width: 10,),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          height(20),

          isAbsenceloading?absences.length>0?Padding(
            padding: const EdgeInsets.only(right: 25,left: 25,top: 5,bottom: 10),
            child:Column(
              children: [
                Row(
                  children: [
                    Text('${DemoLocalization.of(context).getTranslatedValue('Absence_non_justifiée')} : ',style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),),
                    width(0),
                    Text('${WithoutJustification.length}',style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13
                    ),),
                  ],
                ),
                Row(
                  children: [
                    Text('${DemoLocalization.of(context).getTranslatedValue('Absence_justifiée')} : ',style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),),
                    width(0),
                    Text('${WithJustification.length}',style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13
                    ),)
                  ],
                ),
                Row(
                  children: [
                    Text('${DemoLocalization.of(context).getTranslatedValue('Total_des_absences')} : ',style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),),
                    width(0),
                    Text('${absences.where((element) =>element['type']=='absence').toList().length}',style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13
                    ),)
                  ],
                ),
              ],
            ),
          ):height(0):height(0),
          isAbsenceloading?absences.length>0?  Container(
            height: 1,
            width: double.infinity,
            color: Colors.grey[100],
          ):height(0):height(0),
          isAbsenceloading?absences.length>0?ListView.builder(
              itemCount:absences.length,
              physics: BouncingScrollPhysics(),
              shrinkWrap:true,
              itemBuilder:(context,index){
                String inputDate = "${absences[index]['created_at']}";
                // DateTime dateTime = DateTime.parse(inputDate);
                // String formattedDate = DateFormat('HH:mm / d MMM').format(dateTime);
                return absences[index]['type']=='absence'?
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
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
                    child: Padding(
                      padding: const EdgeInsets.only(top:10,right: 20,left: 20,bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: [
                              Row(
                                children: [
                                  Text('${DemoLocalization.of(context).getTranslatedValue('Leçon')} :',style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13
                                  ),),
                                  width(4),
                                  language!='ar'?Text('${absences[index]['session']==1?"matin":"soir"}',style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13
                                  ),):Text('${absences[index]['session']==1?"صباح":"مساء"}',style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13
                                  ),),
                                ],
                              ),
                              Container(
                                width:60,
                                child:Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Center(
                                    child:language!="ar"?Text('${absences[index]['type']=='delay'?"delay":"absence"}',style: TextStyle(
                                        fontSize: 9.5,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    )):Text('${absences[index]['type']=='delay'?"تأخير":"غياب"}',style: TextStyle(
                                        fontSize: 9.5,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    )),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color:Colors.purple,
                                  // border: Border.all(color: Colors.purple,width: 1.5)
                                ),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                          Row(
                            children: [
                              Text('${DemoLocalization.of(context).getTranslatedValue('Jour')} : ',style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13
                              ),),
                              width(4),
                              Text('${absences[index]['created_at']}',style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13
                              ),),
                            ],
                          ),
                          Row(
                            children: [
                              Text('${DemoLocalization.of(context).getTranslatedValue('Justification_de_labsence')} : ',style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                 ),),
                              width(4),
                              Text(absences[index]['justification']!=null?'${absences[index]['justification']}':'${DemoLocalization.of(context).getTranslatedValue('Sans_justification')}',style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13
                              ),),
                            ],
                          ),


                        ],
                      ),
                    ),
                  ),
                ):
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                   width: double.infinity,
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
                   child: Padding(
                     padding: const EdgeInsets.only(top:10,right: 20,left: 20,bottom: 10),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: <Widget>[
                         Row(
                           children: [
                             Row(
                               children: [
                                 Text('${DemoLocalization.of(context).getTranslatedValue('Leçon')} :',style: TextStyle(
                                     fontWeight: FontWeight.bold,
                                     fontSize: 13
                                 ),),
                                 width(4),
                                 language!='ar'?Text('${absences[index]['session']==1?"matin":"soir"}',style: TextStyle(
                                     fontWeight: FontWeight.w500,
                                     fontSize: 13
                                 ),):Text('${absences[index]['session']==1?"صباح":"مساء"}',style: TextStyle(
                                     fontWeight: FontWeight.w500,
                                     fontSize: 13
                                 ),),
                               ],
                             ),
                             Container(
                               width:60,
                               child:Padding(
                                 padding: const EdgeInsets.all(4.0),
                                 child: Center(
                                   child:language!="ar"?Text('${absences[index]['type']=='delay'?"delay":"absence"}',style: TextStyle(
                                       fontSize: 9.5,
                                       color: Colors.white,
                                       fontWeight: FontWeight.bold
                                   )):Text('${absences[index]['type']=='delay'?"تأخير":"غياب"}',style: TextStyle(
                                       fontSize: 9.5,
                                       color: Colors.white,
                                       fontWeight: FontWeight.bold
                                   )),
                                 ),
                               ),
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(50),
                                 color:Colors.purple,
                                 // border: Border.all(color: Colors.purple,width: 1.5)
                               ),
                             ),
                           ],
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         ),
                         Row(
                           children: [
                             Text('${DemoLocalization.of(context).getTranslatedValue('Jour')} : ',style: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 fontSize: 13
                             ),),
                             width(4),
                             Text('${absences[index]['created_at']}',style: TextStyle(
                                 fontWeight: FontWeight.w500,
                                 fontSize: 13
                             ),),
                           ],
                         ),
                         Row(
                           children: [
                             Text('${DemoLocalization.of(context).getTranslatedValue('Justification_du_retard')} : ',style: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 fontSize: 13
                             ),),
                             width(4),
                             Text(absences[index]['justification']!=null?'${absences[index]['justification']}':'${DemoLocalization.of(context).getTranslatedValue('Sans_justification')}',style: TextStyle(
                                 fontWeight: FontWeight.w500,
                                 fontSize: 13
                             ),),
                           ],
                         ),
                       ],
                     ),
                   ),
                    ),
                );
              }):Padding(
            padding: const EdgeInsets.only(right: 20,left: 20,top: 20),
            child: buildNodata(context),
          ):Center(child: Column(
                children: [
                  height(100),
                  CircularProgressIndicator(color: Colors.purple),
                ],
          )),
        ],
      ),
    ): Center(
      child:CircularProgressIndicator(color: Colors.purple),
    );
  }
}

