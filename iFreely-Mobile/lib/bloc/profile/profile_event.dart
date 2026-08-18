part of 'profile_bloc.dart';

class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}


class InitProfileInfo extends ProfileEvent {
  String id;
  InitProfileInfo({this.id = ""});
}
class UpdateProfileInfo extends ProfileEvent {
  Map<String,String> input;
  UpdateProfileInfo(this.input);
  @override
  List<Object> get props => [input];
}
