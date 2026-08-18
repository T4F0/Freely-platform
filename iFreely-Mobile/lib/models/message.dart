import 'package:flut/models/conversation.dart';
import 'package:flut/models/message_model.dart';
import 'package:isar/isar.dart';

part "message.g.dart";

@collection
class Message {
  Id localId = Isar.autoIncrement;

  String id = "";


  String message = "";
  bool isSender = true;

  DateTime time = DateTime.now();

  @Enumerated(EnumType.ordinal,"type")
  MessageType type = MessageType.text;

  @Enumerated(EnumType.ordinal,"status")
  Status status = Status.sent;

  String author = "";

  final conversation = IsarLink<Conversation>();

  Message({
    required this.message,
    required this.isSender,
    required this.time,
    required this.type,
    required this.status,
    required this.author,
    this.id = ""
  });
  
  static Message fromJson(Map<String, dynamic> json,String me) {
    return Message(
    message : json["message"],
    time : DateTime.parse(json["createdAt"]),
    type : json["type"] == "text" ? MessageType.text : json["type"] == "image" ? MessageType.image : json["type"] == "video" ? MessageType.video : json["type"] == "audio" ? MessageType.audio : MessageType.file,
    author : json["postedByUser"]["_id"],
    isSender : me == json["postedByUser"]["_id"],
    id : json["_id"],
    status: json["readByRecipients"].length > 1 ? Status.seen : Status.sent
    );
    
  }
}
