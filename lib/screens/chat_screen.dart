import 'dart:io';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:wechat/contant.dart';
import 'package:wechat/date_time_util.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/models/messege.dart';
import 'package:wechat/screens/view_profile_screen.dart';
import 'package:wechat/widget/messege_card.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

import '../auth/API.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser? user;

  const ChatScreen({
    Key? key,
    this.user,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Messges? messges;
  List<Messges> _list = [];
  TextEditingController msg = TextEditingController();
  bool showEmoji = false;
  bool isUploading = false;
  String? _img;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (showEmoji) {
              setState(() {
                showEmoji = !showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent),
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AudioCallPage(
                            callingId: '000000',
                            userId: FirebaseAuth.instance.currentUser!.uid,
                            userName: FirebaseAuth
                                .instance.currentUser!.displayName
                                .toString(),
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.call),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
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
                  icon: Icon(Icons.videocam),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user!),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                          // return SizedBox();

                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            //
                            _list = data
                                    ?.map((e) => Messges.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  reverse: true,
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          .01),
                                  itemCount: _list.length,
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return MessgeCard(
                                      messegs: _list[index],
                                    );
                                  });
                            } else {
                              return Center(
                                child: Text(
                                  'Say Hii.. 👋',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                        }
                      }),
                ),

                //uploadig image

                if (isUploading)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Container(
                        width: 35,
                        height: 35,
                        child: LoadingIndicator(
                          indicatorType: Indicator.ballPulse,

                          /// Required, The loading type of the widget
                          colors: const [
                            Colors.green,
                            Colors.red,
                            Colors.black
                          ],

                          /// Optional, The color collections
                          strokeWidth: 2,

                          /// Optional, The stroke of the line, only applicable to widget which contains line
                        ),
                      ),
                    ),
                  ),
                chatInput(),
                if (showEmoji)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .35,
                    child: EmojiPicker(
                      textEditingController: msg,
                      // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                      config: Config(
                        backspaceColor: Colors.white,
                        columns: 8,
                        emojiSizeMax: 32 *
                            (Platform.isIOS
                                ? 1.30
                                : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProfileScreen(
                user: widget.user,
              ),
            ),
          );
        },
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user!),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    CupertinoIcons.back,
                    size: 22,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height * .1),
                  child: CachedNetworkImage(
                    height: 40,
                    width: 40,
                    fit: BoxFit.fill,
                    imageUrl: list.isNotEmpty
                        ? "${list[0].image}"
                        : "${widget.user!.image}",
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 3,
                                value: downloadProgress.progress)),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                SizedBox(
                  width: 7,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.isNotEmpty
                          ? '${list[0].name}'
                          : '${widget.user!.name}',
                      style: TextStyle(
                          color: whiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline!
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive!)
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user!.lastActive!),
                      style: TextStyle(
                        color: whiteColor.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ));
  }

  Widget chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        showEmoji = !showEmoji;
                      });
                    },
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                  Expanded(
                      child: TextFormField(
                    controller: msg,
                    keyboardType: TextInputType.multiline,
                    onTap: () {
                      if (showEmoji) {
                        setState(() {
                          showEmoji = !showEmoji;
                        });
                      }
                    },
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type Something...',
                      border: InputBorder.none,
                    ),
                  )),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker _picker = ImagePicker();
                      // Pick an image
                      final List<XFile?> images =
                          await _picker.pickMultiImage(imageQuality: 90);
                      for (var i in images) {
                        setState(() {
                          isUploading = true;
                        });
                        await APIs.sendChatImage(widget.user!, File(i!.path));
                        // Navigator.pop(context);
                        setState(() {
                          isUploading = false;
                        });
                      }

                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.image,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker _picker = ImagePicker();
                      // Pick an image
                      final XFile? image = await _picker.pickImage(
                          source: ImageSource.camera, imageQuality: 90);
                      if (image != null) {
                        // setState(() {
                        //   _img = image.path;
                        // });
                        //upload image
                        setState(() {
                          isUploading = true;
                        });
                        await APIs.sendChatImage(
                            widget.user!, File(image.path));
                        // Navigator.pop(context);
                        setState(() {
                          isUploading = false;
                        });
                      }
                    },
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
            minWidth: 0,
            color: primaryColor,
            shape: CircleBorder(),
            onPressed: () {
              if (msg.text.isNotEmpty) {
                if (_list.isEmpty) {
                  APIs.sendFirstMessage(widget.user!, msg.text, Typee.text);
                } else {
                  APIs.sendMessage(widget.user!, msg.text, Typee.text);
                }
                msg.text = '';
              }
            },
            child: Center(
              child: Icon(
                Icons.send,
                color: whiteColor,
                size: 18,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class VideoCallPage extends StatelessWidget {
  const VideoCallPage(
      {Key? key,
      required this.callingId,
      required this.userId,
      required this.userName})
      : super(key: key);
  final String callingId;
  final String userId;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: ZegoUIKitPrebuiltCall (
          appID: 194346086,
          appSign: '0d00795e566604d6c7834ea5ef8f85a031a7d3789e09ac2473b470bab755b3a8',
          userID: userId,
          userName: userName,
          callID: callingId,
          // Modify your custom configurations here.
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            ..layout = ZegoLayout.pictureInPicture(
              isSmallViewDraggable: true,
              switchLargeOrSmallViewByClick: true,
            ),
        ),
        // ZegoUIKitPrebuiltVideoConference(
        //   appID: 194346086,
        //   // Fill in the appID that you get from ZEGOCLOUD Admin Console.
        //   appSign:
        //       '0d00795e566604d6c7834ea5ef8f85a031a7d3789e09ac2473b470bab755b3a8',
        //   // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
        //   userID: userId,
        //   userName: userName,
        //   conferenceID: callingId,
        //   config: ZegoUIKitPrebuiltVideoConferenceConfig(),
        // ),
      ),
    );
  }
}

// AudioCallPage
class AudioCallPage extends StatelessWidget {
  const AudioCallPage(
      {Key? key,
      required this.callingId,
      required this.userId,
      required this.userName})
      : super(key: key);
  final String callingId;
  final String userId;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: ZegoUIKitPrebuiltCall(
            appID: 194346086,
            // Fill in the appID that you get from ZEGOCLOUD Admin Console.
            appSign:
                '0d00795e566604d6c7834ea5ef8f85a031a7d3789e09ac2473b470bab755b3a8',
            // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
            userID: userId,
            userName: userName,
            callID: callingId,
            // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
            // ..onOnlySelfInRoom = (context) {
            //   Navigator.of(context).pop();
            // },
            // (context) {
            //     Navigator.pop(context);
            //   },
            // ..onOnlySelfInRoom = () => Navigator.pop(),
            ),
      ),
    );
  }
}
