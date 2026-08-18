import 'package:flut/consts/theme_colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final text;
  final icon;
  final callback;
  String? error_text;
  String intial_value;

  CustomTextField({
    super.key,
    required this.text,
    required this.icon,
    required this.callback,
    this.error_text = null,
    this.intial_value = "",
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: intial_value,
      onChanged: (val) {
        callback(val);
      },
      style: TextStyle(
        color: theme_colors.text_black,
      ),
      decoration: InputDecoration(
        label: Text(
          text,
          style: TextStyle(
            color: theme_colors.text_light,
          ),
        ),
        prefixIcon: Icon(
          icon,
          color: theme_colors.text_light,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        fillColor: theme_colors.input_background,
        filled: true,
        hintStyle: TextStyle(
          color: theme_colors.text_light,
        ),
        errorText: error_text,
      ),
    );
  }
}
