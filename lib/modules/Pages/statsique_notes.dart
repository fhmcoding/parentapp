import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../localization/demo_localization.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';
import 'dart:convert';


class StastiqueNotes extends StatefulWidget {
  List students = [];
  StastiqueNotes({Key key,this.students}) : super(key: key);

  @override
  State<StastiqueNotes> createState() => _StastiqueNotesState();
}

class _StastiqueNotesState extends State<StastiqueNotes> {
  String language = Cachehelper.getData(key: "langugeCode");

  TooltipBehavior _tooltipBehavior;
  List students = [];
  String access_token = Cachehelper.getData(key: "token");
  bool isloading = true;
  bool isStatiqueloading = true;

  List chartData = [

  ];

  String selectedOption;
  String selectedSemster;
  List<String> _students = [];
  List<String> _semister = [];
  List Semister = [];
  int studentId;

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
  }
  int semisId ;
  void getSemister({semister}){
    var semis = Semister.where((element) => element['semister']==semister).first;
    setState(() {
      semisId = semis['id'];
      print(semisId);
    });
  }
  void getStudent({first_name}){
    var student = students.where((element) => element['first_name']==first_name).first;
    setState(() {
      studentId = student['id'];
      print(studentId);
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
        print(students);
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

  Future getStastiqueNotes({id,SemisId}) async {
    print(id);
    print(SemisId);
    setState(() {
      isStatiqueloading = false;
    });
    final response = await http.get(
        Uri.parse('${url}/guardian/statistiques/notes?student_id=${studentId}&semester=${semisId}'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        chartData = json.decode(value.body);
        printFullText(chartData.toString());
        setState(() {
          isStatiqueloading = true;
        });
      }else{
        setState(() {
          print(value.body);
          isStatiqueloading = true;
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
    _tooltipBehavior = TooltipBehavior(enable: true);
    GetStudents();
    getSemisters();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return isloading?Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        height(10),
        Padding(
          padding: const EdgeInsets.only(left: 15,right: 15,top: 15,bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DemoLocalization.of(context).getTranslatedValue('Please_Select_Person_To_Login_As'),style: TextStyle(fontSize: 15,fontWeight:FontWeight.w500,color: Colors.grey[600]),),
              height(20),
              Container(
                height: 55,
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
                          children:[
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
              height(10),
              Text(DemoLocalization.of(context).getTranslatedValue('Please_Select_Course'),style: TextStyle(fontSize: 15,fontWeight:FontWeight.w500,color: Colors.grey[600]),),
              height(10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                       borderRadius:
                        BorderRadius.circular(10),border: Border.all(color:Color(0xff9BABB8),),),
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
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(value),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    flex: 0,
                    child:Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Container(
                          height: 55,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: TextButton(onPressed: (){
                            if(studentId!=null||semisId!=null){
                              getStastiqueNotes(
                                  id: studentId,
                                  SemisId: semisId
                              );
                            }
                          }, child:Text(DemoLocalization.of(context).getTranslatedValue('Search'),style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),))),
                    )
                  ),
                ],
              ),
              height(20),
            ],
          ),
        ),
        isStatiqueloading?chartData.length>0 ?Expanded(
          child:Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SfCartesianChart(
              primaryXAxis:CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0),
                  majorTickLines: MajorTickLines(width: 0),
                  labelRotation: -90,
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10
                  )
              ),
              primaryYAxis: NumericAxis(
                axisLine: AxisLine(width: 0),
                majorTickLines: MajorTickLines(size: 0),
              ),
              tooltipBehavior: _tooltipBehavior,
              series: <ChartSeries<dynamic, String>>[
                LineSeries<dynamic, String>(
                  color: Colors.purple,
                  dataSource:chartData,
                  xValueMapper: (datum, _) => datum["subject"]["name"],
                  yValueMapper: (datum, _) => double.parse(datum["average_notes"]),
                  enableTooltip: true,
                ),
              ],
            ),
          ),
        ):Padding(
          padding: const EdgeInsets.only(right: 20,left: 20,top: 20),
          child:buildNodata(context),
        ):Center(
          child:Column(
            children: [
              height(100),
              CircularProgressIndicator(color: Colors.purple),
            ],
          ),
        )
      ],
    ):Center(
      child: CircularProgressIndicator(color: Colors.purple),
    );

  }
}
class _SalesData {
  _SalesData(this.note, this.metier);
  final double metier;
  final double note;
}
