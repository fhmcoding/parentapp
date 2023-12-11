import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../localization/demo_localization.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';
import 'invoice_details.dart';
class Invoives extends StatefulWidget {
  const Invoives({Key key}) : super(key: key);

  @override
  State<Invoives> createState() => _InvoivesState();
}

class _InvoivesState extends State<Invoives>{
  String access_token = Cachehelper.getData(key: "token");
  String language = Cachehelper.getData(key: "langugeCode");

  bool isloading = true;
  List invoices = [];
  double sumRestAmount = 0.0;
  Future getInvoices() async {
    setState(() {
      isloading = false;
    });
    final response = await http.get(
        Uri.parse('${url}/guardian/invoices'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        print(data['data']);
        invoices = data['data'];
        for (var item in invoices){
          if (item["rest_amount"] != null) {
            sumRestAmount += item["rest_amount"];
          }
        }
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
    getInvoices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:isloading? invoices.length>0?SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20,left: 20,top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${DemoLocalization.of(context).getTranslatedValue('doit_être_payé')}',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),),
                  Text('${sumRestAmount} ${Devise(language: language)}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.red),),

                ],
              ),
            ),
           ListView.builder(
             physics: BouncingScrollPhysics(),
             shrinkWrap: true,
             itemCount: invoices.length,
             itemBuilder: (context,index){
             return Padding(
               padding: const EdgeInsets.all(8.0),
               child: Card(
                 elevation: 1.9,
                 child: Padding(
                   padding: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 20),
                   child: Column(
                     children: [
                       Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Text('${invoices[index]['opertion_code']}',style: TextStyle(
                                 fontWeight:FontWeight.w500,
                                 color:Colors.blueGrey,
                                 fontSize: 11
                             ),),
                             Container(
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(5),
                                   color: Color(0xffeeedfd),
                                 ),
                                 child: Padding(
                                   padding: const EdgeInsets.all(5.0),
                                   child: Text(Status(status:invoices[index]['status'],language:language),style: TextStyle(
                                       fontSize: 11.5,
                                       fontWeight: FontWeight.bold,
                                       color: Colors.purpleAccent
                                   )),
                             )),
                           ],
                         ),
                       ),
                       Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Row(
                           mainAxisAlignment:MainAxisAlignment.spaceBetween,
                           children: [
                             Text('${invoices[index]['amount']} ${Devise(language:language)} ',style: TextStyle(
                                 fontWeight: FontWeight.bold
                             )),
                             Text(DateFormat("dd MMM").format(DateTime.parse('${invoices[index]['created_at']}')),style:TextStyle(
                                 fontSize: 12
                             ),),
                           ],
                         ),
                       ),
                       Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Row(
                           mainAxisAlignment:MainAxisAlignment.spaceBetween,
                           children: [
                             Text('${DemoLocalization.of(context).getTranslatedValue('Type_dopération')}',style: TextStyle(
                                 fontWeight: FontWeight.bold
                             )),
                             Text('${OpertionType(type:invoices[index]['type'],language:language)}',style:TextStyle(
                                 fontSize: 14
                             ),),
                           ],
                         ),
                       ),
                       height(10),
                       Container(
                           width: double.infinity,
                           height: 45,
                           decoration: BoxDecoration(
                             color: Colors.purple,
                             borderRadius: BorderRadius.circular(5),
                           ),
                           child: TextButton(
                               onPressed: (){
                                 Navigator.of(context).pushAndRemoveUntil(
                                     MaterialPageRoute(
                                         builder: (context) => InvoiceDetails(id:invoices[index]['id'],)),
                                         (route) => true);
                               }, child:Text(DemoLocalization.of(context).getTranslatedValue('Ouvrir'),style: TextStyle(
                               color: Colors.white,
                               fontSize: 16.5,
                               fontWeight: FontWeight.bold
                           ),)))
                     ],
                   ),
                 ),
               ),
             );
           }),
          ],
        ),
      ):Center(
        child:buildNodata(context),
      ):Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.purple)
          ],
        ),
      ),
    );
  }

  String OpertionType({type,language}){
   if(type == "registration_payment"){
     if(language=='ar'){
       return 'تكاليف تسجيل';
     }else{
       return 'Frais inscription';
     }
   }
   if(type == "monthly_payment"){
     if(language=='ar'){
       return 'الدفع الشهري';
     }else{
       return 'Paiement mensuel';
     }

   }
  }

  String Status({status,language}){
    if(status == "unpaid"){
      if(language=="ar"){
        return 'غير مدفوع';
      }else{
        return 'Non payé';
      }

    }
    if(status == "paid"){
      if(language=="ar"){
        return 'مدفوع';
      }else{
        return 'payé';
      }

    }
    if(status == "semipaid"){
      if(language=="ar"){
        return 'شبه مدفوعة';
      }else{
        return 'Semi-entraîné';
      }
    }
  }

  String Devise({language}){
    if(language=="ar"){
      return 'درهم';
    }else{
      return 'MAD';
    }
  }

}
