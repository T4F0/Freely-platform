part of 'messaging_bloc.dart';

sealed class MessagingEvent extends Equatable {
  const MessagingEvent();

  @override
  List<Object> get props => [];
}

class MessagingCreateUser extends MessagingEvent {
  final String id;
  final String type;
  final String username;

  MessagingCreateUser(this.id, this.type,this.username);

  @override
  List<Object> get props => [id, type];
}

class MessagingInitiateConvo extends MessagingEvent {
  final List<String> userIds;

  MessagingInitiateConvo(this.userIds);

  @override
  List<Object> get props => [userIds];
}

class MessagingGetConvo extends MessagingEvent {
  final String convoId;
  final String userId;
  final int page;
  final int limit;

  MessagingGetConvo(this.convoId, this.userId, this.page, this.limit);

  @override
  List<Object> get props => [convoId];
}

class MessagingSendMessage extends MessagingEvent {
  final String convoId;
  final Message message;
  MessagingSendMessage(this.convoId, this.message);

  @override
  List<Object> get props => [
        convoId,
        message,
      ];
}

class MessagingReceiveMessage extends MessagingEvent {
  final Map<String, dynamic> message;
  final String userId;
  final String convoId;
  MessagingReceiveMessage(this.message, this.userId, this.convoId);

  @override
  List<Object> get props => [message];
}

class MessagingDisposeRoom extends MessagingEvent {
  MessagingDisposeRoom();

  @override
  List<Object> get props => [];
}

class MessagingReadConvo extends MessagingEvent {
  final String convoId;
  final String userId;
  MessagingReadConvo(this.convoId, this.userId);

  @override
  List<Object> get props => [convoId, userId];
}

class MessagingUserIsTyping extends MessagingEvent {
  MessagingUserIsTyping();

  @override
  List<Object> get props => [];
}

class MessagingUserIsOffline extends MessagingEvent {
  MessagingUserIsOffline();

  @override
  List<Object> get props => [];
}

class MessagingUserIsActive extends MessagingEvent {
  MessagingUserIsActive();

  @override
  List<Object> get props => [];
}

class MessagingNetworkError extends MessagingEvent {
  MessagingNetworkError();

  @override
  List<Object> get props => [];
}

class MessagingFileUpload extends MessagingEvent {
  final String path;
  final String convoId;
  final String userId;
  final MessageType type;
  MessagingFileUpload(this.path, this.convoId, this.userId, this.type);

  @override
  List<Object> get props => [path, convoId, userId, type];
}
