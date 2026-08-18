part of 'conversation_bloc.dart';

enum ConversationStatus { initial, loading, failed, success }

enum ConversationError { none, network }

class ConversationState extends Equatable {
  final List<Conversation> conversations;
  final ConversationStatus status;
  final ConversationError error;

  String lastConv = "";
  String otherUser = "";

  ConversationState({
    this.conversations = const [],
    this.error = ConversationError.none,
    this.status = ConversationStatus.initial,
    this.lastConv = "",
    this.otherUser = "",
  });

  ConversationState copyWith({
    List<Conversation>? conversations,
    ConversationStatus? status,
    ConversationError? error,
    String? lastConv,
    String? otherUser,
    
  }) {
    return ConversationState(
        conversations: conversations ?? this.conversations,
        status: status ?? this.status,
        error: error ?? this.error,
        lastConv: lastConv ?? this.lastConv,
        otherUser: otherUser ?? this.otherUser,
        
        );
  }

  @override
  List<Object> get props => [conversations, status, error,lastConv,otherUser];
}
