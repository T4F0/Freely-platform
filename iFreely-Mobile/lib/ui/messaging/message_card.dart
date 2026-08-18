import 'package:flut/consts/routes.dart';
import 'package:flut/models/conversation.dart';
import 'package:flut/models/message.dart';
import 'package:flut/ui/messaging/avatar.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  final Conversation conversation;
  // final Message lastMessage;
  const MessageCard({
    // required this.lastMessage,
    required this.conversation,
    super.key,
  });

  String _calcTime(DateTime? lastMessageTime) {
    if (lastMessageTime != null) {
      String lastMessageDiff = "";
      Duration difference = DateTime.now().difference(lastMessageTime);
      if (difference.inDays > 365) {
        lastMessageDiff = "${difference.inDays ~/ 365}y ago";
      } else if (difference.inDays > 30) {
        lastMessageDiff = "${difference.inDays ~/ 30}m ago";
      } else if (difference.inDays > 7) {
        lastMessageDiff = "${difference.inDays ~/ 7}w ago";
      } else if (difference.inDays > 0) {
        lastMessageDiff = "${difference.inDays}d ago";
      } else if (difference.inHours > 0) {
        lastMessageDiff = "${difference.inHours}h ago";
      } else if (difference.inMinutes > 0) {
        lastMessageDiff = "${difference.inMinutes} min ago";
      } else {
        lastMessageDiff = "Just now";
      }
      return lastMessageDiff;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacementNamed(context, Routes.chats_room,
            arguments: [conversation.id, conversation.otherUser]);
      },
      child: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.background),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                        height: 58,
                        width: 58,
                        child: Avatar(
                            image: "assets/Avatar.png",
                            active: conversation.active)),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        Text(
                          conversation.name!,
                          // "Baghdad Akram",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          conversation.lastMessage.characters.length >= 30
                              ? conversation.lastMessage.substring(0, 31) +
                                  " ..."
                              : conversation.lastMessage,
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        )
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _calcTime(conversation.lastMessageTime),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    (conversation.notification == 0 )
                        ? SizedBox(
                            height: 10,
                          )
                        : Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            child: Center(
                                child: Text(
                              conversation.notification.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            )),
                            width: 20,
                          ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5),
            Divider(),
          ],
        ),
      ),
    );
  }
}
