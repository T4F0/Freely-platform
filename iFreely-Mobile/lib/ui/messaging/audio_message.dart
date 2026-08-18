import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioMessage extends StatefulWidget {
  final String url;
  final bool isMe;

  const AudioMessage({Key? key, required this.url, required this.isMe})
      : super(key: key);

  @override
  _AudioMessageState createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;
  bool _isPlaying = false;
  Duration _duration = Duration();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _playPauseAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });

      if (true) {
        try {
          await _audioPlayer.play(UrlSource(widget.url));

          setState(() {
            _isPlaying = true;
            _isLoading = false;
          });

          _audioPlayer.onPlayerComplete.listen((event) {
            setState(() {
              _isPlaying = false;
            });
          });
        } catch (e) {
          print(e);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: Row(
        children: [
          // SizedBox(width: 10),
          IconButton(
            icon: _isLoading
                ? CircularProgressIndicator(
                    color: widget.isMe ? Colors.white : Colors.black,
                  )
                : _isPlaying
                    ? Icon(
                        Icons.pause,
                        color: widget.isMe ? Colors.white : Colors.black,
                      )
                    : Icon(
                        Icons.play_arrow,
                        color: widget.isMe ? Colors.white : Colors.black,
                      ),
            onPressed: _playPauseAudio,
          ),
          // SizedBox(width: 10,height: 20,),
          Text(
            "Voice Message",
            style: TextStyle(color: widget.isMe ? Colors.white : Colors.black),
          ),
          SizedBox(
            width: 20,
            height: 20,
          ),
        ],
      ),
    );
  }
}
