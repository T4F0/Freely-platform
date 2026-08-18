import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flut/bloc/messaging/conversation_bloc.dart';
import 'package:flut/bloc/messaging/messaging_bloc.dart';
import 'package:flut/consts/routes.dart';
import 'package:flut/consts/server.dart';
import 'package:flut/models/message.dart';
import 'package:flut/models/message_model.dart';
import 'package:flut/models/user_model.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flut/repos/messaging_repo.dart';
import 'package:flut/ui/messaging/audio_recorder.dart';
import 'package:flut/ui/messaging/message_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:unicons/unicons.dart';

class ChatRoom extends StatefulWidget {
  final String id;
  final String otherUserId;
  const ChatRoom({super.key, required this.id, required this.otherUserId});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  late final MessagingBloc messagingBloc;

  bool _iAmTyping = false;

  TextEditingController _inputController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  String recipient = "Baghdad Akram";
  String userId = "";

  Socket ws = Socket();

  void gotoProfile() {
    Navigator.pushNamed(
      context,
      Routes.profile_page,
      arguments: [widget.otherUserId],
    );
  }

  @override
  void initState() {
    super.initState();
    userId = RepositoryProvider.of<AuthRepo>(context).user_model!.id;
    _scrollController.addListener(_onScroll);
    messagingBloc = MessagingBloc(context.read<MessagingRepo>());
    if (messagingBloc.state.conversation.active) {
      messagingBloc.add(MessagingUserIsActive());
    } else {
      messagingBloc.add(MessagingUserIsOffline());
    }
    _getConvo();

    RepositoryProvider.of<MessagingRepo>(context).ws.io.emit("subscribe", {
      "room": widget.id,
      "otherUserId": widget.otherUserId,
    });
    RepositoryProvider.of<MessagingRepo>(context).ws.io.on("new message",
        (data) {
      print("new message");
      if (data["message"]["postedByUser"]["_id"] == userId) return;
      data["message"]["_id"] = data["message"]["postId"];

      messagingBloc.add(MessagingReceiveMessage(
        data["message"],
        userId,
        data["message"]["chatRoomId"],
      ));
    });
    RepositoryProvider.of<MessagingRepo>(context).ws.io.on("read", (data) {
      print("read");
      _getConvo();
    });
    RepositoryProvider.of<MessagingRepo>(context).ws.io.on("typing", (data) {
      print("typing");
      if (data["otherUserId"] != userId) {
        print("no");
        return;
      }
      messagingBloc.add(MessagingUserIsTyping());
    });
    RepositoryProvider.of<MessagingRepo>(context).ws.io.on("stop typing",
        (data) {
      if (messagingBloc.state.conversation.active) {
        messagingBloc.add(MessagingUserIsActive());
      } else {
        messagingBloc.add(MessagingUserIsOffline());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    messagingBloc.close();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      messagingBloc.add(MessagingGetConvo(
          widget.id, userId, messagingBloc.state.messages.length ~/ 50, 50));
    }
  }


  Future<void> _downloadImage(String imageUrl, BuildContext context) async {
    final savedDir = Directory('/storage/emulated/0/Download/Freely');
    if (!savedDir.existsSync()) {
      savedDir.createSync(recursive: true);
    }
    try {
      await FlutterDownloader.enqueue(
          url: imageUrl,
          savedDir: savedDir.path,
          fileName: 'message_${DateTime.now().millisecondsSinceEpoch}.jpg',
          showNotification: true,
          openFileFromNotification: true);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("An error occured while downloading the image"),
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

  void _sendTextMessage(String message) {
    message = message.trim();
    if (message.isEmpty) return;
    messagingBloc.add(MessagingSendMessage(
        widget.id,
        Message(
            message: message,
            type: MessageType.text,
            author: userId,
            time: DateTime.now(),
            isSender: true,
            status: Status.sending)));
    _inputController.clear();
    setState(() {
      _iAmTyping = false;
    });
  }

  void _getConvo() {
    messagingBloc.add(MessagingGetConvo(widget.id, userId, 0, 50));
  }

  void _sendImageMessage() async {
    print("sa");
    ImagePicker picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      print(pickedFile.path);
      messagingBloc.add(MessagingFileUpload(
          pickedFile.path, widget.id, userId, MessageType.image));
    } catch (e) {
      print(e);
    }
  }

  void _sendFileMessage() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: false);
      if (result != null) {
        final path = result.files[0].path;
        print(path);
        messagingBloc.add(
            MessagingFileUpload(path!, widget.id, userId, MessageType.file));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: messagingBloc,
      child: BlocConsumer<MessagingBloc, MessagingState>(
        listener: (context, state) {
          if (state.error == MessagingError.network) {
            messagingBloc.add(MessagingNetworkError());
            _getConvo();
          } else if (state.error == MessagingError.none) {
            // if (state.conversation.active) {
            //   messagingBloc.add(MessagingUserIsActive());
            // } else {
            //   messagingBloc.add(MessagingUserIsOffline());
            // }
          }
        },
        builder: (context, state) {
          return Scaffold(
              appBar: _appBar(context, state.userStatus),
              bottomNavigationBar: _input(context),
              body: PopScope(
                canPop: false,
                child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    cacheExtent: 200,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      index = state.messages.length - index - 1;

                      return GestureDetector(
                        key: ValueKey(state.messages[index].id),
                        onTap: () {
                          print(RepositoryProvider.of<AuthRepo>(context)
                              .user_model!
                              .id);
                          if (state.messages[index].type == MessageType.image) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Stack(
                                    children: [
                                      PhotoView(
                                        imageProvider: NetworkImage(
                                            state.messages[index].message),
                                        // ... (PhotoView options)
                                      ),
                                      Positioned(
                                        bottom: 10.0,
                                        right: 10.0,
                                        child: FloatingActionButton(
                                          mini: true,
                                          onPressed: () {
                                            _downloadImage(
                                                state.messages[index].message,
                                                context);
                                          },
                                          child: const Icon(Icons.download),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          }
                        },
                        child: Column(
                          children: [
                            index == 0 && state.reachedEnd
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child:
                                          Text("Reached end of conversation"),
                                    ),
                                  )
                                : index == 0 &&
                                        !state.reachedEnd &&
                                        state.status == MessagingStatus.loading
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : SizedBox(),
                            MessageBubble(
                              message: state.messages[index],
                              active: messagingBloc.state.conversation.active,
                              isFirst: (index == 0) ||
                                  state.messages[index].isSender !=
                                      state.messages[index - 1].isSender,
                            ),
                          ],
                        ),
                      );
                    }),
              ));
        },
      ),
    );
  }

  Widget _input(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.25,
        ),
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _sendFileMessage,
                        child: SvgPicture.asset(
                          "assets/icons/clip.svg",
                          width: 25,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: _inputController,
                          onChanged: (value) {
                            if (value.trim().isNotEmpty) {
                              RepositoryProvider.of<MessagingRepo>(context)
                                  .ws
                                  .io
                                  .emit("typing", {
                                "room": widget.id,
                                "otherUserId": widget.otherUserId,
                              });
                              setState(() {
                                _iAmTyping = true;
                              });
                            } else {
                              RepositoryProvider.of<MessagingRepo>(context)
                                  .ws
                                  .io
                                  .emit("stop typing", {
                                "room": widget.id,
                                "otherUserId": widget.otherUserId,
                              });
                              setState(() {
                                _iAmTyping = false;
                              });
                            }
                          },
                          padding: EdgeInsets.all(10),
                          style: TextStyle(fontSize: 12),
                          expands: true,
                          placeholder: "Write your message ",
                          maxLines: null,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Visibility(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: InkWell(
                            onTap: () =>
                                _sendTextMessage(_inputController.text),
                            child: SvgPicture.asset("assets/icons/send.svg",
                                width: 20,
                                colorFilter: ColorFilter.mode(
                                    Theme.of(context).primaryColor,
                                    BlendMode.srcIn)),
                          ),
                        ),
                        visible: _iAmTyping,
                      )
                    ],
                  ),
                ),
                Visibility(
                  visible: !_iAmTyping,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: _sendImageMessage,
                          child: SvgPicture.asset(
                            "assets/icons/camera.svg",
                            width: 25,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        MessageAudioRecorder(
                          convoId: widget.id,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context, UserStatus status) {
    print(messagingBloc.state.userStatus);
    return AppBar(
      leadingWidth: 95,
      leading: Row(
        children: [
          SizedBox(
            width: 15.0,
          ),
          SizedBox(
            width: 25,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  context.read<AuthRepo>().user_model!.role == CLIENT
                      ? Routes.client_main_page
                      : Routes.freelancer_main_page,
                );
              },
              child:
                  Text("<", style: TextStyle(fontSize: 20, color: Colors.grey)),
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Stack(
            children: [
              GestureDetector(
                onTap: gotoProfile,
                child: Image(
                  image: AssetImage("assets/Avatar.png"),
                  width: 40,
                ),
              ),
              Visibility(
                visible: messagingBloc.state.conversation.active,
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
        ],
      ),
      surfaceTintColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            messagingBloc.state.conversation.name!,
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            status == UserStatus.active
                ? "Active"
                : status == UserStatus.offline
                    ? "Offline"
                    : "Typing...",
            style: TextStyle(fontSize: 10, color: Colors.grey),
          )
        ],
      ),
    );
  }
}
