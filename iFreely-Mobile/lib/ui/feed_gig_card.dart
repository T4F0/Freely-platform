import 'package:flut/bloc/feed/feed_bloc.dart';
import 'package:flut/bloc/proposals/proposals_bloc.dart';
import 'package:flut/consts/routes.dart';
import 'package:flut/models/feed_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FeedGigCard extends StatelessWidget {
  FeedCard data;
  String jobTyp = "";
  FeedGigCard({
    super.key,
    required this.data,
    this.jobTyp = "",
  });
  int max_descrption_len = 120;

  void _select_card(BuildContext context) {
    context.read<FeedBloc>().add(FeedSelectCard(data));
    Navigator.pushNamed(context, Routes.feed_details_page);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProposalsBloc, ProposalsState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            if (jobTyp == "") {
              _select_card(context);
            } else if (jobTyp.contains("freelancer")) {
              context.read<FeedBloc>().add(FeedSelectCard(data));
              if (jobTyp == "freelancer-onHoldRequests") {
                Navigator.pushNamed(context, Routes.feed_details_page,
                    arguments: ["freelancer-onHoldRequests"]);
              } else {
                Navigator.pushNamed(context, Routes.feed_details_page,
                    arguments: ["freelancer-archive"]);
              }
            } else {
              if (jobTyp == "jobs") {
                context.read<ProposalsBloc>().add(LoadProposals(data.id));
                Navigator.pushNamed(context, Routes.proposals_preview_page,
                    arguments: [data.id, jobTyp]);
              } else {
                context.read<FeedBloc>().add(FeedSelectCard(state.getJob(jobTyp, data.id)!));
                Navigator.pushNamed(context, Routes.feed_details_page,
                    arguments: [jobTyp == "activeJobs" ? "client-active" : "client-archive"]);
              }
            }
          },
          child: Container(
            padding: EdgeInsets.all(24),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  offset: Offset(0, 2),
                  color: Colors.grey.withOpacity(0.3),
                ),
              ],
            ),
            child: Column(
              children: [
                _header(),
                SizedBox(
                  height: 10,
                ),
                _stat(),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    data.description.length <= max_descrption_len
                        ? data.description
                        : data.description.substring(0, max_descrption_len) +
                            "...",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color(0xB2141414).withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Row _header() {
    int max_title_len = 14;

    return Row(
      children: [
        Image.asset(data.logo),
        SizedBox(width: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            data.username.length != 0 ? Text(data.username) : SizedBox(),
            SizedBox(height: 5),
            Text(
              data.title.length <= max_title_len
                  ? data.title
                  : data.title.substring(0, max_title_len) + "...",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            data.username.length != 0
                  ? Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0x1A504099),
                borderRadius: BorderRadius.circular(5),
              ),
              child:  Text(
                      "New post",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7D5AE2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  
            ): SizedBox(),
          ],
        ),
      ],
    );
  }

  Row _stat() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _job_stat_detail("assets/icons/Clock.svg", data.payment_type),
        SvgPicture.asset("assets/icons/Ellipse.svg"),
        _job_stat_detail(
            "assets/icons/CurrencyDollar.svg", data.price.toString()),
        SvgPicture.asset("assets/icons/Ellipse.svg"),
        _job_stat_detail(
          "assets/icons/CalendarBlank.svg",
          "${DateTime.parse(data.deadline).year}-${DateTime.parse(data.deadline).month}-${DateTime.parse(data.deadline).day}",
        )
      ],
    );
  }

  Row _job_stat_detail(icon, text) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          color: Color(0xB2141414).withOpacity(0.7),
        ),
        SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: Color(0xB2141414).withOpacity(0.7),
            fontSize: 12,
          ),
        )
      ],
    );
  }
}
