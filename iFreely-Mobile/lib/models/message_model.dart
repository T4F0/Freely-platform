enum Status { sending, sent, seen }
enum MessageType { text, image, video, audio, file }
class MessageModel {
  String message = "";
  bool isSender = true;
  DateTime time = DateTime.now();
  MessageType type = MessageType.text;
  Status status = Status.sent;
  String author = "";
  String? id;

  MessageModel({
    required this.message,
    required this.isSender,
    required this.time,
    required this.type,
    required this.status,
    required this.author,
    this.id
  });

  void updateFromJson(Map<String, dynamic> json) {
    message = json["message"] ?? message;
    isSender = json["isSender"] ?? isSender;
    time = DateTime.parse(json["createdAt"]) ?? time;
    type = MessageType.values[json["type"]] ?? type;
    author = json["postedByUser"]["_id"] ?? author;
    id = json["_id"] ?? id;
    status = Status.sent;
  }

  MessageModel.fromJson(Map<String, dynamic> json,String me) {
    message = json["message"];
    time = DateTime.parse(json["createdAt"]);
    type = json["type"] == "text" ? MessageType.text : json["type"] == "image" ? MessageType.image : json["type"] == "video" ? MessageType.video : json["type"] == "audio" ? MessageType.audio : MessageType.file;
    author = json["postedByUser"]["_id"];
    isSender = me == json["postedByUser"]["_id"];
    id = json["_id"];
  }
}