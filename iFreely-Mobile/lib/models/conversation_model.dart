import 'package:flut/models/message_model.dart';


class ConversationModel {
  String id;
  List<MessageModel> messages;
  List<String> users;

  ConversationModel(
      {required this.messages, required this.users, required this.id});

  void addMessage(MessageModel? message) {
    if (message != null) messages.add(message);
  }
}
