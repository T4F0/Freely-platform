part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();
  @override
  List<Object> get props => [];
}

class RegisterFirstStageSubmit extends RegisterEvent {
  String first_name;
  String last_name;
  String email;
  String password;

  RegisterFirstStageSubmit(
      this.first_name, this.last_name, this.email, this.password);
  @override
  List<Object> get props => [first_name, last_name, email, password];
}

class RegisterSecondStageSubmit extends RegisterEvent {
  String birthday;
  String phone_number;
  String wilaya;
  String job_title;
  String role;

  RegisterSecondStageSubmit(
    this.birthday,
    this.phone_number,
    this.wilaya,
    this.job_title,
    this.role,
  );
  @override
  List<Object> get props => [
        birthday,
        phone_number,
        wilaya,
        job_title,
        role,
      ];
}

class RegisterFinishSubmitFreelancer extends RegisterEvent {
  String education;
  String work_expertise;
  String rate;
  String skills;
  String bio;

  RegisterFinishSubmitFreelancer(
    this.education,
    this.work_expertise,
    this.rate,
    this.skills,
    this.bio,
  );

  @override
  List<Object> get props => [
        education,
        work_expertise,
        rate,
        skills,
        bio,
      ];
}



class RegisterFinishSubmitClient extends RegisterEvent {
  String intersts;

  RegisterFinishSubmitClient(
    this.intersts,
  );

  @override
  List<Object> get props => [
      intersts
      ];
}
