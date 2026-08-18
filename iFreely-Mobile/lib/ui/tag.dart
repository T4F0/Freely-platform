import 'package:flut/consts/theme_colors.dart';
import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  final String text;
  const Tag({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          margin: EdgeInsets.only(right: 4, left: 4),
          decoration: BoxDecoration(
            color: theme_colors.primary_color.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: theme_colors.text_black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
