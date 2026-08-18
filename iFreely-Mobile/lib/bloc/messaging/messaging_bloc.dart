import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flut/consts/server.dart';
import 'package:flut/models/conversation.dart';
import 'package:flut/models/conversation_model.dart';
import 'package:flut/models/message.dart';
import 'package:flut/models/message_model.dart';
import 'package:flut/repos/messaging_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';

part 'messaging_event.dart';
part 'messaging_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  final MessagingRepo _messagingRepo;

  MessagingBloc(this._messagingRepo)
      : super(MessagingState(conversation: Conversation(), messages: [])) {
    on<MessagingCreateUser>((event, emit) {
      emit(state.copyWith(status: MessagingStatus.loading));
      try {
        _messagingRepo.createUser(event.id, event.type,event.username);
        emit(state.copyWith(status: MessagingStatus.success));
      } catch (e) {
        emit(state.copyWith(
            status: MessagingStatus.failed, error: e as MessagingError));
      }
    });
    // on<MessagingInitiateConvo>((event, emit) async {
    //   emit(state.copyWith(status: MessagingStatus.loading));
    //   try {
    //     var res = await _messagingRepo.initConvo(event.userIds);
    //     emit(state.copyWith(status: MessagingStatus.success , currentConvo: res,messages: []));
    //   } catch (e) {
    //     emit(state.copyWith(status: MessagingStatus.failed, error: e as MessagingError));5
    //   }
    // });
    on<MessagingGetConvo>((event, emit) async {
      emit(state.copyWith(status: MessagingStatus.loading));
      try {
        Conversation? cached = await _messagingRepo.isar.conversations
            .where()
            .filter()
            .idEqualTo(event.convoId)
            .findFirst();
        List<Message> messages;
        if (cached != null){
        messages =
            await cached.messages.filter().sortByTime().findAll();
        } else {
          messages = List<Message>.empty();
        }
        emit(state.copyWith(
            status: MessagingStatus.loading,
            conversation: cached,
            messages: messages));

        Map<String, dynamic> res = await _messagingRepo.getConvo(
            event.convoId, event.userId, event.page, event.limit);
        bool reachedEnd = res["reachedEnd"];
        print(res["convo"]);
        messages = await (res["convo"] as Conversation)
            .messages
            .filter()
            .sortByTime()
            .findAll();

        emit(state.copyWith(
            status: MessagingStatus.success,
            conversation: res["convo"],
            error: MessagingError.none,
            messages: messages,
            reachedEnd: reachedEnd));
      } catch (e) {
        print(e);
        emit(state.copyWith(
            status: MessagingStatus.failed, error: e as MessagingError));
      }
    });
    on<MessagingSendMessage>((event, emit) async {
      emit(state.copyWith(status: MessagingStatus.loading));
      try {
        int savedId = 0;
        await _messagingRepo.isar.writeTxn(() async {
          savedId = await _messagingRepo.isar.messages.put(event.message);
          Conversation? convo = await _messagingRepo.isar.conversations
              .filter()
              .idEqualTo(event.convoId)
              .findFirst();
          convo!.messages.add(event.message);
          await convo.messages.save();
        });
        emit(state.copyWith(
            status: MessagingStatus.success,
            messages: state.messages..add(event.message)));

        var res = await _messagingRepo.sendMessage(
          event.convoId,
          event.message,
        );
        await _messagingRepo.isar.writeTxn(() async {
          Message? message = await _messagingRepo.isar.messages.get(savedId);
          print(message!.message);
          message!.status = Status.sent;
          await _messagingRepo.isar.messages.put(message);
        });

        Conversation? convo = await _messagingRepo.isar.conversations
            .filter()
            .idEqualTo(event.convoId)
            .findFirst();
        List<Message>? messages =
            await convo!.messages.filter().sortByTime().findAll();
        emit(state.copyWith(
            status: MessagingStatus.success,
            conversation: convo,
            messages: messages));
      } catch (e) {
        emit(state.copyWith(
            status: MessagingStatus.failed, error: e as MessagingError));
      }
    });

    on<MessagingReceiveMessage>((event, emit) {
      emit(state.copyWith(status: MessagingStatus.loading));
      try {
        var message = Message.fromJson(event.message, event.userId);
        _messagingRepo.isar.writeTxn(() async {
          await _messagingRepo.isar.messages.put(message);
          Conversation? convo = await _messagingRepo.isar.conversations
              .filter()
              .idEqualTo(event.convoId)
              .findFirst();
          convo!.messages.add(message);
          await convo.messages.save();
        });
        emit(state.copyWith(
            status: MessagingStatus.success,
            messages: state.messages..add(message)));
      } catch (e) {
        emit(state.copyWith(
            status: MessagingStatus.failed, error: e as MessagingError));
      }
    });
    on<MessagingDisposeRoom>((event, emit) {
      emit(state.copyWith(status: MessagingStatus.loading));
      try {
        emit(state.copyWith(
            status: MessagingStatus.success,
            conversation: Conversation(),
            messages: []));
      } catch (e) {
        emit(state.copyWith(
            status: MessagingStatus.failed, error: e as MessagingError));
      }
    });
    on<MessagingReadConvo>(
      (event, emit) async {
        try {
          await _messagingRepo.markConvoRead(event.convoId, event.userId);
        } catch (e) {
          emit(state.copyWith(
              status: MessagingStatus.failed, error: e as MessagingError));
        }
      },
    );



    on<MessagingFileUpload>((event, emit) async {
      emit(state.copyWith(status: MessagingStatus.loading));
      try {
        var res = await _messagingRepo.uploadFile(event.path);
        emit(state.copyWith(status: MessagingStatus.success));
        print(res);
        add(MessagingSendMessage(
        event.convoId,
        Message(
            message:  res,
            type: event.type,
            author: event.userId,
            time: DateTime.now(),
            isSender: true,
            status: Status.sending)));
      } catch (e) {
        emit(state.copyWith(
            status: MessagingStatus.failed, error: e as MessagingError));
      }
    });


    on<MessagingUserIsActive>((event, emit) {
      emit(state.copyWith(userStatus: UserStatus.active));
    });
    on<MessagingUserIsOffline>((event, emit) {
      emit(state.copyWith(userStatus: UserStatus.offline));
    });
    on<MessagingUserIsTyping>((event, emit) {
      emit(state.copyWith(userStatus: UserStatus.typing));
    });
    on<MessagingNetworkError>((event, emit) {
      emit(state.copyWith(userStatus: UserStatus.NetworkError));
    });




  }
}
