import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'nav_event.dart';
part 'nav_state.dart';

class NavBloc extends Bloc<NavEvent, NavState> {
  NavBloc() : super(NavIndex(0)) {
    on<NavChange>((event, emit) {
      emit(NavIndex(event.index));
    });
  }
}
