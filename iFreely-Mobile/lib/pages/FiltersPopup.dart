// ignore_for_file: must_be_immutable

import 'package:flut/bloc/feed/feed_bloc.dart';
import 'package:flut/ui/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FiltersPopup extends StatefulWidget {
  FiltersPopup({super.key});

  @override
  State<FiltersPopup> createState() => _FiltersPopupState();
}

class _FiltersPopupState extends State<FiltersPopup> {
  int rate_idx = 0;
  int type_idx = 0;
  int date_idx = 0;

  var filters = [
    {
      "title": "Gig rate",
      "options": [
        "> 30",
        "> 50",
        "> 80",
        "> 100",
      ],
    },
    {
      "title": "Date of posting",
      "options": [
        "All time",
        "Last 24 hours",
        "Last 3 days",
        "Last 7 days",
      ],
    },
    {
      "title": "Type of payement",
      "options": [
        "Any",
        "Full project",
        "Hourly",
      ],
      "square": true,
    },
  ];

  void on_back_clicked() {

    context.read<FeedBloc>().add(
          FeedLoad(
              rate: ((filters[0]["options"] as List)[rate_idx] as String).substring(2)            ,
              date: date_idx == 0 ? null : ((filters[1]["options"] as List)[date_idx] as String)  ,
              type: type_idx == 0 ? null : ((filters[2]["options"] as List)[type_idx] as String) ),
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
            left: 20,
            top: AppBar().preferredSize.height,
          ),
          child: Column(
            children: [
              _heading(context),
              ...filters.map(
                (filter) => Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: FilterList(
                      title: filter["title"]!,
                      options: filter["options"] as List,
                      square_checkbox: (filter["square"] ?? false) as bool,
                      onSelectFilter: (idx) {
                        if (filter["title"]! == "Gig rate") {
                          rate_idx = idx;
                        } else if (filter["title"]! == "Date of posting") {
                          date_idx = idx;
                        } else {
                          type_idx = idx;
                        }
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _heading(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Filters",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        IconButton(
            onPressed: () => on_back_clicked(),
            icon: Icon(Icons.arrow_forward, size: 30))
      ],
    );
  }
}
