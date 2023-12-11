import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../localization/demo_localization.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';

class ExtrActivties extends StatefulWidget {
  const ExtrActivties({Key key}) : super(key: key);

  @override
  State<ExtrActivties> createState() => _ExtrActivtiesState();
}

class _ExtrActivtiesState extends State<ExtrActivties> {

  String access_token = Cachehelper.getData(key: "token");
  bool isloading = true;
  List extraActives = [];
  Future getExtraActives()async{
    setState(() {
      isloading = false;
    });
    final response = await http.get(
        Uri.parse('${url}/guardian/extracurricular_activities'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        print(data);
        extraActives = data['data'];
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

  bool _expanded = false;
  int maxline = 3;
  void _toggleExpansion() {
    setState(() {
      _expanded = !_expanded;
    });
  }
  @override
  void initState() {
    getExtraActives();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return isloading? extraActives.length>0?SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          height(20),
          ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context,index){
                List<String> dateParts = extraActives[index]['date'].split("-");
                List<int> dateIntegers = dateParts.map((part) => int.parse(part)).toList();
                return Padding(
                  padding: const EdgeInsets.only(left: 15,right: 15,top: 20,bottom: 8),
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${extraActives[index]['title']}",style:TextStyle(color:Color(0xff211c1c),fontSize: 15.4,fontWeight: FontWeight.w500)),
                          height(5),
                         extraActives[index]['is_day_correct']?Text("${dateIntegers[0]} / ${dateIntegers[1]} / ${dateIntegers[2]}",style: TextStyle(color:Color(0xff9BABB8),fontSize: 10.0,fontWeight: FontWeight.w500),textDirection:TextDirection.ltr):
                          Text("${dateIntegers[0]} / ${dateIntegers[1]}",style:TextStyle(color:Color(0xff9BABB8),fontSize: 10.0,fontWeight: FontWeight.w500),textDirection:TextDirection.ltr),
                          height(2),
                          Text('${extraActives[index]['description']}',
                            style: TextStyle(
                                height:1.5,
                                color:Color(0xff211c1c),
                            ),
                            textAlign:TextAlign.justify,
                          ),
                          height(12),
                        ],
                      ),
                    ),
                  ),
                );
              }, separatorBuilder: (context,index){
            return Divider();
          }, itemCount: extraActives.length)

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
