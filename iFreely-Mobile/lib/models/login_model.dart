
import 'package:equatable/equatable.dart';

class LoginModel extends Equatable  {
  final String name;
  final String password;

  const LoginModel({
    required this.name,
    required this.password,
  });

  @override
  List<Object> get props => [name,password];
}