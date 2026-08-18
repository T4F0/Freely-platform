import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flut/models/feed_card.dart';
import 'package:flut/models/job_model.dart';
import 'package:flut/repos/auth_repo.dart';

part 'freelancer_jobs_event.dart';
part 'freelancer_jobs_state.dart';

class FreelancerJobsBloc extends Bloc<FreelancerJobsEvent, FreelancerJobsState> {
  AuthRepo _authRepo;
  FreelancerJobsBloc(this._authRepo) : super(FreelancerJobsState(active_jobs: [],archived_jobs: [],requests: [])) {
    on<FreelancerJobsEvent>(onLoadJobs);
  }

  onLoadJobs(event, emit) async {
    var data = await _authRepo.load_freelancer_dash();

    List<FeedCard> jobsProgress = [];
    for (int i = 0; i < (data["jobsProgress"] as List).length; i++) {
      jobsProgress.add(FeedCard.fromJson((data["jobsProgress"] as List)[i]));
    }

    List<FeedCard> jobsArchive = [];
    for (int i = 0; i < (data["jobsArchive"] as List).length; i++) {
      jobsArchive.add(FeedCard.fromJson((data["jobsArchive"] as List)[i]));
    }



    List<FeedCard> requests = [];
      for (int i = 0; i < (data["requests"] as List).length; i++) {
      requests.add(FeedCard.fromJson((data["requests"] as List<dynamic>)[i]["job"]));
    }
 

    emit(state.copyWith(active_jobs: jobsProgress,archived_jobs: jobsArchive,requests: requests));    
  }
}
