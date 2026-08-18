import 'package:flut/consts/theme_colors.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: TextField(
        style: TextStyle(
          color: theme_colors.text_black
        ),
        decoration: InputDecoration(
          label: Text(
            "Search",
            style: TextStyle(
              color: theme_colors.text_light,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          fillColor: theme_colors.input_background,
          filled: true,
          suffixIcon: Icon(
            Icons.search,
            color: theme_colors.text_light,
          ),
        ),
      ),
    );
  }
}