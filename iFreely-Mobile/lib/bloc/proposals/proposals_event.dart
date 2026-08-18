part of 'proposals_bloc.dart';

sealed class ProposalsEvent extends Equatable {
  const ProposalsEvent();

  @override
  List<Object> get props => [];
}

class SetProposalsJobID extends ProposalsEvent { 
  String job_id = "";
  SetProposalsJobID(this.job_id);
  @override
  List<Object> get props => [job_id];

}


class LoadProposals extends ProposalsEvent {
  String proposal_id = "";
  LoadProposals(this.proposal_id);

  @override
  List<Object> get props => [proposal_id];

}

class LoadJobs extends ProposalsEvent {
  @override
  List<Object> get props => [];
}


class SelectProposal extends ProposalsEvent {
  int idx = 0;
  SelectProposal(this.idx);

  @override
  List<Object> get props => [idx];

}


class LoadOneProposal extends ProposalsEvent {
  String jobID = "";
  LoadOneProposal(this.jobID);

  @override
  List<Object> get props => [jobID];

}