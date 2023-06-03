import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat/auth/API.dart';
import 'package:wechat/auth/login_screen.dart';
import 'package:wechat/contant.dart';
import 'package:wechat/date_time_util.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:image_picker/image_picker.dart';

import '../dialog.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser? user;

  const ViewProfileScreen({Key? key, this.user}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  TextFormField nameC = TextFormField();
  TextFormField aboutC = TextFormField();
  final key = GlobalKey<FormState>();
  String? _img;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Joind At :',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            Text(
              ' ${MyDateUtil.getLastMessageTime(
                context: context,
                time: '${widget.user!.createdAt}',
                showYear: true,
              )}',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              CupertinoIcons.back,
            ),
          ),
          title: Text(
            '${widget.user!.name}',
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height * .1,
                    ),
                    child: CachedNetworkImage(
                      height: 150,
                      width: 150,
                      fit: BoxFit.fill,
                      imageUrl: "${widget.user!.image}",
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  '${widget.user!.email}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'About:',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      ' ${widget.user!.about}',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 180,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
