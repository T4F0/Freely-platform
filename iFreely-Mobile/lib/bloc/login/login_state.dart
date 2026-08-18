part of 'login_bloc.dart';


enum LoginStatus {initial, loading, failed, success}
enum LoginError {none ,email , password,network}

class LoginState extends Equatable {
  final String email; 
  final String password; 


  final LoginStatus status; 
  final LoginError error;
  


  const LoginState({
    this.email = "",
    this.password = "",
    this.error = LoginError.none,
    this.status = LoginStatus.initial,
  });


  LoginState copyWith({
    String? email, 
    String? password, 
    LoginStatus? status, 
    LoginError? error, 
  }) => LoginState(
    email : email ?? this.email, 
    password : password ?? this.password, 
    status : status ?? LoginStatus.initial, 
    error : error ?? LoginError.none, 
  );

  @override
  List<Object> get props => [email,password,error,status];
}

