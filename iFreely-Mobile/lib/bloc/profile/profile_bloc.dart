import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flut/models/user_model.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:http/http.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  AuthRepo _authRepo;
  ProfileBloc(this._authRepo) : super(ProfileState(user: UserModel(firstName: "", lastName: "", id: "", ccp: "", email: "", role: "", token: "",bio: ""))) {
    on<InitProfileInfo>(on_init_profile);
    on<UpdateProfileInfo>(on_update_profile);
    
  }

  on_init_profile(event, emit) async {
    emit(ProfileState(user: _authRepo.user_model!));
    try {
      var profile_user_model =  await _authRepo.load_profile_info(event.id);
      emit(state.copyWith(user:  profile_user_model));
    } catch(e) {
      rethrow;
    }
  }

  on_update_profile(UpdateProfileInfo event, emit) async {
    try {
      var profile_user_model =  await _authRepo.update_client_profile(event.input);
      emit(state.copyWith(user:  profile_user_model));
  } catch(e) {
      rethrow;
    }
    

  }
}
