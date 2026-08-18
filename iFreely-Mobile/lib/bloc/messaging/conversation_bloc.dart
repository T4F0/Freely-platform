import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flut/models/conversation.dart';
import 'package:flut/repos/messaging_repo.dart';
import 'package:isar/isar.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final MessagingRepo _messagingRepo;
  ConversationBloc(this._messagingRepo) : super(ConversationState()) {
    on<ConversationGetConversations>((event, emit) async {
      try {
        var cached = await _messagingRepo.isar.conversations
            .where()
            .sortByLastMessageTimeDesc()
            .findAll();
        emit(
          state.copyWith(
            status: ConversationStatus.loading,
            conversations: cached,
            error: ConversationError.none,
          ),
        );
        var res = await _messagingRepo.getConvos(event.userId);
        emit(
          state.copyWith(
              status: ConversationStatus.success,
              conversations: res,
              error: ConversationError.none),
        );
      } catch (e) {
        print(e);
        emit(state.copyWith(
            status: ConversationStatus.failed,
            error: ConversationError.network));
      }
    });
    on<ConversationInitiateConvo>((ConversationInitiateConvo event, emit) async {
      emit(state.copyWith(status: ConversationStatus.loading));
      try {
        var res = await _messagingRepo.initConvo(event.userIds);
        add(ConversationGetConversations(userId: event.userIds[0]));  
        emit(
          state.copyWith(
            status: ConversationStatus.success,
            conversations: [],
            lastConv: res.toString(),
            otherUser: event.userIds[1]
          ),
        );
      } catch (e) {
        emit(state.copyWith(
            status: ConversationStatus.failed,
            error: ConversationError.network));
      }
    });
  }
}
