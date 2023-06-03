import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:wechat/auth/API.dart';
import 'package:wechat/dialog.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/screens/profile_screen.dart';
import 'package:wechat/widget/chat_user_card.dart';

import '../../contant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //for storing user data
  List<ChatUser> list = [];

  //for storing search item
  final List<ChatUser> _searchList = [];

  //for storing search status
  bool isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();

    //fot user status active or not
    // API.UpdateActiveStatus(true);

    //active user status according to life cycle of app

    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) APIs.updateActiveStatus(true);
        if (message.toString().contains('pause')) APIs.updateActiveStatus(false);
        if (message.toString().contains('close')) APIs.updateActiveStatus(false);
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (isSearching) {
            setState(() {
              isSearching = !isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(
                      user: APIs.me,
                    ),
                  ),
                );
              },
              icon: Icon(
                CupertinoIcons.person,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isSearching = !isSearching;
                  });
                },
                icon: Icon(
                  isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : CupertinoIcons.search,
                ),
              ),
            ],
            title: isSearching
                ? TextFormField(
                    onChanged: (val) {
                      //search logic
                      _searchList.clear();
                      for (var i in list) {
                        if (i.name!.toLowerCase().contains(val.toLowerCase()) ||
                            i.email!
                                .toLowerCase()
                                .contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        ;
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                    style: TextStyle(
                        color: whiteColor, fontSize: 16, letterSpacing: 1),
                    cursorColor: whiteColor,
                    autofocus: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search People',
                        hintStyle: TextStyle(color: whiteColor, fontSize: 16)),
                  )
                : Text(
                    'گپshup',
              style: TextStyle(
                fontSize: 20
              ),
                  ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () async {
                _addChatUser();
                // await FirebaseAuth.instance.signOut();
              },
              child: Icon(
                Icons.add_comment_outlined,
              ),
            ),
          ),
          body: StreamBuilder(
              stream: APIs.getMyUsersId(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:

                  return Center(
                    child: Container(
                      width: 80,
                      height: 50,
                      child: LoadingIndicator(
                        indicatorType: Indicator.ballPulse,

                        /// Required, The loading type of the widget
                        colors:  [
                          Colors.green,
                          primaryColor,
                          Colors.black
                        ],
                        strokeWidth: 2,

                      ),
                    ),
                  );

                  case ConnectionState.active:
                  case ConnectionState.done:

                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                      snapshot.data?.docs.map((e) => e.id).toList() ?? [],
                    ),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:

                          //data is loaded

                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;

                          list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                              [];

                          if (list.isNotEmpty) {
                            return ListView.builder(
                                padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height *
                                        .01),
                                itemCount: isSearching
                                    ? _searchList.length
                                    : list.length,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                    chatUser: isSearching
                                        ? _searchList[index]
                                        : list[index],
                                  );
                                });
                          } else {
                            return Center(
                              child: Text('No User found... 🙂',style: TextStyle(fontSize: 20,),),
                            );
                          }
                      }
                    },
                  );

                }
              }),
        ),
      ),
    );
  }

  void _addChatUser() {
    String name = '';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.person_add_alt,
                    color: primaryColor,
                    size: 28,
                  ),
                  Text(' Add User'),
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => name = value,
                // initialValue: updateMsg,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  label: Text('Add User'),
                  hintText: 'Name',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black38, fontSize: 18),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (name.isNotEmpty) {
                      await APIs.addChatUser(name).then((value) {
                        if (!value) {
                          Dialogs.showSnakcbar(
                              context, 'User does not Exists..!');
                        }
                      });
                    }
                  },
                  child: Text(
                    'Add User',
                    style: TextStyle(color: primaryColor, fontSize: 18),
                  ),
                ),
              ],
            ));
  }
}
