// ignore_for_file: must_be_immutable
import 'package:flut/models/job_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FeedJobCard extends StatelessWidget {
  final JobModel jobModel;

  FeedJobCard({super.key, required this.jobModel});

  var card_data = {
    "icon": "assets/django.png",
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.symmetric(horizontal: 15),
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
          Text(
            jobModel.description,
            style: TextStyle(
              color: Color(0xB2141414).withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Row _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // put user pfp here
        Image.asset(card_data["icon"]!),

        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(jobModel.username), // card_data["username"]!),
            SizedBox(height: 5),
            Text(
              jobModel.job_title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0x1A504099),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                "New post",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7D5AE2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Row _stat() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _job_stat_detail("assets/icons/Clock.svg", jobModel.payment_structure),
        SvgPicture.asset("assets/icons/Ellipse.svg"),
        _job_stat_detail(
            "assets/icons/CurrencyDollar.svg", jobModel.rate.toString()),
        SvgPicture.asset("assets/icons/Ellipse.svg"),
        _job_stat_detail(
          "assets/icons/CalendarBlank.svg",
          DateTime.parse(jobModel.deadline).year.toString() +
              "-" +
              DateTime.parse(jobModel.deadline).month.toString() +
              "-" +
              DateTime.parse(jobModel.deadline).day.toString(),
        ),
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
