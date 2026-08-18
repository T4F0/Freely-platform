part of 'create_job_bloc.dart';

sealed class CreateJobEvent extends Equatable {
  const CreateJobEvent();

  @override
  List<Object> get props => [];
}

class SetStage extends CreateJobEvent {
  final int stage;
  SetStage(this.stage) {
    debugPrint("SetStage stage: $stage");
  }

  @override
  List<Object> get props => [stage];
}


class CreateJob extends CreateJobEvent {
  final JobModel jobModel;
  const CreateJob(this.jobModel);

  @override
  List<Object> get props => [];
}
