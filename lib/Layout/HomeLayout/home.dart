import 'package:flutter/material.dart';
import 'package:parentapp/modules/Login/login.dart';
import 'package:parentapp/shared/components/components.dart';
import 'package:restart_app/restart_app.dart';

import '../../localization/demo_localization.dart';
import '../../localization/localization_constants.dart';
import '../../main.dart';
import '../../module/language.dart';
import '../../modules/Pages/devoirs.dart';
import '../../modules/Pages/extra_activties.dart';
import '../../modules/Pages/absences.dart';
import '../../modules/Pages/activities.dart';
import '../../modules/Pages/classes.dart';
import '../../modules/Pages/invoices.dart';
import '../../modules/Pages/messages.dart';
import '../../modules/Pages/points.dart';
import '../../modules/Pages/policy_page.dart';
import '../../modules/Pages/profile.dart';
import '../../modules/Pages/statsique_notes.dart';
import '../../modules/Pages/students.dart';
import '../../shared/remote/cachehelper.dart';

class HomeScreen extends StatefulWidget {
    int index = 0;
   HomeScreen({Key key,this.index}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String firstname = Cachehelper.getData(key: "first_name");
  String lastname = Cachehelper.getData(key: "last_name");
  String cin = Cachehelper.getData(key: "user_cin");
  String avatar = Cachehelper.getData(key: "avatar");
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void _openDrawer() {
    _scaffoldKey.currentState.openDrawer();
  }
  int  SelectedIndex = 0;

  List<String> titlescreens;

  String selectelang;
  String language = Cachehelper.getData(key: "langugeCode");
  void _changeLanguge(Language lang) async{
    Locale _temp = await setLocale(lang.languageCode);
    MyApp.setLocale(context, _temp);
    setState(() {

    });
  }

@override
  void initState() {
   selectelang =language=="ar"?'تغيير لغة':"Changer de langue";
    SelectedIndex = widget.index;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    titlescreens = [
      DemoLocalization.of(context).getTranslatedValue('Activities'),
      DemoLocalization.of(context).getTranslatedValue('Devoir'),
      DemoLocalization.of(context).getTranslatedValue('Annual_Program'),
      DemoLocalization.of(context).getTranslatedValue('Time_Slots'),
      DemoLocalization.of(context).getTranslatedValue('Student_Absence'),
      DemoLocalization.of(context).getTranslatedValue('Student_Points'),
      DemoLocalization.of(context).getTranslatedValue('Student_Report'),
      DemoLocalization.of(context).getTranslatedValue('Messages'),
      DemoLocalization.of(context).getTranslatedValue('My_Account'),
      DemoLocalization.of(context).getTranslatedValue('Student_List'),
      DemoLocalization.of(context).getTranslatedValue('Factours'),
      DemoLocalization.of(context).getTranslatedValue('loi'),
      language=="ar"?'تغيير لغة':"Changer de langue",
    ];
    List<Widget>screens=[

      Activites(),
      Devoirs(),
      ExtrActivties(),
      Classes(),
      Absences(),
      Points(),
      StastiqueNotes(),
      Messangers(),
      Profile(),
      Students(),
      Invoives(),
      PolicyPage(),
    ];

    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(
         elevation: 0,
         centerTitle: true,
         backgroundColor: Colors.white,
         leading: GestureDetector(
             onTap: (){
               _openDrawer();
             },
             child: Icon(Icons.menu,color: Colors.black)),
         title: Text(titlescreens[SelectedIndex],style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500)),
        ),
        drawer: Drawer(
          elevation: 10,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff511798),Colors.deepPurple],
                begin: Alignment.topCenter,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple,Colors.deepPurple],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  currentAccountPicture:avatar!=null?CircleAvatar(
                    backgroundImage:NetworkImage("${avatar}"),
                  ):height(0),
                  accountName:Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      firstname!=null?Text('${firstname}',style: TextStyle(
                          fontWeight: FontWeight.w500
                      ),):height(0),
                      firstname==null || lastname==null?width(0):width(5),
                      lastname!=null?Text('${lastname}',style: TextStyle(
                          fontWeight: FontWeight.w500
                      ),):height(0),
                    ],
                  ),

                  accountEmail:cin!=null?Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${cin}',style:TextStyle(
                      fontWeight:FontWeight.w400,
                        fontSize:13,color:Colors.grey[100]
                      )),
                      Padding(
                        padding: const EdgeInsets.only(right: 10,left: 10),
                        child: GestureDetector(
                          onTap: (){
                            Cachehelper.removeData(key: "token").then((value){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
                            });
                          },
                          child: Row(
                            children: [
                              Icon(Icons.logout,color: Colors.white,size: 21),
                              width(8),
                              Text(language=="ar"?'تسجيل الخروج':"Déconnexion",style: TextStyle(fontSize: 13.5),)
                            ],
                          ),
                        ),
                      )
                    ],
                  ):height(0)),

                buildPage(
                  icon: Icons.local_activity_outlined,
                  title:DemoLocalization.of(context).getTranslatedValue('Activities'),
                  ontap: (){
                    Navigator.pop(context);
                    setState(() {
                      SelectedIndex = 0;
                    });
                  }
                ),
                buildPage(
                    icon: Icons.cabin_rounded,
                    title:DemoLocalization.of(context).getTranslatedValue('Devoir'),
                    ontap: (){
                      Navigator.pop(context);
                      setState(() {
                        SelectedIndex = 1;
                      });
                    }
                ),
                buildPage(
                    icon: Icons.local_activity_outlined,
                    title:DemoLocalization.of(context).getTranslatedValue('Annual_Program'),
                    ontap: (){
                      Navigator.pop(context);
                      setState(() {
                        SelectedIndex = 2;
                      });
                    }
                ),
                buildPage(
                    icon: Icons.access_time,
                    title:DemoLocalization.of(context).getTranslatedValue('Time_Slots'),
                    ontap: (){
                      Navigator.pop(context);
                      setState(() {
                        SelectedIndex = 3;
                      });
                    }
                ),
                buildPage(
                    icon: Icons.message_outlined,
                    title:DemoLocalization.of(context).getTranslatedValue('Student_Absence'),
                    ontap: (){
                      Navigator.pop(context);
                      setState(() {
                        SelectedIndex = 4;
                      });
                    }
                ),
                buildPage(
                    icon: Icons.timeline,
                    title:DemoLocalization.of(context).getTranslatedValue('Student_Points'),
                    ontap: (){
                      Navigator.pop(context);
                      setState(() {
                        SelectedIndex = 5;
                      });
                    }
                ),
                buildPage(
                    icon: Icons.timeline,
                    title:DemoLocalization.of(context).getTranslatedValue('Student_Report'),
                    ontap: (){
                      Navigator.pop(context);
                      setState(() {
                        SelectedIndex = 6;
                      });
                    }
                ),
                buildPage(
                    icon: Icons.message_outlined,
                    title:DemoLocalization.of(context).getTranslatedValue('Messages'),
                    ontap: (){
                      Navigator.pop(context);
                      setState(() {
                        SelectedIndex = 7;
                      });
                    }
                ),
                buildPage(
                    icon: Icons.person_2_outlined,
                    title:DemoLocalization.of(context).getTranslatedValue('My_Account'),
                    ontap: (){
                      Navigator.pop(context);
                      setState(() {
                        SelectedIndex = 8;
                      });
                    }
                ),
                buildPage(
                    icon: Icons.groups,
                    title:DemoLocalization.of(context).getTranslatedValue('Student_List'),
                    ontap: (){
                      Navigator.pop(context);
                      setState(() {
                        SelectedIndex = 9;
                      });
                    }
                ),
                buildPage(
                    icon: Icons.inventory_outlined,
                    title:DemoLocalization.of(context).getTranslatedValue('Factours'),
                    ontap: (){
                      Navigator.pop(context);
                      setState(() {
                        SelectedIndex = 10;
                      });
                    }
                ),
                buildPage(
                    icon: Icons.balance_outlined,
                    title:DemoLocalization.of(context).getTranslatedValue('loi'),
                    ontap: (){
                      Navigator.pop(context);
                      setState(() {
                        SelectedIndex = 11;
                      });
                    }
                ),
                  

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color:Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15,right: 5,left: 0),
                                child: Icon(
                                  Icons.language,
                                  color:Colors.white,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: Container(
                                  height: 30,
                                  width: 2,
                                  color:Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 5, top: 5, right: 30),
                            child: DropdownButton(
                              onChanged: (language) async {
                                await _changeLanguge(language);
                                setState(() {
                                  Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                  builder: (context) => HomeScreen(index:0)),
                                  (route) => false);
                                });
                              },

                              icon:Padding(
                                padding:
                                const EdgeInsets.only(top: 0, right: 0, left: 0),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                ),
                              ),
                              underline: SizedBox(),
                              isExpanded: true,
                              hint: Padding(
                                padding: const EdgeInsets.only(right: 30, top: 0,left: 50),
                                child:Text(
                                  "${selectelang}",
                                  style: TextStyle(color: Colors.white,fontSize: 13.5),
                                ),
                              ),
                              items: Language.languageList()
                                  .map<DropdownMenuItem<Language>>((lang){
                                    return DropdownMenuItem(
                                      value:lang,child:Text(lang.name),
                                    );
                                  }
                              ).toList(),
                            ),
                          )
                        ],
                      )),
                ),


              ],
            ),
          ),
        ),
        backgroundColor:Colors.white,
        body:screens[SelectedIndex]
    );
  }
}
Widget buildPage({IconData icon,title,Function ontap}){
  return ListTile(
    leading: Icon(icon,color: Colors.white),
    title: Text(title,style: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white
    )),
    onTap:ontap
  );
}
