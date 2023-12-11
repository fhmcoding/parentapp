import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parentapp/Layout/HomeLayout/home.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String selectedOption = 'اختار شخص الذي تريد دخول به';
  List<String> options = ['اختار شخص الذي تريد دخول به', 'Hamza', 'Yassin','Laila'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30,),

            Text('Wechats مرحبًا بكم في ',style: TextStyle(fontSize: 29,fontWeight:FontWeight.w600,color: Colors.teal),),

            SizedBox(height: 50,),

            Image.asset('assets/bg.png',color: Colors.greenAccent[700],height: 340,width: 340,),

            SizedBox(height: 40,),

            Padding(
              padding: const EdgeInsets.only(left: 50,right: 50),
              child: Text('الرجاء تحديد شخص الذي تريد دخول به',style: TextStyle(fontSize: 15,fontWeight:FontWeight.w500,color: Colors.grey[600]),textAlign: TextAlign.center,),
            ),

            SizedBox(height: 20,),

            Padding(
              padding: const EdgeInsets.only(left: 35,right: 35,),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Container(
                  height: 60,
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
                        });
                      },
                      items:options.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [


                              Text(value,textDirection: TextDirection.ltr),
                              SizedBox(width: 10,),
                              Icon(Icons.person_2_outlined,color:Color(0xff9BABB8)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30,),

            InkWell(
              onTap: (){
                if(selectedOption=='اختار شخص الذي تريد دخول به'){

                }else{
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                }

              },
              child: Padding(
                padding: const EdgeInsets.only(left: 30,right: 30),
                child: Container(
                  width:double.infinity,
                  height: 50,
                  child: Card(
                    margin: EdgeInsets.all(0),
                    elevation: 8,
                    color: Colors.greenAccent[700],
                    child: Center(
                        child: Text(
                          'استمر',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 17
                          ),
                        )),
                  ),
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}
