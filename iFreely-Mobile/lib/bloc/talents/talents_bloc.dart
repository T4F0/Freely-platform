import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flut/repos/auth_repo.dart';

part 'talents_event.dart';
part 'talents_state.dart';

class TalentsBloc extends Bloc<TalentsEvent, TalentsState> {
  AuthRepo _authRepo;
  TalentsBloc(this._authRepo) : super(TalentsState(talents: [])) {
    on<LoadTalents>(onLoadTalents);
  }

  onLoadTalents(event, emit) async {
    var data = await _authRepo.load_talents() as List;

    List<Map<String, dynamic>> talents = [];
    for (int i = 0; i < data.length; i++) {
      talents.add({
        "name": data[i]["name"],
        "freelancers": data[i]["freelancers"],
      });
    }

    emit(state.copyWith(talents: talents));
  }
}
