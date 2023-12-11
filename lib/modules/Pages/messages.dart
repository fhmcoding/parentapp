import 'package:flutter/material.dart';
import 'package:parentapp/modules/Pages/receive_message.dart';
import 'package:parentapp/modules/Pages/reception.dart';


import '../../localization/demo_localization.dart';
import 'message_envoie.dart';

class Messangers extends StatefulWidget {
  List groups =[];
  Messangers({Key key,this.groups}) : super(key: key);

  @override
  State<Messangers> createState() => _MessangersState();
}

class _MessangersState extends State<Messangers> with SingleTickerProviderStateMixin{



  TabController tabcontroller;
  void initState() {
    tabcontroller  = TabController(length: 3, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        bottom: TabBar(
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.purple,
            labelColor:Colors.purple,
            controller: tabcontroller,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(DemoLocalization.of(context).getTranslatedValue('Create_Message'),style: TextStyle(
                        fontSize: 11
                    ),),
                  ],
                ),

              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(DemoLocalization.of(context).getTranslatedValue('Inbox'),style: TextStyle(
                        fontSize: 11
                    ),),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(DemoLocalization.of(context).getTranslatedValue('My_Messages'),style: TextStyle(
                        fontSize: 11
                    ),),
                  ],
                ),

              ),



            ]),
      ),
      body:TabBarView(
          controller:tabcontroller,
          children: [
            Message_envoie(),
            Reception(),
            Receive_message(),
          ]
      ),
    );
  }
}
