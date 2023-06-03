import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/screens/view_profile_screen.dart';

import '../screens/chat_screen.dart';

class ProfileAlertDialog extends StatefulWidget {
  final ChatUser chatUser;

  ProfileAlertDialog({required this.chatUser});

  @override
  State<ProfileAlertDialog> createState() => _ProfileAlertDialogState();
}

class _ProfileAlertDialogState extends State<ProfileAlertDialog> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: SizedBox(
        // width: size.width * .09,
        height: size.height * .35,
        child: Stack(
          children: [

            //for image

            Positioned(
              left: size.width * .2,
              top: size.height * .075,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.height * .1),
                child: CachedNetworkImage(
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                  imageUrl: "${widget.chatUser.image}",
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),

            //for bottom row.. call (AUDIO < VIDEO) button
            Positioned(
              top: 210,
              left: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            user: widget.chatUser,
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.message,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AudioCallPage(
                            callingId: '111222',
                            userId: FirebaseAuth.instance.currentUser!.uid,
                            userName: FirebaseAuth
                                .instance.currentUser!.displayName
                                .toString(),
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.call,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoCallPage(
                            callingId: '111222',
                            userId: FirebaseAuth.instance.currentUser!.uid,
                            userName: FirebaseAuth
                                .instance.currentUser!.displayName
                                .toString(),
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.videocam,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            //for chat user name

            Positioned(
              left: size.width * .04,
              top: size.height * .02,
              width: size.width * .55,
              child: Text(
                '${widget.chatUser.name}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            //for information icon

            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewProfileScreen(
                                user: widget.chatUser,
                              )));
                },
                icon: Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
