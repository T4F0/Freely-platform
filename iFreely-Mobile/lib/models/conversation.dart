import 'package:flut/models/message.dart';
import 'package:isar/isar.dart';

part 'conversation.g.dart';

@collection
class Conversation {
  Id localId =
      Isar.autoIncrement; // you can also use id = null to auto increment

  String id = "";
  String? name;
  String? otherUser;

  String image = "assets/Avatar.png";

  @Backlink(to: "conversation")
  final messages = IsarLinks<Message>();

  String lastMessage = "";

  DateTime? lastMessageTime;

  int notification = 0;
  bool active = false;
  Conversation({
    this.id = "",
    this.active = false,
    this.image = "assets/Avatar.png",
    this.name = "Baghdad Akram",
    this.notification = 0,
    this.otherUser = "",
    this.lastMessage = "",
    this.lastMessageTime,
  });

  static Conversation fromJson(Map<String, dynamic> json, String me) {
    String lastMessage;
    String lastMessageDiff = "";
    print(json["lastMessage"]);
    if (json["lastMessage"] != null) {
      if (json["lastMessage"]["type"] == "text") {
        lastMessage = json["lastMessage"]["message"];
      } else if (json["lastMessage"]["type"] == "image") {
        lastMessage = "Image";
      } else if (json["lastMessage"]["type"] == "audio") {
        lastMessage = "Audio";
      } else {
        lastMessage = "Video";
      }
      if (json["lastMessage"]["postedByUser"] == me) {
        lastMessage = "You: " + lastMessage;
      }
      DateTime lastMessageTime =
          DateTime.parse(json["lastMessage"]["createdAt"]);
    } else {
      lastMessage = "No messages yet";
    }
    return Conversation(
        id: json["_id"],
        active: json["userIds"]
                .firstWhere((element) => element["_id"] != me)["active"] ??
            false,
        image: "assets/Avatar.png",
        name: json["userIds"]
            .firstWhere((element) => element["_id"] != me)["username"],
        notification: json["lastMessage"] != null &&
                json["lastMessage"]["postedByUser"] != me
            ? json["notifications"]
            : 0,
        otherUser: json["userIds"]
            .firstWhere((element) => element["_id"] != me)["_id"],
        lastMessage: lastMessage,
        lastMessageTime: json["lastMessage"] != null
            ? DateTime.parse(json["lastMessage"]["createdAt"])
            : null);
  }
}
