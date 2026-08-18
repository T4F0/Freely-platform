import 'package:flut/consts/theme_colors.dart';
import 'package:flut/ui/styled_button.dart';
import 'package:flut/ui/tag.dart';
import 'package:flutter/material.dart';

class WorkRequestCard extends StatelessWidget {
  final Function details_callback;

  const WorkRequestCard({
    super.key,
    required this.details_callback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Title",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme_colors.text_black),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.heart_broken_outlined,
                        size: 18,
                        color: theme_colors.text_light,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "5000 DZD",
                        style: TextStyle(
                          color: theme_colors.text_light,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 10),
              RichText(
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                strutStyle: StrutStyle(
                  fontSize: 14,
                ),
                text: TextSpan(
                  text:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque nec erat enim. Nullam sapien nisi, vestibulum id ex sit amet, cursus feugiat eros. Pellentesque vestibulum semper molestie. Nam ac tellus sit amet nisi iaculis ultrices ut vitae dui. Vestibulum a posuere turpis. Proin lectus orci, pellentesque et mattis in, cursus sit amet velit. Nulla gravida sollicitudin porttitor. Cras sed neque finibus mauris varius interdum. Nulla facilisi.",
                  style: TextStyle(
                    color: theme_colors.text_black.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 18),
              Row(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Tag(text: "tags"),
                        Tag(text: "tags"),
                        Tag(text: "tags"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Posted 20 minutes ago",
                    style: TextStyle(
                        fontSize: 12, color: theme_colors.text_light),
                  ),
                  StyledButton(
                    text: Text(
                      "More Details",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    callback: details_callback,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
