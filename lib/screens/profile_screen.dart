import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat/auth/API.dart';
import 'package:wechat/auth/login_screen.dart';
import 'package:wechat/contant.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:image_picker/image_picker.dart';

import '../dialog.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser? user;

  const ProfileScreen({Key? key, this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextFormField nameC = TextFormField();
  TextFormField aboutC = TextFormField();
  final key = GlobalKey<FormState>();
  String? _img;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              CupertinoIcons.home,
            ),
          ),
          title: Text(
            'User Profile',
          ),
          actions: [
            IconButton(
              onPressed: () async {
                Dialogs.showProgresbar(context);
                await APIs.updateActiveStatus(false);
                await FirebaseAuth.instance.signOut().then((value) {

                  APIs.auth = FirebaseAuth.instance;

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LogInPage(),
                    ),
                  );
                });
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.only(bottom: 10.0),
        //   child: FloatingActionButton.extended(
        //     backgroundColor: primaryColor,
        //     onPressed: () async {
        //
        //     },
        //     label: Text('LogOut'),
        //     icon: Icon(
        //       Icons.logout,
        //     ),
        //   ),
        // ),
        body: Form(
          key: key,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Stack(
                    children: [
                      _img != null
                          ?
                          //local image
                          Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.height * .1),
                                child: Image.file(
                                  File(_img!),
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          :
                          //server image
                          Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.height * .1),
                                child: CachedNetworkImage(
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.fill,
                                  imageUrl: "${widget.user!.image}",
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      CircleAvatar(
                                    child: Icon(CupertinoIcons.person),
                                  ),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 5,
                        right: 75,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          child: Icon(
                            Icons.edit,
                            color: whiteColor,
                          ),
                          shape: CircleBorder(),
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    '${widget.user!.email}',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Required Field',
                    initialValue: widget.user!.name,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: primaryColor, width: 2)),
                      hintText: 'Your Name',
                      label: Text(
                        'Name',
                        style: TextStyle(color: primaryColor),
                      ),
                      prefixIconColor: primaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : 'Required Field',
                    initialValue: widget.user!.about,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide:
                              BorderSide(color: primaryColor, width: 2)),
                      hintText: 'About',
                      prefixIconColor: primaryColor,
                      label:
                          Text('About', style: TextStyle(color: primaryColor)),
                    ),
                  ),
                  SizedBox(
                    height: 180,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: StadiumBorder(),
                      minimumSize: Size(180, 50),
                    ),
                    onPressed: () {
                      if (key.currentState!.validate()) {
                        key.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnakcbar(
                              context, 'Profile Updated Successfully');
                        });
                      }
                    },
                    icon: Icon(Icons.edit),
                    label: Text('UPDATE'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //for picking profile pick
  void _showBottomSheet() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (_) {
          return ListView(
            padding: EdgeInsets.only(top: 15),
            shrinkWrap: true,
            children: [
              Text(
                'Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      fixedSize: Size(110, 110),
                      shape: CircleBorder(),
                    ),
                    onPressed: () async {
                      final ImagePicker _picker = ImagePicker();
                      // Pick an image
                      final XFile? image = await _picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 70);
                      if (image != null) {
                        setState(() {
                          _img = image.path;
                        });
                        //upload image
                        APIs.updateProfilePicture(File(_img!));
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/images/add_image.png'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      fixedSize: Size(110, 110),
                      shape: CircleBorder(),
                    ),
                    onPressed: () async {
                      final ImagePicker _picker = ImagePicker();
                      // Pick an image
                      final XFile? image = await _picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        setState(() {
                          _img = image.path;
                        });
                        //upload image
                        APIs.updateProfilePicture(File(_img!));
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset('assets/images/camera.png'),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          );
        });
  }

//pickimage

// Capture a photo
// final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
}
