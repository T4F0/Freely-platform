part of 'talents_bloc.dart';

sealed class TalentsEvent extends Equatable {
  const TalentsEvent();
  @override
  List<Object> get props => [];
}


class LoadTalents extends TalentsEvent {
  LoadTalents();
  @override
  List<Object> get props => [];
}