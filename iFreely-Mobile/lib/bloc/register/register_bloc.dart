import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flut/consts/hive_consts.dart';
import 'package:flut/models/user_model.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:hive/hive.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  AuthRepo _authRepo;
  RegisterBloc(this._authRepo) : super(RegisterState()) {
    on<RegisterFirstStageSubmit>(_register_first_stage);
    on<RegisterSecondStageSubmit>(_register_second_stage);
    on<RegisterFinishSubmitFreelancer>(_register_last_stage_freelancer);
    on<RegisterFinishSubmitClient>(_register_last_stage_client);
  }

  _register_first_stage(RegisterFirstStageSubmit event, emit) {
    emit(state.copyWith(
      first_name: event.first_name,
      last_name: event.last_name,
      email: event.email,
      password: event.password,
    ));
  }

  _register_second_stage(RegisterSecondStageSubmit event, emit) {
    emit(state.copyWith(
      birthday: event.birthday,
      phone_number: event.phone_number,
      wilaya: event.wilaya,
      job_title: event.job_title,
      role: event.role,
    ));
  }

  _register_last_stage_freelancer(RegisterFinishSubmitFreelancer event, emit) async {
    emit(state.copyWith(
      education: event.education,
      work_expertise: event.work_expertise,
      rate: event.rate,
      skills: event.skills,
      status: RegisterStatus.loading,
    ));


    try {
      await _authRepo.register_freelancer(state);

      var box =  await Hive.openBox(HiveConsts.USER_SESSION);
      _authRepo.user_model?.hive_store_self(box);

      emit(state.copyWith(status: RegisterStatus.success,error: RegisterError.none));
    } catch(register_error) {
      emit(state.copyWith(status: RegisterStatus.failed,error: register_error));
    } 

  }

  _register_last_stage_client(RegisterFinishSubmitClient event, emit) async {
    emit(state.copyWith(
      intersts: event.intersts,
      status: RegisterStatus.loading,
    ));


    try {
      await _authRepo.register(state);

      var box =  await Hive.openBox(HiveConsts.USER_SESSION);
      _authRepo.user_model?.hive_store_self(box);
      emit(state.copyWith(status: RegisterStatus.success,error: RegisterError.none));
    } catch(register_error) {
      emit(state.copyWith(status: RegisterStatus.failed,error: register_error));
    } 

  }  
}
