import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flut/bloc/messaging/messaging_bloc.dart';
import 'package:flut/models/message.dart';
import 'package:flut/models/message_model.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MessageAudioRecorder extends StatefulWidget {
  final String convoId;
  const MessageAudioRecorder({required this.convoId});

  @override
  _MessageAudioRecorderState createState() => _MessageAudioRecorderState();
}

class _MessageAudioRecorderState extends State<MessageAudioRecorder> {
  bool _isRecording = false;
  Duration _recordDuration = Duration(seconds: 0);
  late DateTime _startTime;
  late DateTime _endTime;
  final record = FlutterSoundRecorder();
  late Timer _timer;

  @override
  void initState()  {
    super.initState();
    initRecorder();
  }

  void initRecorder() async {
    await record.openRecorder();
  }

  @override
  void dispose() {
    record.closeRecorder();
    super.dispose();
  }

  void _startRecording() async {
    final dir = Directory("/storage/emulated/0/Download/Freely");
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    await record.startRecorder(
      codec: Codec.aacMP4,
      toFile:
          "/storage/emulated/0/Download/Freely/${DateTime.now().millisecondsSinceEpoch}.aac",
    );
    setState(() {
      _isRecording = true;
      _startTime = DateTime.now();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _recordDuration = DateTime.now().difference(_startTime);
        });
      });
    });
  }

  void _stopRecording() async {
    try {
      final path = await record.stopRecorder();
      print(path);
      setState(() {
        _recordDuration = Duration(seconds: 0);
        _endTime = DateTime.now();
        _timer.cancel();
        _isRecording = false;
        //reset timer to 0
        // Here you can do something with the recorded audio
      });
      _sendAudio(path!);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("An error occurred while recording audio"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                )
              ],
            );
          });
    }
  }

  void _sendAudio(String path) {
    BlocProvider.of<MessagingBloc>(context).add(MessagingFileUpload(
        path,
        widget.convoId,
        RepositoryProvider.of<AuthRepo>(context).user_model!.id,
        MessageType.audio));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressDown: (_) {
        if ( !_isRecording)
          _startRecording();
      },
      onLongPressUp: () {
        if ( _isRecording)

        _stopRecording();
      },
      child: Container(
        width: 25,
        height: 25,
        alignment: Alignment.center,
        child: OverflowBox(
          maxWidth: 25,
          maxHeight: 100,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _isRecording
                  ? Positioned(
                      top: 0.0,
                      right: 0,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 2009),
                        opacity: _isRecording ? 1.0 : 0.0,
                        child: Container(
                          width: 50,
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              '${_recordDuration.inSeconds} s',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
              Positioned(
                top: 37,
                right: 0.5,
                child: SvgPicture.asset(
                  'assets/icons/microphone.svg',
                  color: _isRecording ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
