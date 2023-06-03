import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat/auth/API.dart';
import 'package:wechat/date_time_util.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/models/messege.dart';
import 'package:wechat/screens/chat_screen.dart';
import 'package:wechat/widget/profile_alert_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser? chatUser;

  ChatUserCard({Key? key, this.chatUser}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Messges? messges;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .04, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      // color: Colors.pink.withOpacity(0.4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                user: widget.chatUser,
              ),
            ),
          );
        },
        child: StreamBuilder(
            stream: APIs.getLastMessage(widget.chatUser!),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final _list =
                  data?.map((e) => Messges.fromJson(e.data())).toList() ?? [];

              if (_list.isNotEmpty) {
                messges = _list[0];
              }

              return ListTile(
                leading: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ProfileAlertDialog(chatUser: widget.chatUser!, ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.height * .10),
                    child: CachedNetworkImage(
                      height: 50,
                      width: 50,
                      imageUrl: "${widget.chatUser!.image}",
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
                title: Text('${widget.chatUser!.name}'),
                subtitle: Text(
                  '${messges != null ? messges!.type == Typee.image ? 'Image' : messges!.msg : widget.chatUser!.about}',
                  maxLines: 1,
                ),
                trailing: messges == null
                    ? null
                    : messges!.read!.isEmpty && messges!.fromId != APIs.user.uid
                        ? Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10)),
                          )
                        : Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: '${messges!.sent}'),
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
              );
            }),
      ),
    );
  }
}
