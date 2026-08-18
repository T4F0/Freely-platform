// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';

class RegisterModel extends Equatable {
  String first_name = "";
  String last_name = "";
  String email = "";
  String password = "";
  String phone_number = "";
  String wilaya = "";
  String job_title = "";
  String birthday = "";
  String work_expertise = "";
  String education = "";
  String skills = "";
  String bio = "";
  String rate = "";

  RegisterModel.init();

  RegisterModel({
    required this.first_name,
    required this.last_name,
    required this.email,
    required this.password,
    required this.phone_number,
    required this.wilaya,
    required this.job_title,
    required this.birthday,
    required this.work_expertise,
    required this.education,
    required this.skills,
    required this.bio,
    required this.rate,
  });

  @override
  List<Object> get props => [
        first_name,
        last_name,
        email,
        password,
        phone_number,
        wilaya,
        job_title,
        birthday,
        work_expertise,
        education,
        skills,
        bio
      ];
}
