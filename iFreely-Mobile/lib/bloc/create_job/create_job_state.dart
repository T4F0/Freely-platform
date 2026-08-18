part of 'create_job_bloc.dart';

class CreateJobState extends Equatable {
  const CreateJobState();

  @override
  List<Object> get props => [];
}

final class CreateJobStage extends CreateJobState {
  final int stage;
  const CreateJobStage(this.stage) ;

  @override
  List<Object> get props => [stage];
}



final class CreateJobLoading extends CreateJobState {
   const CreateJobLoading();
}

final class CreateJobSuccess extends CreateJobState {
  const CreateJobSuccess();
}

final class CreateJobError extends CreateJobState {
  final String error;
  const CreateJobError(this.error);

  @override
  List<Object> get props => [error];
}
