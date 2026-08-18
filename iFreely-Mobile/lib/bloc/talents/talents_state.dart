part of 'talents_bloc.dart';

class TalentsState extends Equatable {
  List<Map<String, dynamic>> talents;

  TalentsState({
    required this.talents,
  });

  TalentsState copyWith({
    List<Map<String, dynamic>>? talents,
  }) =>
      TalentsState(
        talents: talents ?? this.talents,
      );

  @override
  List<Object> get props => [talents];
}
