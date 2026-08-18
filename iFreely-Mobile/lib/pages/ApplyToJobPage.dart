// ignore_for_file: must_be_immutable

import 'package:flut/consts/theme_colors.dart';
import 'package:flut/models/feed_card.dart';
import 'package:flut/repos/feed_repo.dart';
import 'package:flut/ui/client_info_gig.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApplyToJobPage extends StatefulWidget {
  FeedCard feed_card;
  ApplyToJobPage({super.key, required this.feed_card});

  @override
  State<ApplyToJobPage> createState() => _ApplyToJobPageState();
}

class _ApplyToJobPageState extends State<ApplyToJobPage> {
  String deadline = "Deadline";
  void update_date(DateTime time) {
    setState(() {
      deadline =
          "${time.year.toString()}-${time.month.toString()}-${time.day.toString()}";
    });
  }

  late TextEditingController rate_controller;
  late TextEditingController description_controller;
  @override
  void initState() {
    rate_controller = TextEditingController();
    description_controller = TextEditingController();
    super.initState();
  }

  var gig_info = {
    "icon": "assets/django.png",
    "job-title": "Django bug fixing",
  };

  var client_info = {
    "profile-picture": "assets/icons/placehoder_img.png",
    "name": "Echidna Greed",
    "bio":
        "Quis eiusmod deserunt cillum laboris magna cupidatat esse labore irure quis cupidatat in. Mollit in laborum tempor Lorem incididunt irure.",
    "stars": 5,
  };

  void send_proposal(BuildContext context) async {
    try {
      await context.read<FeedRepo>().send_propsal(
          widget.feed_card.id,
          description_controller.text,
          int.parse(rate_controller.text),
          deadline);
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("proposal sent!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appbar(),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              SizedBox(height: 40),
              _description(),
              SizedBox(height: 20),
              _rate_deadline(),
              SizedBox(height: 50),
              _send_proposal_btn(context),
              SizedBox(height: 40),
              // ClientInfo(client_info: client_info),
            ],
          ),
        ),
      ),
    );
  }

  Container _send_proposal_btn(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () => send_proposal(context),
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
          "Send Proposal",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Row _rate_deadline() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text( "Rate"),
            SizedBox(
              width: 200,
              height: 46,
              child: TextField(
                controller: rate_controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.grey),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  label: Text(
                    "Rate",
                    style: TextStyle(color: Colors.grey),
                  ),
                  suffix: Text("DA"),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
              ),
            ),
          ],
        ),
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     RequiredText(text: "Time"),
        //     SizedBox(
        //       width: 100,
        //       height: 46,
        //       child: TextField(
        //         readOnly: true,
        //         onTap: () {
        //           showDatePicker(
        //             context: context,
        //             initialDate: DateTime.now(),
        //             firstDate: DateTime(2019, 1),
        //             lastDate: DateTime(2025, 12),
        //           ).then((pickedDate) {
        //             update_date(pickedDate!);
        //           });
        //         },
        //         decoration: InputDecoration(
        //           border: OutlineInputBorder(
        //             borderSide: BorderSide(width: 1, color: Colors.grey),
        //           ),
        //           enabledBorder: OutlineInputBorder(
        //             borderSide: BorderSide(width: 1, color: Colors.grey),
        //           ),
        //           focusedBorder: OutlineInputBorder(
        //             borderSide: BorderSide(width: 1, color: Colors.grey),
        //           ),
        //           // contentPadding:
        //           // EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        //           hintText: deadline,
        //           hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
        //           floatingLabelBehavior: FloatingLabelBehavior.never,
        //         ),
        //       ),
        // ),
        // ],
        // ),
      ],
    );
  }

  Column _description() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RequiredText(text: "Proposal Description"),
        SizedBox(height: 5),
        TextField(
          controller: description_controller,
          minLines: 5,
          maxLines: 10,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: Colors.grey),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            hintText: "Description",
            hintStyle: TextStyle(
              color: Color(0xFFB8BCCA),
            ),
          ),
        ),
      ],
    );
  }

  Widget _header() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Image.asset(widget.feed_card.logo),
          SizedBox(width: 32),
          Flexible(
            child: Text(
              widget.feed_card.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
        "Apply to gig",
        style: TextStyle(
          color: theme_colors.text_black,
        ),
      ),
      backgroundColor: theme_colors.background,
      foregroundColor: theme_colors.background,
      surfaceTintColor: theme_colors.background,
      shadowColor: Colors.grey.withOpacity(0.2),
      elevation: 5,
      iconTheme: IconThemeData(
        color: theme_colors.text_light,
      ),
    );
  }
}

class RequiredText extends StatelessWidget {
  final String text;
  const RequiredText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Color(0xB2141414),
        ),
        children: [
          TextSpan(
            text: "  *",
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
