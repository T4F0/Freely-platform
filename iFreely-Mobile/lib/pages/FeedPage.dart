// ignore_for_file: must_be_immutable

import 'package:flut/bloc/feed/feed_bloc.dart';
import 'package:flut/consts/init_user.dart';
import 'package:flut/consts/routes.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flut/repos/feed_repo.dart';
import 'package:flut/ui/feed_gig_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FeedPage extends StatefulWidget {
  FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late TextEditingController search_controller; 

  @override
  void initState() {
    //NOTE: Should not be here, change it in the future
    context.read<FeedBloc>().add(FeedLoad());
    search_controller = TextEditingController();
    super.initState();
  }





  void on_sort_click() {
    Navigator.pushNamed(context, Routes.feed_filter);
  }

  void _generate_feed() {
    context.read<FeedRepo>().generate_jobs();
  }


  void on_search() {


    context.read<FeedBloc>().add(
          FeedLoad(
            query : search_controller.text.length == 0 ? null : search_controller.text ,
          )
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {
        if(state.status == FeedStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Network Error")));
        }
      },
      builder: (context, state) {
        return BlocBuilder<FeedBloc, FeedState>(builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: _appbar(),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _search_bar(),
                  Container(
                    padding: EdgeInsets.only(top: 24),
                    width: MediaQuery.of(context).size.width,
                    color: Color(0xFFFAFAFA),
                    child: Column(
                      children: [
                        _jobs_info_header(state),
                        SizedBox(height: 24),
                        _job_list(state),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                  // ElevatedButton(onPressed: () {
                  //   _generate_feed();
                  // }, child: Text("Generate Feed")),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Container _search_bar() {


    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: TextField(
        onSubmitted: (s) => on_search(),
        controller: search_controller,
        decoration: InputDecoration(
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.grey),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            hintText: "What job are you looking for ?",
            
            suffixIcon: GestureDetector(
              onTap: on_search,
              child: Container(
                padding: EdgeInsets.all(10),
                child: SvgPicture.asset(
                  "assets/icons/search.svg",
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF864AF9),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
              ),
            )),
      ),
    );
  }

  Container _jobs_info_header(state) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child:
             Align(
              alignment: Alignment.topLeft,
              child: Text(
                "${state.feed.length} Gigs",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              on_sort_click();
            },
            child: Text(
              "Filter by",
            ),
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2.5,
                ),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(
                Colors.white,
              ),
              overlayColor: MaterialStateProperty.all<Color>(
                Colors.white,
              ),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
              surfaceTintColor: MaterialStateProperty.all<Color>(
                Colors.white,
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _job_list(state) {
    return (() {
      switch (state.status) {
        case FeedStatus.loading:
          return CircularProgressIndicator();
        case FeedStatus.loaded:
          if (state.feed.isNotEmpty) {
            return Column(children: [
              ...state.feed.map(
                (feed_card) => FeedGigCard(data: feed_card),
              )
            ]);
          }
        default:
          break;
      }
      return Text(
        "No Gigs Available",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    })();
  }

  AppBar _appbar() {
    return AppBar(
      title: Text("Feed"),
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.white,
      elevation: 5,
      shadowColor: Colors.grey.withOpacity(0.2),
    );
  }
}
