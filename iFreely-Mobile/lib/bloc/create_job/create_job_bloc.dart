import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flut/models/job_model.dart';
import 'package:flut/repos/job_creation_repo.dart';
import 'package:flutter/material.dart';

part 'create_job_event.dart';
part 'create_job_state.dart';

class CreateJobBloc extends Bloc<CreateJobEvent, CreateJobState> {
  JobCreationRepo _job_creation_repo;
  CreateJobBloc(this._job_creation_repo) : super(CreateJobStage(1)) {
    on<SetStage>((event, emit) {
      emit(CreateJobStage(event.stage));
    });

    on<CreateJob>((event, emit) async {
      emit(CreateJobLoading());
      try {
        await _job_creation_repo.post_job(event.jobModel);
        emit(CreateJobSuccess());
      } catch (e) {
        emit(CreateJobError(e.toString()));
      }
    });
  }
}
