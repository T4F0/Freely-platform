part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final UserModel user;
  const ProfileState({
   required this.user
  });



  ProfileState copyWith({
    UserModel? user, 
  }) => ProfileState(
      user: user ?? this.user,
  );



  @override
  List<Object> get props => [user];
}

