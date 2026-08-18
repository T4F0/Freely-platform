import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flut/models/feed_card.dart';
import 'package:flut/models/proposal_model.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';

part 'proposals_event.dart';
part 'proposals_state.dart';

class ProposalsBloc extends Bloc<ProposalsEvent, ProposalsState> {
  AuthRepo _authRepo;
  ProposalsBloc(this._authRepo)
      : super(ProposalsState(curr_proposal: 0, proposals: [], jobId: "",)) {
    on<LoadProposals>(onLoadProposals);
    on<SetProposalsJobID>(onSetProposalsJobID);
    on<SelectProposal>(onSelectProposal);
    on<LoadJobs>(onLoadJobs);
  }

  void onLoadProposals(LoadProposals event, emit) async {
    emit(state.copyWith(status: ProposalNetworkStatus.loading));
    var props = await _authRepo.get_proposals(event.proposal_id);
    emit(state.copyWith(proposals: props,status: ProposalNetworkStatus.loaded));
  }

  void onSelectProposal(SelectProposal event, emit) async {
    emit(state.copyWith(curr_proposal: event.idx));
  }

  void onSetProposalsJobID(SetProposalsJobID event, emit) async {
    emit(state.copyWith(jobId: event.job_id));
  }  

  void onLoadJobs(event, emit) async {
    var data = await _authRepo.loadJobs();
    print("data: " + data.toString());

    List<FeedCard> jobs = [];
    for (int i = 0; i < (data["jobs"] as List).length; i++) {
      jobs.add(FeedCard.fromJson((data["jobs"] as List)[i]));
    }

    List<FeedCard> jobsProgress = [];
    for (int i = 0; i < (data["jobsProgress"] as List).length; i++) {
      jobsProgress.add(FeedCard.fromJson((data["jobsProgress"] as List)[i]));
    }

    List<FeedCard> jobsArchive = [];
    for (int i = 0; i < (data["jobsArchive"] as List).length; i++) {
      jobsArchive.add(FeedCard.fromJson((data["jobsArchive"] as List)[i]));
    }

    emit(state.copyWith(jobs: jobs,activeJobs: jobsProgress,archivedJobs: jobsArchive));
  }
}
