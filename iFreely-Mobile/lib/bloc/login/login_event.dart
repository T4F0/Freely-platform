part of 'login_bloc.dart';



sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmit extends LoginEvent {
  final email;
  final password;
  LoginSubmit(this.email,this.password);

    @override
  List<Object> get props => [email,password];

}