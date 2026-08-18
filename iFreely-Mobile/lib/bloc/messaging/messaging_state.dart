part of 'messaging_bloc.dart';

enum MessagingStatus { initial, loading, failed, success }

enum MessagingError { none, network, userExists,fileUpload }

enum UserStatus { active, typing, offline,NetworkError }

class MessagingState extends Equatable {
  final List<Message> messages ;
  final Conversation conversation;
  final MessagingStatus status;
  final MessagingError error;
  final UserStatus userStatus;
  final bool reachedEnd ;

  const MessagingState({
    required this.messages,
    required this.conversation ,
    this.status = MessagingStatus.initial,
    this.error = MessagingError.none,
    this.userStatus = UserStatus.active,
    this.reachedEnd = false,
  });

  MessagingState copyWith({
    Conversation? conversation,
    MessagingStatus? status,
    MessagingError? error,
    List<Message>? messages,
    UserStatus? userStatus,
    bool? reachedEnd,
  }) {
    return MessagingState(
      conversation: conversation ?? this.conversation,
      status: status ?? this.status,
      error: error ?? this.error,
      messages: messages ?? this.messages,
      userStatus: userStatus ?? this.userStatus,
      reachedEnd: reachedEnd ?? this.reachedEnd,
    );
  }

  @override
  List<Object> get props => [conversation, status, error,messages,userStatus,reachedEnd];
}
