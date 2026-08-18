import 'package:flut/bloc/freelancer_jobs/freelancer_jobs_bloc.dart';
import 'package:flut/bloc/proposals/proposals_bloc.dart';
import 'package:flut/ui/feed_gig_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FreelancerJobs extends StatefulWidget {
  FreelancerJobs({super.key});

  @override
  State<FreelancerJobs> createState() => _FreelancerJobsState();
}

class _FreelancerJobsState extends State<FreelancerJobs> {
  void showOnHold() {
    setState(() {
      curJobTab = 0;
    });    
  }

  void showActiveJobs() {
    setState(() {
      curJobTab = 1;
    });
  }

  void showArchivedJobs() {
    setState(() {
      curJobTab = 2;
    });
  }



  int curJobTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<FreelancerJobsBloc>().add(FreelancerLoadJobs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFfafafa),
      appBar: _appbar(),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 36,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _flatBtn("On Hold", showOnHold),
                  SizedBox(width: 10),
                  _flatBtn("Active Jobs", showActiveJobs),
                  SizedBox(width: 10),
                  _flatBtn("Archived Jobs", showArchivedJobs),
                ],
              ),
              SizedBox(height: 20),
              [
                BlocBuilder<FreelancerJobsBloc, FreelancerJobsState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        state.requests.length == 0
                            ? Text("You have no active jobs, check out the feed")
                            : SizedBox(),
                        for (int i = 0; i < state.requests.length; i++)
                          FeedGigCard(data: state.requests[i],jobTyp : "freelancer-onHoldRequests"),
                      ],
                    );
                  },
                ),                
                BlocBuilder<FreelancerJobsBloc, FreelancerJobsState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        state.active_jobs.length == 0
                            ? Text("You have no active jobs, check out the feed")
                            : SizedBox(),
                        for (int i = 0; i < state.active_jobs.length; i++)
                          FeedGigCard(data: state.active_jobs[i],jobTyp : "freelancer-activeJobs"),
                      ],
                    );
                  },
                ),
                BlocBuilder<FreelancerJobsBloc, FreelancerJobsState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        state.archived_jobs.length == 0
                            ? Text("You have no archived jobs")
                            : SizedBox(),
                        for (int i = 0; i < state.archived_jobs.length; i++)
                          FeedGigCard(data: state.archived_jobs[i],jobTyp : "freelancer-archived_jobs"),
                      ],
                    );
                  },
                )
              ][curJobTab],
            ],
          ),
        ),
      ),
    );
  }

  TextButton _flatBtn(text, callback) {
    return TextButton(
      onPressed: () => callback(),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Color(0xFF864AF9),
            ),
          ),
        ),
      ),
    );
  }


  AppBar _appbar() {
    return AppBar(
      title: Text(
        "Jobs",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 5,
    );
  }
}
