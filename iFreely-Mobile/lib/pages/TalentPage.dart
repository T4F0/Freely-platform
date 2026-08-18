import 'package:flut/bloc/messaging/conversation_bloc.dart';
import 'package:flut/bloc/talents/talents_bloc.dart';
import 'package:flut/consts/routes.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horizontal_list/horizontal_list.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';

class TalentPage extends StatefulWidget {
  TalentPage({super.key});

  @override
  State<TalentPage> createState() => _TalentPageState();
}

class _TalentPageState extends State<TalentPage> {
  void init() async {
    await context.read<AuthRepo>().load_auth_from_session();
    context.read<TalentsBloc>().add(LoadTalents());
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  var focus_idx = 0;
  void onItemFocus(idx) {
    setState(() {
      focus_idx = idx;
    });
  }

  void navigateToProposals(context) {
    Navigator.pushNamed(context, Routes.proposals_page);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, state) {
        if (state.status == ConversationStatus.success) {
          Navigator.pushReplacementNamed(
            context,
            Routes.chats_room,
            arguments: [state.lastConv, state.otherUser],
          );
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: _appbar(),
          body: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: BlocBuilder<TalentsBloc, TalentsState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < state.talents.length; i++) ...[
                        state.talents[i]["freelancers"].length == 0
                            ? SizedBox()
                            : _talent(
                                state.talents[i]["name"],
                                state.talents[i]["freelancers"],
                              ),
                        SizedBox(height: 32)
                      ],

                      // SizedBox(height: 32),
                      // _talent("Web Dev"),
                      // SizedBox(height: 32),
                      // _talent("Mobile"),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column _talent(title, List freelancers) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
          child: Row(
            children: [
              for (int i = 0; i < freelancers.length; i++)
                freelancers.length == 0
                    ? SizedBox()
                    : _talentCard(freelancers[i]),
            ],
          ),
        ),
      ],
    );
  }

  Container _talentCard(freelancer) {
    return Container(
      width: 300,
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 0,
            color: Color.fromRGBO(134, 74, 249, 1),
            offset: Offset(0, 4),
          ),
          BoxShadow(
            blurRadius: 4,
            color: Colors.grey.withOpacity(0.5),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          freelancer["photo"] == null
              ? Image.asset(
                  "assets/pfp.png",
                )
              : Image.network(
                  freelancer["photo"],
                  width: 70,
                  height: 70,
                ),
          Text(freelancer["firstName"] + " " + freelancer["lastName"]),
          SizedBox(height: 4),
          Text(freelancer["jobTitle"] ?? "no title"),
          SizedBox(height: 8),
          Text(
            freelancer["description"] != null
                ? freelancer["description"] +
                    "asdmnasdjlkasdjhasdhjhjasdhjashjdhjasd,asdnjbasdjhkashjkdjkasdhjkasjdhk"
                : "no description",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<ConversationBloc>().add(
                        ConversationInitiateConvo(
                          [
                            context.read<AuthRepo>().user_model!.id,
                            freelancer["_id"],
                          ],
                        ),
                      );
                },
                child: Text("Message"),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text("View Profile"),
              ),
            ],
          )
        ],
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
      title: Text("Talent Page"),
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.white,
      elevation: 5,
      shadowColor: Colors.grey.withOpacity(0.2),
      actions: [
        IconButton(
            onPressed: () => navigateToProposals(context),
            icon: Icon(Icons.notifications)),
      ],
    );
  }
}
