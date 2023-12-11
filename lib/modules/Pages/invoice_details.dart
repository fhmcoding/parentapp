import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../localization/demo_localization.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';

class InvoiceDetails extends StatefulWidget {
  final id ;
  const InvoiceDetails({Key key,this.id}) : super(key: key);

  @override
  State<InvoiceDetails> createState() => _InvoiceDetailsState();
}

class _InvoiceDetailsState extends State<InvoiceDetails> {
  String access_token = Cachehelper.getData(key: "token");
  String language = Cachehelper.getData(key: "langugeCode");

  bool isloading = true;

   List<dynamic> invoices = [];
   Map invoice = {};


  Future getInvoices() async {
    setState(() {
      isloading = false;
    });
    final response = await http.get(
        Uri.parse('${url}/guardian/invoices/${widget.id}'),
        headers:{'Content-Type':'application/json','Accept':'application/json','Authorization': 'Bearer ${access_token}',}
    ).then((value){
      if(value.statusCode==200){
        var data = json.decode(value.body);
        print(data);
        invoices = data['invoice_lines'];
        invoice = data;
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
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: Text(language=='ar'?'فاتورة':"facture",style: TextStyle(
          color: Colors.black,
        )),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: isloading? SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Padding(
            padding: const EdgeInsets.only(left: 15,right:15,top: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                  children:[
                    Row(
                      children: [
                        Text('${DemoLocalization.of(context).getTranslatedValue('Symbole_de_processus')} :',style: TextStyle(fontSize: 12.5,),),
                        width(5),
                        Text('${invoice['opertion_code']}',style: TextStyle(fontSize: 12.5,),),
                      ],
                    ),
                    Row(
                      children: [
                        Text('${DemoLocalization.of(context).getTranslatedValue('Etabli_en')}',style: TextStyle(fontSize: 13,),),
                        width(5),
                        Text('${DateFormat("dd MMM").format(DateTime.parse('${invoice['created_at']}'))}',style: TextStyle(fontSize: 13,),),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('${DemoLocalization.of(context).getTranslatedValue('Type')} : ',style: TextStyle(fontSize: 13,),),
                        Text('${OpertionType(type:invoice['type'],language:language)}',style: TextStyle(fontSize: 13,),),
                      ],
                    ),
                    Row(
                      children: [
                        Text('${DemoLocalization.of(context).getTranslatedValue('Mis_à_jour_le')}',style: TextStyle(fontSize: 13,),),
                        width(5),
                        Text('${DateFormat("dd MMM").format(DateTime.parse('${invoice['updated_at']}'))}',style: TextStyle(fontSize: 13,),),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
            height(50),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DataTable(
                  columnSpacing: 45,
                  columns: [
                    DataColumn(
                      label: Text('${DemoLocalization.of(context).getTranslatedValue('Description')}',style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                    DataColumn(
                      label: Text('${DemoLocalization.of(context).getTranslatedValue('Quantité')}',style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                    DataColumn(
                      label: Text('${DemoLocalization.of(context).getTranslatedValue('Montant')}',style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                  ],
                  rows:invoices.map((e) => DataRow(
                      cells: [
                        DataCell(
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(0),
                              child: Text(OpertionType(type:invoice['type'],language:language)
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(0),
                              child: Text(e['qty'].toString()),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(0), // Set padding to zero
                              child: Text("${e['amount']} ${Devise(language: language)} "),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).toList(),
                  dataRowHeight: 50,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 25,top: 20,left: 25),
                  child: Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${DemoLocalization.of(context).getTranslatedValue('Montant')} : ',style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                          width(5),
                          Text('${invoice['total_by_invoice_line']} ${Devise(language: language)} '),
                        ],
                      ),
                      invoice['total_by_invoice_line'] - double.tryParse(invoice['amount'])>0? height(20):height(0),
                      invoice['total_by_invoice_line'] - double.tryParse(invoice['amount'])>0? Row(
                        children: [
                          Text('${DemoLocalization.of(context).getTranslatedValue('Discount')} : ',style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                          width(5),
                           Text('${invoice['total_by_invoice_line'] - double.tryParse(invoice['amount'])} درهم ',style: TextStyle(
                              color:Colors.purple,
                              fontWeight: FontWeight.bold
                          )),
                        ],
                      ):height(0),
                      height(20),
                      Row(
                        children: [
                          Text('${DemoLocalization.of(context).getTranslatedValue('Le_total')} : ',style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),),
                          width(5),
                          Text('${invoice['total_paid']} ${Devise(language: language)} ',style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold
                          )),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
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


  String Devise({language}){
    if(language=="ar"){
      return 'درهم';
    }else{
      return 'MAD';
    }
  }
}
