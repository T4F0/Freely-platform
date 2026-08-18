part of 'nav_bloc.dart';

sealed class NavState extends Equatable {
  const NavState();
  
  @override
  List<Object> get props => [];
}

final class NavIndex extends NavState {
  final int index;
  const NavIndex(this.index);
  
  @override
  List<Object> get props => [index];
}

