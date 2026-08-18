part of 'nav_bloc.dart';

sealed class NavEvent extends Equatable {
  const NavEvent();

  @override
  List<Object> get props => [];
}

class NavChange extends NavEvent {
  final int index;
  const NavChange(this.index);

  @override
  List<Object> get props => [index];
}
