import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:wechat/auth/API.dart';
import 'package:wechat/contant.dart';
import 'package:wechat/date_time_util.dart';
import 'package:wechat/dialog.dart';
import 'package:wechat/models/messege.dart';
import 'package:wechat/widget/image_view.dart';

class MessgeCard extends StatefulWidget {
  final Messges messegs;

  const MessgeCard({Key? key, required this.messegs}) : super(key: key);

  @override
  State<MessgeCard> createState() => _MessgeCardState();
}

class _MessgeCardState extends State<MessgeCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.messegs.fromId;
    //
    return InkWell(
      onTap: () {
        if (widget.messegs.type == Typee.image) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageView(img: "${widget.messegs.msg}"),
            ),
          );
        }
      },
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _purpleMessege() : _orangeMessege(),
    );
  }

  Widget _orangeMessege() {
    //update read status yani blue tick ta ky pta lagy msg seen ho gya ky nai
    if (widget.messegs.read!.isEmpty) {
      APIs.updateMessageReadStatus(widget.messegs);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //body

        Flexible(
          child: Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.orange,
                width: 1,
              ),
              color: Colors.deepOrangeAccent.withOpacity(0.3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: widget.messegs.type == Typee.text
                ?
                //for text in chat
                Text(
                    '${widget.messegs.msg}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  )
                :
                //for image in chat
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      onTap: () {},
                      child: CachedNetworkImage(
                        height: 250,
                        width: 150,
                        fit: BoxFit.fill,
                        imageUrl: "${widget.messegs.msg}",
                        placeholder: (context, url) => Center(
                          child: Container(
                            width: 20,
                            height: 20,
                            child: LoadingIndicator(
                              indicatorType: Indicator.ballPulse,
                              colors: [
                                Colors.green,
                                primaryColor,
                                Colors.black
                              ],

                              /// Optional, The color collections
                              strokeWidth: 2,

                              /// Optional, The stroke of the line, only applicable to widget which contains line
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
          ),
        ),

        //double tick or msg time
        Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: '${widget.messegs.sent}'),
              style: TextStyle(fontSize: 13, color: Colors.black38),
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _purpleMessege() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //double tick or msg time

        Row(
          children: [
            SizedBox(
              width: 10,
            ),
            if (widget.messegs.read!.isNotEmpty)
              Icon(
                Icons.check_circle,
                color: Colors.deepPurple,
                size: 18,
              ),
            SizedBox(
              width: 4,
            ),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: '${widget.messegs.sent}'),
              style: TextStyle(fontSize: 13, color: Colors.black38),
            ),
          ],
        ),

        //body

        Flexible(
          child: Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.purple,
                width: 1,
              ),
              color: Colors.deepPurple.withOpacity(0.4),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  // topRight: Radius.circular(35),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18)),
            ),
            child: widget.messegs.type == Typee.text
                ?
                //for text in chat
                Text(
                    '${widget.messegs.msg}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  )
                :
                //for image in chat
                ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      onTap: (){},
                      child: CachedNetworkImage(
                        height: 250,
                        width: 150,
                        fit: BoxFit.fill,
                        imageUrl: "${widget.messegs.msg}",
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  //bottom sheet

  void _showBottomSheet(bool isMe) {
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
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * .015,
                    horizontal: MediaQuery.of(context).size.width * .4),
              ),
              widget.messegs.type == Typee.text
                  ? _OptionItem(
                      icon: Icon(
                        Icons.copy_all_rounded,
                        color: Colors.blue,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.messegs.msg))
                            .then(
                          (value) {
                            Navigator.pop(context);
                            Dialogs.showSnakcbar(context, 'Text Copied ');
                          },
                        );
                      })
                  : _OptionItem(
                      icon: Icon(
                        Icons.download_rounded,
                        color: Colors.blue,
                      ),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          // log('${widget.messegs.msg!}');
                          await GallerySaver.saveImage(
                            widget.messegs.msg!,
                            albumName: 'We Chat',
                          ).then((success) {
                            Navigator.pop(context);
                            if (success != null && success) {
                              Dialogs.showSnakcbar(
                                  context, 'Image Save to Gallery');
                            }
                          });
                        } catch (e) {
                          log('${e}');
                          Dialogs.showSnakcbar(
                              context, 'Error while Saving ${e}');
                        }
                      }),
              if (isMe)
                SizedBox(
                  height: 10,
                ),
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: MediaQuery.of(context).size.width * .04,
                  indent: MediaQuery.of(context).size.height * .04,
                ),
              if (isMe)
                SizedBox(
                  height: 10,
                ),
              if (isMe && widget.messegs.type == Typee.text)
                _OptionItem(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.blue,
                    ),
                    name: 'Edit Messege',
                    onTap: () {
                      Navigator.pop(context);
                      _showdialog();
                    }),
              // if (widget.messegs.type == Typee.text && isMe)
              SizedBox(
                height: 10,
              ),
              // if (widget.messegs.type == Typee.text && isMe)
              SizedBox(
                height: 10,
              ),
              if (isMe)
                _OptionItem(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    name: 'Delete Messege',
                    onTap: () async {
                      Navigator.pop(context);
                      await APIs.deleteMessage(widget.messegs).then((value) {
                        Dialogs.showSnakcbar(context, 'Deleted');
                      });
                    }),
              if (widget.messegs.type == Typee.text &&
                  widget.messegs.type == Typee.image &&
                  isMe)
                SizedBox(
                  height: 10,
                ),

              Divider(
                color: Colors.black54,
                endIndent: MediaQuery.of(context).size.width * .04,
                indent: MediaQuery.of(context).size.height * .04,
              ),

              SizedBox(
                height: 10,
              ),
              _OptionItem(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.blue,
                  ),
                  name:
                      'Sent At:  ${MyDateUtil.getMessageTime(context: context, time: widget.messegs.sent!)}',
                  onTap: () {}),
              SizedBox(
                height: 20,
              ),
              _OptionItem(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.green,
                  ),
                  name: widget.messegs.read!.isEmpty
                      ? 'Read At:  Not seen yet'
                      : 'Read At:  ${MyDateUtil.getMessageTime(context: context, time: widget.messegs!.read!)}',
                  onTap: () {}),
              SizedBox(
                height: 25,
              ),
            ],
          );
        });
  }

  void _showdialog() {
    String updateMsg = widget.messegs.msg!;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.message,
                    color: primaryColor,
                    size: 28,
                  ),
                  Text(' Update Messege'),
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => updateMsg = value,
                initialValue: updateMsg,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  label: Text('Update'),
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
                  onPressed: () {
                    Navigator.pop(context);
                    APIs.updateMessage(widget.messegs, updateMsg);
                  },
                  child: Text(
                    'Update',
                    style: TextStyle(color: primaryColor, fontSize: 18),
                  ),
                ),
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {Key? key, required this.icon, required this.name, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          children: [
            icon,
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                '  ${name}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
