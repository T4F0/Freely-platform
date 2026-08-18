part of 'conversation_bloc.dart';

sealed class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object> get props => [];
}

class ConversationGetConversations extends ConversationEvent {
  final int? page;
  final int? limit;
  final String userId;

  ConversationGetConversations({
    required this.userId ,
    this.limit ,
    this.page ,
  });

  @override
  List<Object> get props => [];
}

class ConversationInitiateConvo extends ConversationEvent {
  final List<String> userIds;

  ConversationInitiateConvo(this.userIds);

  @override
  List<Object> get props => [userIds];
}
