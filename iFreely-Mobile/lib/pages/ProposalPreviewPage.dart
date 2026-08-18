import 'package:flut/bloc/messaging/conversation_bloc.dart';
import 'package:flut/bloc/messaging/messaging_bloc.dart';
import 'package:flut/bloc/proposals/proposals_bloc.dart';
import 'package:flut/consts/routes.dart';
import 'package:flut/models/attachement.dart';
import 'package:flut/models/proposal_model.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProposalPreviewPage extends StatefulWidget {
  String jobID;
  String jobType;

  ProposalPreviewPage({super.key, required this.jobID, required this.jobType});

  @override
  State<ProposalPreviewPage> createState() => _ProposalPreviewPageState();
}

class _ProposalPreviewPageState extends State<ProposalPreviewPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProposalsBloc>().add(LoadProposals(widget.jobID));
  }

  void onAccept(state) async {
    try {
      context
          .read<AuthRepo>()
          .accept_job(state.currProposal!.userId, widget.jobID);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    Navigator.pop(context);
  }

  void onChat() {
    context.read<ConversationBloc>().add(
          ConversationInitiateConvo(
            [
              context.read<AuthRepo>().user_model!.id,
              "2bc8ec9eca5a49fd9536e465d2e88ff8"
            ],
          ),
        );
  }

  void selectProposal(idx) {
    context.read<ProposalsBloc>().add(SelectProposal(idx));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProposalsBloc, ProposalsState>(
      listener: (context, state) {
        if (state.status == ProposalNetworkStatus.failed) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Failed to load proposals, please retry")));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: _appbar(state),
          endDrawer: (state.proposals.length != 0 && widget.jobType == "jobs")
              ? Drawer(
                  backgroundColor: Colors.white,
                  child: SafeArea(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Proposals",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            ...state.proposals.length == 0
                                ? [
                                    Text("No Available Proposals"),
                                  ]
                                : [
                                    for (var i = 0;
                                        i < state.proposals.length;
                                        i++)
                                      _proposal_card(i, state)
                                  ]
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          body: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...widget.jobType == "jobs"
                      ? state.status == ProposalNetworkStatus.loading &&
                              state.proposals.length == 0
                          ? [
                              Row(
                                children: [
                                  Center(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ],
                              )
                            ]
                          : [
                              ...state.proposals.length == 0
                                  ? [Center(child: Text("No proposals for current job"))]
                                  : [
                                      _pf_info(state.currProposal!),
                                      SizedBox(height: 40),
                                      _bio(state),
                                      SizedBox(height: 40),
                                      _description(state),
                                      SizedBox(height: 40),
                                      _date_price(state),
                                      SizedBox(height: 40),
                                      _files(state),
                                      SizedBox(height: 40),
                                      _btns(state),
                                    ]
                            ]
                      : [
                          (() {
                            
                            var curJob = state
                                .getJob(widget.jobType, widget.jobID)!
                                .title;
                            return Text(curJob.toString());
                          }()),
                        ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  GestureDetector _proposal_card(int i, ProposalsState state) {
    return GestureDetector(
      onTap: () => selectProposal(i),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                !state.proposals[i].userPfp.contains("http")
                    ? Image.asset(
                        state.proposals[i].userPfp,
                        width: 35,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: Image.network(
                          state.proposals[i].userPfp,
                          width: 60,
                          height: 60,
                        ),
                      ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          state.proposals[i].userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            for (var j = 0; j < 5; j++)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 1),
                                child: SvgPicture.asset(
                                  j < state.proposals[i].userRating.ceil()
                                      ? "assets/icons/star.svg"
                                      : "assets/icons/star_grey.svg",
                                  width: 12,
                                ),
                              ),
                            SizedBox(width: 5),
                            Text(
                              state.proposals[i].userRating.ceil().toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF864AF9),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.proposals[i].dueDate,
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    state.proposals[i].finalPrice + " DA",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            )
          ],
        ),
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: Color(0x40D9D9D9),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Row _btns(state) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => onAccept(state),
          child: Text(
            "Accept",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xFF864AF9)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            padding: MaterialStateProperty.all(
              EdgeInsets.symmetric(horizontal: 40),
            ),
          ),
        ),
        SizedBox(width: 16),
        BlocListener<ConversationBloc, ConversationState>(
          listener: (context, state) {
            if (state.status == ConversationStatus.success) {
              Navigator.pushReplacementNamed(
                context,
                Routes.chats_room,
                arguments: [state.lastConv, state.otherUser],
              );
            }
          },
          child: ElevatedButton(
            onPressed: onChat,
            child: Text(
              "Chat",
              style: TextStyle(
                color: Color(0xFF332941),
                fontSize: 18,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              surfaceTintColor: MaterialStateProperty.all(Colors.white),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: Color(0xFF864AF9))),
              ),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(horizontal: 40),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column _files(ProposalsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            "Attachements:",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF333333),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        ...state.currProposal!.files.length == 0
            ? [Text("    No attachements")]
            : (state.currProposal!.files).map(
                (Attachement attachement) => Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // SvgPicture.asset(
                          //   attachement.icon,
                          // ),
                          SizedBox(width: 20),
                          Text(
                            attachement.name,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xB2141414),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        attachement.size,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0x141414).withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Column _date_price(ProposalsState state) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Due Date",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "Final Price",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                state.currProposal!.dueDate,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xCC141414),
                ),
              ),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                state.currProposal!.finalPrice + "\$",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xCC141414),
                ),
              ),
              decoration: BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _description(ProposalsState state) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(
              minHeight: 100,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              state.currProposal!.description,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            decoration: BoxDecoration(
              color: Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(4),
            ),
          )
        ],
      ),
    );
  }

  Widget _bio(ProposalsState state) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bio",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(
              minHeight: 100,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              state.currProposal!.userBio,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            decoration: BoxDecoration(
              color: Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(4),
            ),
          )
        ],
      ),
    );
  }

  Widget _pf_info(ProposalModel proposal) {
    return Row(
      children: [
        !proposal.userPfp.contains("http")
            ? Image.asset(
                proposal.userPfp,
                width: 35,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: Image.network(
                  proposal.userPfp,
                  width: 80,
                  height: 80,
                ),
              ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  proposal.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < 5; i++)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 1),
                        child: SvgPicture.asset(
                          i < proposal.userRating.ceil()
                              ? "assets/icons/star.svg"
                              : "assets/icons/star_grey.svg",
                          width: 14,
                        ),
                      ),
                    SizedBox(width: 10),
                    Text(
                      proposal.userRating.ceil().toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF864AF9),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        )
      ],
    );
  }

  AppBar _appbar(ProposalsState state) {
    return AppBar(
      title: Text(
        widget.jobType == "jobs"
            ? "Proposal Preivew"
            : state.getJob(widget.jobType, widget.jobID)!.title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      automaticallyImplyLeading: false,
      actions: [],
      surfaceTintColor: Colors.white,
      elevation: 5,
      shadowColor: Colors.grey.withOpacity(0.2),
    );
  }
}
