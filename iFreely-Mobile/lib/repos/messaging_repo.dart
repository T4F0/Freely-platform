import 'package:dio/dio.dart';
import 'package:flut/bloc/messaging/conversation_bloc.dart';
import 'package:flut/bloc/messaging/messaging_bloc.dart';
import 'package:flut/consts/server.dart';
import 'package:flut/models/conversation.dart';
import 'package:flut/models/conversation_model.dart';
import 'package:flut/models/message.dart';
import 'package:flut/models/message_model.dart';
import 'package:isar/isar.dart';

class MessagingRepo {
  final Isar isar;
  final Socket ws = Socket();
  MessagingRepo(this.isar);

  String token = "sadsa";
  Future<void> createUser(String id, String type, String username) async {
    var res;
    try {
      res = await Dio().post(
        MESSAGING_SERVER + "/users",
        data: {"id": id, "type": type, "username": username},
      );
    } catch (e) {
      print(e);
      throw MessagingError.network;
    }
    Map<String, dynamic> data = res.data as Map<String, dynamic>;
    if (data["success"] == false) {
      if (data["message"] == "User exists already") {
        throw MessagingError.userExists;
      }
      throw MessagingError.network;
    }
  }

  void init_user(String userId) {
    ws.io.connect();
    ws.io.emit("init", userId);
  }

  Future<String> initConvo(List<String> userIds) async {
    var res;
    try {
      res = await Dio().post(MESSAGING_SERVER + "/room/initiate",
          data: {"userIds": userIds},
          options: Options(headers: {
            "authorization": token,
          }));
    } catch (e) {
      print(e);
      throw MessagingError.network;
    }
    Map<String, dynamic> data = res.data as Map<String, dynamic>;
    if (data["success"] == false) {
      throw MessagingError.network;
    }
    return data["chatRoom"]["chatRoomId"];
  }

  Future<String> uploadFile(String path) async {
    var res;
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(path),
      });

      res = await Dio().post(SERVER + "/upload",
          data: formData,
          options: Options(headers: {
            "authorization": token,
          }));
      Map<String, dynamic> data = res.data as Map<String, dynamic>;

      return data["filepath"];
    } catch (e) {
      throw MessagingError.fileUpload;
    }
  }

  Future<List<Conversation>?> getConvos(String userId) async {
    var res;
    try {
      res = await Dio().get(MESSAGING_SERVER + "/room/user/$userId",
          options: Options(headers: {"authorization": token}));
      Map<String, dynamic> data = res.data as Map<String, dynamic>;
      await isar.writeTxn(() async {
        await isar.conversations.clear();
        data["conversations"].forEach((e) {
          isar.conversations.put(Conversation.fromJson(e, userId));
        });
      });
      return isar.conversations.where().sortByLastMessageTimeDesc().findAll();
    } catch (e) {
      print(e);
      throw ConversationError.network;
    }
  }

  Future<Map<String, dynamic>> getConvo(
      String convoId, String me, int page, int limit) async {
    var res;
    try {
      res = await Dio().get(MESSAGING_SERVER + "/room/$convoId",
          options: Options(
            headers: {"authorization": token},
          ),
          queryParameters: {"page": page, "limit": limit});
      Map<String, dynamic> data = res.data as Map<String, dynamic>;
      if (data["success"] == false) {
        throw MessagingError.network;
      }
      Conversation? convo;
      await isar.writeTxn(() async {
        convo =
            await isar.conversations.filter().idEqualTo(convoId).findFirst();
        if (convo != null) {
          await convo!.messages
              .filter()
              .sortByTimeDesc()
              .offset(page * limit)
              .limit(limit)
              .deleteAll();

          for (var message in data["conversation"]) {
            final t = Message.fromJson(message, me);
            await isar.messages.put(t);
            convo!.messages.add(t);
          }
          await convo!.messages.save();
        } 
      });
      return {
        "convo": convo!,
        "reachedEnd": data["conversation"].length < limit
      };
    } catch (e) {
      print(e);
      throw MessagingError.network;
    }
  }

  Future<MessageModel?> sendMessage(String convoId, Message message) async {
    var res;
    try {
      int savedId = 0;
      isar.writeTxn(() async {
        savedId = await isar.messages.put(message);
        Conversation? convo =
            await isar.conversations.filter().idEqualTo(convoId).findFirst();
        convo!.messages.add(message);
        await convo.messages.save();
      });
      res = await Dio().post(MESSAGING_SERVER + "/room/$convoId/message",
          data: {
            "message": message.message,
            "type": message.type.toString().split(".")[1],
            "senderId": message.author
          },
          options: Options(headers: {"authorization": token}));
    } catch (e) {
      throw MessagingError.network;
    }
    Map<String, dynamic> data = res.data as Map<String, dynamic>;
    if (data["success"] == false) {
      throw MessagingError.network;
    }
    // return MessageModel.fromJson(data["message"]);
  }

  Future<void> markConvoRead(convoId, userId) async {
    try {
      var res = await Dio().put(MESSAGING_SERVER + "/room/$convoId/mark-read",
          data: {"readerId": userId},
          options: Options(headers: {"authorization": token}));
      return;
    } catch (e) {
      throw MessagingError.network;
    }
  }
}
