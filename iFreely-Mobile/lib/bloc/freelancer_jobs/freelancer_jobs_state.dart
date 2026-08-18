part of 'freelancer_jobs_bloc.dart';

class FreelancerJobsState extends Equatable {
  List<dynamic> active_jobs;
  List<dynamic> archived_jobs;
  List<dynamic> requests;
  

  FreelancerJobsState({
    required this.active_jobs,
    required this.archived_jobs,
    required this.requests,
  });

  FreelancerJobsState copyWith({
    List<dynamic>? active_jobs,
    List<dynamic>? archived_jobs,
    List<dynamic>? requests
  }) =>
      FreelancerJobsState(
        active_jobs: active_jobs ?? this.active_jobs,
        archived_jobs: archived_jobs ?? this.archived_jobs,
        requests: requests ?? this.requests,
      );

  @override
  List<Object> get props => [active_jobs, archived_jobs,requests];
}
