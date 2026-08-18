part of 'register_bloc.dart';

enum RegisterError { none, network, email }

enum RegisterStatus { intial, loading, success ,failed }

class RegisterState extends Equatable {
  String first_name;
  String last_name;
  String email;
  String password;

  String birthday;
  String phone_number;
  String wilaya;
  String job_title;

  String education;
  String work_expertise;
  String role;
  String rate;
  String skills;
  String intersts;


  RegisterError error;
  RegisterStatus status;

  RegisterState({
    this.first_name = "hawad",
    this.last_name = "sleeps well",
    this.email = "hawad@gmail.com",
    this.password = "123456789",
    this.birthday = "12-12-12",
    this.phone_number = "06xxxxxxx",
    this.wilaya = "usa",
    this.job_title = "freelacer for free",
    this.education = "esi sba",
    this.work_expertise = "none",
    this.rate = "0 DA",
    this.skills = "",
    this.intersts = "",
    this.role = CLIENT,
    this.error = RegisterError.none,
    this.status = RegisterStatus.intial,
  });
  RegisterState copyWith({
    first_name,
    last_name,
    email,
    password,
    birthday,
    phone_number,
    wilaya,
    job_title,
    education,
    work_expertise,
    rate,
    skills,
    error,
    status,
    role,
    intersts,
  }) =>
      RegisterState(
        first_name: first_name ?? this.first_name,
        last_name: last_name ?? this.last_name,
        email: email ?? this.email,
        password: password ?? this.password,
        birthday: birthday ?? this.birthday,
        phone_number: phone_number ?? this.phone_number,
        wilaya: wilaya ?? this.wilaya,
        job_title: job_title ?? this.job_title,
        education: education ?? this.education,
        work_expertise: work_expertise ?? this.work_expertise,
        rate: rate ?? this.rate,
        skills: skills ?? this.skills,
        error : error ?? this.error,
        status : status ?? this.status,
        role : role ?? this.role,
        intersts : intersts ?? this.intersts,
      );

  @override
  List<Object> get props => [
        first_name,
        last_name,
        email,
        password,
        birthday,
        phone_number,
        wilaya,
        job_title,
        education,
        work_expertise,
        role,
        rate,
        skills,
        status,
        intersts,
        error,
      ];
}
