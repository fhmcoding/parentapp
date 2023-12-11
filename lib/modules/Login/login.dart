import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parentapp/shared/components/components.dart';
import '../../Layout/HomeLayout/home.dart';
import '../../localization/demo_localization.dart';
import '../../shared/components/constants.dart';
import '../../shared/remote/cachehelper.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';

bool isShow = true;
class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login>{
  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
  var PhoneController = TextEditingController();
  var PasswordController = TextEditingController();
  var fbm = FirebaseMessaging.instance;

  String fcmtoken='';
  bool isloading = true;



  Future login({payload})async{
    isloading = false;
    final response = await http.post(
      Uri.parse('${url}/auth/guardian'),
      body:jsonEncode(payload),
      headers:{'Content-Type':'application/json','Accept':'application/json',},
    ).then((value){
        if(value.statusCode==200){
          var data = json.decode(value.body);
              Cachehelper.sharedPreferences.setInt("id",data['user']['id']);
              if(data['user']['avatar']!=null){
                Cachehelper.sharedPreferences.setString("avatar",data['user']['avatar']);
              }
          if(data['user']['first_name'] != null){
            Cachehelper.sharedPreferences.setString("first_name",data['user']['first_name']);
          }
          if(data['user']['last_name']!= null){
            Cachehelper.sharedPreferences.setString("last_name",data['user']['last_name']);
          }
          if(data['user']['cin']!=null){
            Cachehelper.sharedPreferences.setString("user_cin",data['user']['cin']);
          }
          Cachehelper.sharedPreferences.setString("token",data['token']).then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen(index:0)));
          });
        }else{
          var data = json.decode(value.body);

          setState(() {
            print(data);
            Fluttertoast.showToast(
                msg: "${data['message']}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                webShowClose:false,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0
            );
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
  super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: fromkey,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children:[

                  Align(alignment:Alignment.topLeft,child:Text('Bienvenue à Sofia Ecole',style: TextStyle(
                    fontSize:17,
                    fontWeight: FontWeight.bold,color:Color(0xff511798)
                  ),)),

                  height(20),

                  Text(DemoLocalization.of(context).getTranslatedValue('Login'),
                      style:TextStyle(
                      fontSize:28,
                      fontWeight:FontWeight.bold
                  ),),

                  SizedBox(height: 20),

                  DefaultTextfiled(
                      controller: PhoneController,
                      keyboardType: TextInputType.emailAddress,
                      obscureText:false,
                      hintText:DemoLocalization.of(context).getTranslatedValue('National_ID'),
                      label:DemoLocalization.of(context).getTranslatedValue('National_ID'),
                      prefixIcon:Icons.person
                  ),

                  SizedBox(height:20),

                  DefaultTextfiled(
                      controller:PasswordController,
                      onTap:(){
                        setState((){
                          isShow =! isShow;
                        });
                      },
                      obscureText:isShow,
                      hintText:DemoLocalization.of(context).getTranslatedValue('Password'),
                      label:DemoLocalization.of(context).getTranslatedValue('Password'),
                      prefixIcon:Icons.lock_outline_rounded,
                      suffixIcon:isShow?Icons.visibility_off_outlined:Icons.visibility
                  ),

                  SizedBox(height:15),

                  GestureDetector(
                    onTap:()async{
                      if (fromkey.currentState.validate()) {
                      fromkey.currentState.save();
                      setState(() {
                        isloading = false;
                      });
                      try {
                        final authcredential = await FirebaseAuth.instance.signInAnonymously();
                        if (authcredential.user != null) {
                          fbm.getToken().then((token) {
                            printFullText(token.toString());
                            fcmtoken = token;
                            login(
                               payload:{
                                  "cin":"${PhoneController.text}",
                                  "password":"${PasswordController.text}",
                                  "firebase_token":token
                               });
                          });
                        }
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          isloading = true;
                        });
                        print("error is ${e.message}");
                      }
                    }
                    },
                    child:Container(
                      decoration:BoxDecoration(
                          borderRadius:BorderRadius.circular(5),
                          color:Color(0xff511798)
                      ),
                      child:Center(
                        child:isloading?Text(DemoLocalization.of(context).getTranslatedValue('Login'),
                          style:TextStyle(
                              color:Colors.white,
                              fontSize:20,
                              fontWeight:FontWeight.bold),
                        ):CircularProgressIndicator(
                          color:Colors.white,
                        ),
                      ),
                      height:55,
                      width:double.infinity,
                    ),
                  ),

                  SizedBox(height:5),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget DefaultTextfiled({bool obscureText,String hintText,String label,IconData prefixIcon,IconData suffixIcon,TextEditingController controller ,Function onTap,TextInputType keyboardType}){
    return TextFormField(
      keyboardType:keyboardType,
      obscureText: obscureText,
      controller:controller,
      style: TextStyle(color: Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${hintText} ${DemoLocalization.of(context).getTranslatedValue('Field_Cannot_Be_Empty')} ';
        }
        return null;
      },
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                width: 1,
                color: Colors.black,
              )),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                width: 1,
                color: Colors.black,
              )),
          hintText: hintText,

          label: Text(label),
          prefixIcon:prefixIcon!=null? Icon(prefixIcon):null,
          suffixIcon: suffixIcon!=null? GestureDetector(
              onTap:onTap,
              child: Icon(suffixIcon)):null,
          hintStyle: TextStyle(
            color: Color(0xFF7B919D),
          )),
    );
  }
}
