import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parentapp/Layout/HomeLayout/home.dart';
import 'package:parentapp/modules/Login/login.dart';
import 'package:parentapp/shared/remote/cachehelper.dart';
import 'localization/demo_localization.dart';
import 'localization/localization_constants.dart';
import 'modules/Pages/splashScreen.dart';
Future<void> backgroundMessageHandler(RemoteMessage message){
  if (message.notification!=null) {
    if(message.notification.title=='رسالة جديدة'){
      Fluttertoast.showToast(
          msg: "${message.notification.title}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          webShowClose:false,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }

    if(message.notification.title=='منشور جديدة'){
      Fluttertoast.showToast(
          msg: "${message.notification.title}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          webShowClose:false,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }
}

FirebaseMessaging messaging = FirebaseMessaging.instance;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Cachehelper.init();
  await Firebase.initializeApp();
  messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  String token = Cachehelper.getData(key: "token");
  Widget widget;
  if(token!= null) widget = HomeScreen(index: 0,);
  else widget = Login();

  runApp(MyApp(startWidget:widget,));
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale local) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setLocale(local);
  }

  final Widget startWidget;
  const MyApp({Key key,this.startWidget}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
      print(_locale);
    });
  }
  @override
  void didChangeDependencies() {
    getLocale().then((locale){
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: [
        Locale('en','US'),Locale('ar', 'EG')
      ],
      locale:_locale,
      localizationsDelegates: [
        DemoLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback:(deviceLocal, supportedLocales){
        if(deviceLocal!=null){
          for (var local in supportedLocales) {
            if (local.languageCode == deviceLocal.languageCode){
              return deviceLocal;
            }
          }
        }
        return supportedLocales.first;

      },
      title: 'Parents | Ecole Sofia Sahara',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home:SplashScreen(),
    );
  }
}

