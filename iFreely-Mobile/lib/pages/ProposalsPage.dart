import 'package:flut/bloc/proposals/proposals_bloc.dart';
import 'package:flut/ui/feed_gig_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProposalsPage extends StatefulWidget {
  ProposalsPage({super.key});

  @override
  State<ProposalsPage> createState() => _ProposalsPageState();
}

class _ProposalsPageState extends State<ProposalsPage> {
  void showJobs() {
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
    context.read<ProposalsBloc>().add(LoadJobs());
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
                  _flatBtn("Jobs", showJobs),
                  SizedBox(width: 10),
                  _flatBtn("Active Jobs", showActiveJobs),
                  SizedBox(width: 10),
                  _flatBtn("Archived Jobs", showArchivedJobs),
                ],
              ),
              SizedBox(height: 20),
              [
                BlocBuilder<ProposalsBloc, ProposalsState>(
                  builder: (context, ProposalsState state) {
                    return Column(
                      children: [
                        state.jobs.length == 0
                            ? Text("You have no jobs, create a job?")
                            : SizedBox(),
                        for (int i = 0; i < state.jobs.length; i++)
                          FeedGigCard(data: state.jobs[i],jobTyp : "jobs"),
                      ],
                    );
                  },
                ),
                BlocBuilder<ProposalsBloc, ProposalsState>(
                  builder: (context, ProposalsState state) {
                    return Column(
                      children: [
                        state.activeJobs.length == 0
                            ? Text("You have no active jobs")
                            : SizedBox(),
                        for (int i = 0; i < state.activeJobs.length; i++)
                          FeedGigCard(data: state.activeJobs[i],jobTyp : "activeJobs"),
                      ],
                    );
                  },
                ),
                BlocBuilder<ProposalsBloc, ProposalsState>(
                  builder: (context, ProposalsState state) {
                    return Column(
                      children: [
                        state.archivedJobs.length == 0
                            ? Text("You have no archived jobs")
                            : SizedBox(),
                        for (int i = 0; i < state.archivedJobs.length; i++)
                          FeedGigCard(data: state.archivedJobs[i],jobTyp : "archivedJobs"),
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
        "Proposals",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 5,
    );
  }
}
