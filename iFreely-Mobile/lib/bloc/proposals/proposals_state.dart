part of 'proposals_bloc.dart';

enum ProposalNetworkStatus { loading, failed, loaded }

class ProposalsState extends Equatable {
  List<ProposalModel> proposals;
  int curr_proposal;
  ProposalNetworkStatus status;
  String jobId;

  List<FeedCard> activeJobs;
  List<FeedCard> jobs;
  List<FeedCard> archivedJobs;

  ProposalModel? clientProposal;


  ProposalsState({
    required this.proposals,
    required this.curr_proposal,
    required this.jobId,
    this.clientProposal = null,
    this.status = ProposalNetworkStatus.loading,
    this.activeJobs = const [],
    this.jobs = const [],
    this.archivedJobs = const [],
  });


  FeedCard? getJob(typ,id) {
    List<FeedCard> l = jobs;
    if(typ == "archivedJobs") {
      l = archivedJobs;
    } else if(typ == "activeJobs") {
      l = activeJobs;

    }
    
    for(int i = 0 ; i < l.length; i++) {
      if(l[i].id == id) {
        return l[i];
      }
    }
    return null;
  }

  ProposalsState copyWith({
    List<ProposalModel>? proposals,
    ProposalNetworkStatus? status,
    int? curr_proposal,
    String? jobId,
    List<FeedCard>? activeJobs,
    List<FeedCard>? jobs,
    List<FeedCard>? archivedJobs,
    ProposalModel? clientProposal,

  }) =>
      ProposalsState(
        proposals: proposals ?? this.proposals,
        curr_proposal: curr_proposal ?? this.curr_proposal,
        status: status ?? this.status,
        jobId: jobId ?? this.jobId,
        activeJobs: activeJobs ?? this.activeJobs,
        jobs: jobs ?? this.jobs,
        archivedJobs: archivedJobs ?? this.archivedJobs,
        clientProposal: clientProposal ?? this.clientProposal,
        
      );

  ProposalModel? get currProposal {
    if (proposals.length != 0) {
      return this.proposals[this.curr_proposal];
    }
    return null;
  }

  @override
  List<dynamic> get props => [
        proposals,
        curr_proposal,
        status,
        activeJobs,
        jobs,
        archivedJobs,
        clientProposal
      ];
}
