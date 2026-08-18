import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flut/consts/hive_consts.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:hive/hive.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepo _authRepo;

  LoginBloc(this._authRepo) : super(LoginState()) {
    on<LoginSubmit>((event, emit) =>_login_submit(event,emit) );
  }

  
  
  _login_submit(event,emit) async {
    String email = (event as LoginSubmit).email;
    String password = (event as LoginSubmit).password;


    
    emit(state.copyWith(status: LoginStatus.loading, email: email,password: password));

    try {
      await _authRepo.default_login(email, password);

      var box = await Hive.openBox(HiveConsts.USER_SESSION);
      _authRepo.user_model?.hive_store_self(box);

      emit(state.copyWith(status: LoginStatus.success));
    } catch(login_error) {
      emit(state.copyWith(error: login_error as LoginError,status: LoginStatus.failed));
    }

  }  
}
