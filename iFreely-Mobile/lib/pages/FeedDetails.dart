// ignore_for_file: must_be_immutable
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flut/bloc/feed/feed_bloc.dart';
import 'package:flut/consts/routes.dart';
import 'package:flut/consts/server.dart';
import 'package:flut/consts/theme_colors.dart';
import 'package:flut/models/feed_card.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flut/repos/graphql.dart';
import 'package:flut/ui/client_info_gig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedDetails extends StatefulWidget {
  String typ = "";
  FeedDetails({super.key, this.typ = ""});

  @override
  State<FeedDetails> createState() => _FeedDetailsState();
}

class _FeedDetailsState extends State<FeedDetails> {
  void apply_to_job(BuildContext context) {
    Navigator.pushNamed(
      context,
      Routes.apply_to_job,
      arguments: context.read<FeedBloc>().state.selected_feed,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void finish_job(state) async {
    var res;
    print(state.selected_feed.id);
    print(context.read<AuthRepo>().user_model!.id);
    print(context.read<AuthRepo>().user_model!.token);
    try {
      res = await Dio().post(
        GRAPHQL_SERVER,
        data: GraphQLRequester.get_chargily_link( context.read<AuthRepo>().user_model!.id, state.selected_feed.id),
        options: Options(
          headers: {
            "authorization": context.read<AuthRepo>().user_model!.token,
          },
          validateStatus: (status) => true,
        ),
      );
    } catch (e) {
      rethrow;
    }


    var res1;
    try {
      res1 = await Dio().post(
        GRAPHQL_SERVER,
        data: GraphQLRequester.validate_job( context.read<AuthRepo>().user_model!.id, state.selected_feed.id),
        options: Options(
          headers: {
            "authorization": context.read<AuthRepo>().user_model!.token,
          },
          validateStatus: (status) => true,
        ),
      );
    } catch (e) {
      rethrow;
    }    


    await launchUrl(Uri.parse(res.data["data"]["getChargilyLink"]["url"]));



   
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        return Scaffold(
          appBar: _appbar(),
          body: SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.only(top: 40, bottom: 20, left: 30, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(state.selected_feed),
                  SizedBox(height: 30),
                  _quick_info(state.selected_feed),
                  SizedBox(height: 30),
                  _description(state.selected_feed),
                  SizedBox(height: 30),
                  _files(state.selected_feed),
                  SizedBox(height: 30),
                  _pay_info(state.selected_feed),
                  SizedBox(height: 30),
                  _skills(state.selected_feed),
                  SizedBox(height: 30),
                  _action_btns(context),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _action_btns(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(builder: (context, state) {
      return Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                !widget.typ.contains("archive") &&
                        !widget.typ.contains("active")
                    ? ElevatedButton(
                        onPressed: () => apply_to_job(context),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Color(0xFF7360DF),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        child: Text(
                          "${widget.typ == '' ? 'Apply to Job' : 'Update Proposal'}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : SizedBox(),
                widget.typ != "client-active"
                    ? SizedBox()
                    : ElevatedButton(
                        onPressed: () => finish_job(state),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Color(0xFF7360DF),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        child: Text(
                          "Finish Job",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ]
      );
    });
  }

  Column _skills(FeedCard data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Skills & technologies :",
          style: TextStyle(fontSize: 17),
        ),
        SizedBox(height: 10),
        Wrap(
          children: [
            data.skills.length == 0
                ? Text(
                    "      No Skills required",
                    style: TextStyle(color: Colors.grey),
                  )
                : SizedBox(),
            ...data.skills.map(
              (skill) => Container(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                margin: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0x80D9D9D9),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    color: Color(0xFF161455),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Row _pay_info(FeedCard data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ColumnTextText(
          title: "Pay Structure",
          text: data.payment_type,
        ),
        ColumnTextText(
          title: "Pay Method",
          text: data.payement_method,
        ),
      ],
    );
  }

  Column _files(FeedCard data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Attachements:",
          style: TextStyle(
            fontSize: 17,
            color: Color(0xFF333333),
          ),
        ),
        SizedBox(height: 10),
        ...data.attachements.length == 0
            ? [Text("    No attachements")]
            : (data.attachements).map(
                (attachement) => Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            "attachement.icon",
                          ),
                          SizedBox(width: 20),
                          Text(
                            (attachement["link"] as String).substring(
                                    0, min(20, attachement["link"].length)) +
                                "...",
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xB2141414),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Text _description(FeedCard data) {
    return Text(
      data.description,
      style: TextStyle(
        height: 1.5,
        color: Color(0xB2141414),
      ),
    );
  }

  Row _quick_info(FeedCard data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ColumnIconText(
          icon: "assets/icons/Clock.svg",
          text: data.payment_type as String,
        ),
        ColumnIconText(
          icon: "assets/icons/CurrencyDollar.svg",
          text: data.price.toString() + " DA",
        ),
        ColumnIconText(
          icon: "assets/icons/CalendarBlank.svg",
          text:
              "${DateTime.parse(data.deadline).year}-${DateTime.parse(data.deadline).month}-${DateTime.parse(data.deadline).day}",
        )
      ],
    );
  }

  Widget _title(FeedCard data) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(data.logo),
          SizedBox(width: 32),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                data.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        "Gig",
        style: TextStyle(
          color: theme_colors.text_black,
        ),
      ),
      backgroundColor: theme_colors.background,
      foregroundColor: theme_colors.background,
      surfaceTintColor: theme_colors.background,
      shadowColor: Colors.grey.withOpacity(0.2),
      elevation: 5,
      actions: [],
      iconTheme: IconThemeData(
        color: theme_colors.text_light,
      ),
    );
  }
}
