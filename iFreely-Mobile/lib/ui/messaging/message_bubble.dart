import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flut/bloc/messaging/messaging_bloc.dart';
import 'package:flut/consts/server.dart';
import 'package:flut/models/message.dart';
import 'package:flut/models/message_model.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flut/ui/messaging/audio_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:unicons/unicons.dart';
import 'package:voice_message_package/voice_message_package.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({
    super.key,
    required this.message,
    required this.active,
    required this.isFirst,
  });
  final Message message;
  final bool active;
  final bool isFirst;
  late String padding = (message.message.characters.length <= 10)
      ? " " * (12 - 2 * (message.isSender ? 0 : 1))
      : "";


  Future<void> _downloadFile(
      String fileUrl, BuildContext context, String fileName) async {
    print("file");
    final savedDir = Directory('/storage/emulated/0/Download/Freely');
    if (!savedDir.existsSync()) {
      savedDir.createSync(recursive: true);
    }
    try {
      await FlutterDownloader.enqueue(
          url: fileUrl,
          savedDir: savedDir.path,
          fileName: fileName,
          showNotification: true,
          openFileFromNotification: true);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("An error occured while downloading the file"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK"))
              ],
            );
          });
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    message.time = DateTime.parse(message.time.toString()).toLocal();
    String time = (message.time.hour > 12
            ? (message.time.hour < 10
                ? "0" + (message.time.hour - 12).toString()
                : (message.time.hour - 12).toString())
            : message.time.hour == 0
                ? "12"
                : (message.time.hour < 10
                    ? "0" + (message.time.hour).toString()
                    : (message.time.hour).toString())) +
        ":" +
        (message.time.minute < 10
            ? "0" + message.time.minute.toString()
            : message.time.minute.toString()) +
        " " +
        (message.time.hour > 12 ? "PM" : "AM");
    if (message.status == Status.sent && !message.isSender) {
      BlocProvider.of<MessagingBloc>(context).add(MessagingReadConvo(
          BlocProvider.of<MessagingBloc>(context).state.conversation.id,
          RepositoryProvider.of<AuthRepo>(context).user_model!.id));
    }

    return Padding(
      padding: isFirst
          ? EdgeInsets.only(top: 20, left: 10, right: 10)
          : EdgeInsets.only(top: 2, left: 10, right: 10),
      child: Row(
        mainAxisAlignment:
            message.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          message.isSender
              ? SizedBox()
              : (isFirst)
                  ? Stack(
                      children: [
                        Image(
                          image: AssetImage("assets/Avatar.png"),
                          width: 35,
                        ),
                        Visibility(
                          visible: active,
                          child: Positioned(
                            top: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: Color(0xFF2BEF83),
                                  borderRadius: BorderRadius.circular(100)),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: 35,
                    ),
          SizedBox(
            width: 10,
          ),
          Container(
            alignment: Alignment.topRight,
            decoration: BoxDecoration(
                color: message.isSender
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topLeft: message.isSender
                      ? Radius.circular(15)
                      : Radius.circular(0),
                  topRight: message.isSender
                      ? Radius.circular(0)
                      : Radius.circular(15),
                )),
            child: Stack(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (message.type == MessageType.text)
                  _text(context)
                else if (message.type == MessageType.image)
                  _photo(context)
                else if (message.type == MessageType.audio)
                  _audio(context)
                else
                  _file(context),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: message.type == MessageType.image
                            ? Colors.black.withOpacity(0.5)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(100)),
                    margin: EdgeInsets.only(
                        right: 6,
                        bottom: message.type == MessageType.text ? 2 : 5,
                        left: 5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          time,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              color: message.isSender ||
                                      (message.type == MessageType.image)
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 7),
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: message.isSender
                                ? (message.status == Status.seen)
                                    ? SizedBox(
                                        child: Stack(
                                          children: [
                                            Icon(
                                              UniconsLine.check,
                                              size: 10,
                                              color: Colors.white,
                                            ),
                                            Positioned(
                                              left: 2,
                                              child: Icon(
                                                UniconsLine.check,
                                                size: 10,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : (message.status == Status.sent)
                                        ? Icon(
                                            UniconsLine.check,
                                            size: 10,
                                            color: Colors.white,
                                          )
                                        : Icon(
                                            UniconsLine.check,
                                            size: 10,
                                            color: Colors.grey[400],
                                          )
                                : SizedBox())
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photo(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
        minWidth: 50,
      ),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: message.isSender
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(15)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: CachedNetworkImage(
            cacheKey: message.message,
            imageUrl: message.message,
            // imageUrl: "https://picsum.photos/200",
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child:
                    CircularProgressIndicator(value: downloadProgress.progress),
              ),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
    );
  }

// change this stupid

  Widget _audio(BuildContext context) {
    return AudioMessage(
      url: message.message,
      isMe: message.isSender,
    );
  }

  Widget _file(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("as");
        _downloadFile(message.message, context, message.message.split("%20%20")[1].split("?alt")[0]);
      },
      child: ConstrainedBox(
          constraints: BoxConstraints(
              // maxWidth: MediaQuery.of(context).size.width * 0.7,
              // minWidth: message.isSender ? 70 : 50,
              ),
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(8.0, 8.0,16,8),
            child: Container(
                child: Row(children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Color(0x50000000)),
                child: Icon(
                  Icons.file_open,
                  color: message.isSender ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(width: 10),
              Text(
                "${message.message.split("%20%20")[1].split("?alt")[0].substring(0, min(25, message.message.split("%20%20")[1].split("?alt")[0].length)) + (message.message.split("%20%20")[1].split("?alt")[0].length > 25 ? "..." : "")}",
                style: TextStyle(
                    color: message.isSender ? Colors.white : Colors.black),
              )
            ])),
          )),
    );
  }

  Widget _text(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
        minWidth: message.isSender ? 70 : 50,
      ),
      child: Container(
        margin: EdgeInsets.only(
            left: 10,
            right: 10,
            top: 5,
            bottom: message.message.characters.length <= 10 ? 5 : 15),
        child: Text(
          message.message + padding,
          style: TextStyle(
            color: message.isSender ? Colors.white : Colors.black,
            fontSize: 12,
          ),

          // softWrap: true,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}
