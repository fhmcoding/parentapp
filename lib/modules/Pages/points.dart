

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../localization/demo_localization.dart';
import '../../shared/remote/cachehelper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';

class Points extends StatefulWidget {

   Points({Key key,}) : super(key: key);

  @override
  State<Points> createState() => _PointsState();
}

class _PointsState extends State<Points> {
  String access_token = Cachehelper.getData(key: "token");
  String language = Cachehelper.getData(key: "langugeCode");

  bool isloading = true;
  bool isNotesloading = true;
  List students = [];
  String selectedOption;
  String selectedSemster;
  String selectedExame;
  List<String> _students = [];
  List<String> _semister = [];
  List<String> _Exames = [];
  List Semister = [];
  List Exames = [];

  void getSemisters(){
    Semister =[{
      "id":1,
      "semister":language=="ar"?"دورة الاولى":"Premier semestre"
    },
      {
        "id":2,
        "semister":language=="ar"?"دورة التانية":"Deuxième semestre"
      },
      {
        "id":3,
        "semister":language=="ar"?"الكل":"Tout"
      },];
    _semister.add(language=="ar"?'اختار دورة':"sélectionner un semestre");
    Semister.forEach((element){
      _semister.add(element['semister']);
    });
    print(_students);
  }

  void getExams(){

    Exames =[{
      "id":1,
      "exame":language=="ar"?"الفرض الاولى":"Premier exam"
    },
      {
        "id":2,
        "exame":language=="ar"?"الفرض التانية":"Deuxième exam"
      },
      {
        "id":3,
        "exame":language=="ar"?"الفرض الثالث":"La troisième exam"
      },
      {
        "id":4,
        "exame":language=="ar"?"الفرض الرابع":"La quatrième exam"
      },
    ];
    _Exames.add(language=="ar"?'اختار الفرض':"sélectionner un exam");
    Exames.forEach((element){
      _Exames.add(element['exame']);
    });
    print(_students);
  }
  var semisId;
  var examId;
  void getSemister({semister}){
    var semis = Semister.where((element) => element['semister']==semister).first;
    setState(() {
      semisId = semis['id'];
      print(semisId);
    });
  }
  void getExames({exame}){
    var exam = Exames.where((element) => element['exame']==exame).first;
    setState(() {
      print(exam['id']);
      examId = exam['id'];
      getNotes(id:studentId,exam_number:examId);
    });
  }

  List notes = [];
  Future getNotes({id,exam_number}) async {
    setState(() {
      isNotesloading = false;
    });
    final response = await http.get(
        Uri.parse('${url}/guardian/notes?filter[student_id]=${id}&filter[exam_number]=${exam_number}'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        notes = data['data'];
        print(data);
        setState(() {
          isNotesloading = true;
        });
      }else{
        setState(() {
          print(value.body);
          isNotesloading = true;
        });
      }

    }).onError((error, stackTrace){
      print(error);
    });
    return response;
  }

  int studentId;
  void getStudent({first_name}){
    var student = students.where((element) => element['first_name']==first_name).first;
    setState(() {
      studentId = student['id'];
      getNotes(id:studentId,exam_number:examId);
    });
  }
  Future GetStudents() async {
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

@override
  void initState() {
  selectedOption = language=="ar"?'اختر التلميذ':"sélectionner l'élève";
  selectedSemster = language=="ar"?'اختار دورة':"sélectionner un semestre";
  selectedExame = language=="ar"?'اختار الفرض':"sélectionner un exam";
  GetStudents();
  getSemisters();
  getExams();
  super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return isloading?SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(right: 20,left: 20,top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text(DemoLocalization.of(context).getTranslatedValue('Please_Select_Person_To_Login_As'),style: TextStyle(fontSize: 15,fontWeight:FontWeight.w500,color: Colors.grey[600]),),
            height(20),
            Container(
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
                  style:TextStyle(color:Colors.grey[600]),
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
                          Text(value,textDirection: TextDirection.ltr),

                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            height(10),
            Text(DemoLocalization.of(context).getTranslatedValue('Please_Select_Course'),style: TextStyle(fontSize: 15,fontWeight:FontWeight.w500,color: Colors.grey[600]),),
            height(10),
            Container(
              height: 50,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color:Color(0xff9BABB8),),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSemster,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.grey[600],),
                  onChanged: (String newValue) {
                    setState(() {
                      selectedSemster = newValue;
                      getSemister(semister:newValue);
                    });
                  },
                  items:_semister.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value:value,
                      child:Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            height(10),
            Text(language=='ar'?'الرجاء تحديد الفرض':'Veuillez sélectionner exam',style: TextStyle(fontSize: 15,fontWeight:FontWeight.w500,color: Colors.grey[600]),),
            height(10),
            Container(
              height: 50,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color:Color(0xff9BABB8),),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedExame,
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.grey[600],),
                  onChanged: (String newValue) {
                      setState(() {
                      selectedExame = newValue;
                      getExames(exame:newValue);
                    });
                  },
                  items:_Exames.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child:Text(value,),
                    );
                  }).toList(),
                ),
              ),
            ),

            height(20),
            isNotesloading?notes.where((element) => element['semester']=="${semisId}" || element['exam_number']=="${examId}").toList().length>0?ListView.builder(
                itemCount:notes.where((element) => element['semester']=="${semisId}").toList().length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap:true,
                itemBuilder:(context,index){
                  var note = notes.where((element) => element['semester']=="${semisId}").toList();
                 return Card(
                    elevation: 3,
                    child: Container(
                      width: double.infinity,
                     child: Padding(
                       padding: const EdgeInsets.only(top:10,right: 20,left: 20,bottom: 10),
                       child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: [
                              Text('${DemoLocalization.of(context).getTranslatedValue('Subject')} : ',style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              ),),
                              width(0),
                              Text('${note[index]['subject']['name'][0].toUpperCase() + note[index]['subject']['name'].substring(1)}',style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13
                              ),),
                            ],
                          ),
                          Row(
                            children: [
                              Text('${DemoLocalization.of(context).getTranslatedValue('Assignment')} : ',style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              ),),
                              width(0),
                              Text('${note[index]['exam_number']}',style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13
                              ),),
                            ],
                          ),
                          Row(
                            children: [
                              Text('${DemoLocalization.of(context).getTranslatedValue('Grade')} : ',style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              ),),
                              width(0),
                              Text('${note[index]['note']}',style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13
                              ),),
                            ],
                          ),
                          Row(
                            children: [
                              Text('${DemoLocalization.of(context).getTranslatedValue('Semester')} : ',style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              ),),
                              width(0),
                              Text(note[index]['semester']=="1"?'${DemoLocalization.of(context).getTranslatedValue('First_Semester')}':"${DemoLocalization.of(context).getTranslatedValue('Second_Semester')}",style: TextStyle(
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
               }):buildNodata(context):Center(child: Column(
                  children: [
                    height(100),
                    CircularProgressIndicator(color: Colors.purple),
              ],
            )),

          ],
        ),
      ),
    ):Center(
      child: CircularProgressIndicator(color: Colors.purple),
    );
  }

  String selectExam({exam,context}){
    if(exam=='1'){
      return DemoLocalization.of(context).getTranslatedValue('First_Semester');
    }
    if(exam=='2'){
      return DemoLocalization.of(context).getTranslatedValue('Second_Semester');
    }
    if(exam=='3'){
      return DemoLocalization.of(context).getTranslatedValue('First_Semester');
    }
    if(exam=='4'){
      return DemoLocalization.of(context).getTranslatedValue('First_Semester');
    }
  }
}
