import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../localization/demo_localization.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';

class Classes extends StatefulWidget {
   Classes({Key key}) : super(key: key);

  @override
  State<Classes> createState() => _ClassesState();
}

class _ClassesState extends State<Classes> with SingleTickerProviderStateMixin{
  String language = Cachehelper.getData(key: "langugeCode");
  TabController _tabController;
   List<String> daysOfWeek = [
     'Lundi',
     'Mardi',
     'Mercredi',
     'Jeudi',
     'Vendredi'
   ];

   List<String> daysOfWeekArabic = [
     'الاثنين',
     'الثلاثاء',
     'الأربعاء',
     'الخميس',
     'الجمعة',
   ];

  String selectedOption ;

   List<String> _students = [];

   List students = [];

   int studentId;

   void getStudent({first_name}){
     var student = students.where((element) => element['first_name']==first_name).first;
     setState(() {
       print('object');
       studentId = student['id'];
       getGroups(id:student['id']);
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
         _students..add(language=="ar"?'اختر التلميذ':"sélectionner l'élève");
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


  bool isloading = true;
  String access_token = Cachehelper.getData(key: "token");


  List groups = [];
  Future getGroups({id})async{
    print(id);
    setState(() {
      isloading = false;
    });
    final response = await http.get(
        Uri.parse('${url}/guardian/groups?filter[students.id]=${id}&include=sessions,sessions.subject'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        printFullText(data.toString());
        groups = data['data'][0]['sessions'];
         print(groups);
        setState(() {
          isloading = true;
        });
      }else{
        var data = json.decode(value.body);
        setState(() {
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
    selectedOption = language=="ar"?'اختر التلميذ':"sélectionner l'élève";
    _tabController = TabController(length: 5, vsync: this);
    GetStudents();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    printFullText(groups.toString());
    return !isloading?Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(color:Colors.purple)
        ],
      ),
    ):Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20,left: 20,top: 20),
          child: Text(DemoLocalization.of(context).getTranslatedValue('Please_Select_Person_To_Login_As'),style: TextStyle(fontSize: 15,fontWeight:FontWeight.w500,color: Colors.grey[600]),),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 10),
          child: Container(
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


        groups.length>0?TabBar(
          indicatorColor:Colors.purple,
          labelColor: Colors.black,
          controller: _tabController,
          tabs: [
            ...language=="ar"?daysOfWeekArabic.map((e) =>Tab(child: Text('${e}',style: TextStyle(fontSize: 15),textAlign: TextAlign.center,)),)
          :daysOfWeek.map((e) =>Tab(child: Text('${e}',style: TextStyle(fontSize:e.length>5?11:13),textAlign: TextAlign.center,)),)],
        ):height(0),
        isloading? groups.length>0?Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ...daysOfWeek.map((g){
               var filteredSessions =
                groups.where((element) => element['day'] == g).toList();
                filteredSessions.sort((a, b) => a['session_start_at'].compareTo(b['session_start_at']));
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      filteredSessions.length>0? ListView.builder(
                          itemBuilder: (context,index){
                        return Padding(
                                padding: const EdgeInsets.only(top: 10,right: 10,left: 10,bottom: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[200],
                                        spreadRadius: 2,
                                        blurRadius: 3,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                    color: Colors.white,
                                  ),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15,bottom: 20,right: 15,top: 15),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Column(
                                                children: [
                                                  Text('${filteredSessions[index]['session_start_at_readable'][0]}',style: TextStyle(
                                                    fontSize: 17
                                                  )),
                                                  Text('${filteredSessions[index]['session_end_at_readable'][1]}',style: TextStyle(
                                                      fontSize: 14,
                                                    color: Colors.grey[600]
                                                  )),
                                                ],
                                              ),
                                            ),
                                            width(10),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Container(
                                                width: 2,
                                                height: 35,
                                                color: Colors.purple,
                                              ),
                                            ),
                                            width(10),
                                            Column(
                                              crossAxisAlignment:CrossAxisAlignment.start,
                                              children: [
                                                Text('${filteredSessions[index]['subject']['name'][0].toUpperCase() + filteredSessions[index]['subject']['name'].substring(1)}',style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500)),
                                                Text('${filteredSessions[index]['user']['role']} ${filteredSessions[index]['user']['first_name']} ${filteredSessions[index]['user']['last_name']}',style: TextStyle(fontSize: 12,color: Colors.grey[700]))
                                              ],
                                            ),

                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                      },
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      itemCount: filteredSessions.length,
                      ):Padding(padding:EdgeInsets.only(right: 20,left: 20,top: 20),child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/nondata.jpg'),
                          Text(language=='ar'?"لا توجد اي حصة في هذا اليوم":"Il n'y a pas de cours ce jour-là",style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500
                          ),)
                        ],
                      )),
                      // ...filteredSessions.map((e){
                      //   return Padding(
                      //     padding: const EdgeInsets.only(top: 10,right: 10,left: 10,bottom: 10),
                      //     child: Container(
                      //       decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(5),
                      //         boxShadow: [
                      //           BoxShadow(
                      //             color: Colors.grey[200],
                      //             spreadRadius: 2,
                      //             blurRadius: 3,
                      //             offset: Offset(1, 1),
                      //           ),
                      //         ],
                      //         color: Colors.white,
                      //       ),
                      //       width: double.infinity,
                      //       child: Padding(
                      //         padding: const EdgeInsets.only(left: 15,bottom: 20,right: 15,top: 15),
                      //         child: Column(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Text('${e}')
                      //             // Row(
                      //             //   children: [
                      //             //     Padding(
                      //             //       padding: const EdgeInsets.only(top: 8),
                      //             //       child: Column(
                      //             //         children: [
                      //             //           Text('${e['session_start_at_readable']}',style: TextStyle(
                      //             //             fontSize: 17
                      //             //           )),
                      //             //           Text('${e['session_end_at_readable']}',style: TextStyle(
                      //             //               fontSize: 14,
                      //             //             color: Colors.grey[600]
                      //             //           )),
                      //             //         ],
                      //             //       ),
                      //             //     ),
                      //             //     width(10),
                      //             //     Padding(
                      //             //       padding: const EdgeInsets.only(top: 8),
                      //             //       child: Container(
                      //             //         width: 2,
                      //             //         height: 35,
                      //             //         color: Colors.purple,
                      //             //       ),
                      //             //     ),
                      //             //     width(10),
                      //             //     Column(
                      //             //       crossAxisAlignment: CrossAxisAlignment.start,
                      //             //       children: [
                      //             //         Text('${e['subject']['name'][0].toUpperCase() + e['subject']['name'].substring(1)}',style: TextStyle(
                      //             //                       fontSize: 17,fontWeight: FontWeight.w500
                      //             //                   )),
                      //             //         Text('Pr. ${e['user']['first_name']} ${e['user']['last_name']}',style: TextStyle(
                      //             //                       fontSize: 12,color: Colors.grey[700]
                      //             //        ))
                      //             //       ],
                      //             //     ),
                      //             //
                      //             //   ],
                      //             // )
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   );
                      // })
                    ],
                  ),
                );
              })
            ],
          ),
        ):Padding(padding:EdgeInsets.only(right: 20,left: 20,top: 20),child:buildNodata(context),):Center(child: Column(
          children: [
            CircularProgressIndicator(),
          ],
        )),

      ],
    );
  }
}
