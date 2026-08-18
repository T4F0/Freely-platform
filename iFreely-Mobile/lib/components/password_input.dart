import 'package:flut/consts/theme_colors.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final Function update_password;
  String intial_value;
  String? error_text;
  PasswordField({
    super.key,
    required this.update_password,
    this.error_text = null,
    this.intial_value = "",
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool text_obscure = true;

  void toggle_obscure() {
    setState(() {
      text_obscure = !text_obscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.intial_value,
      onChanged: (val) {
        widget.update_password(val);
      },
      obscureText: text_obscure,
      style: TextStyle(
        color: theme_colors.text_black,
      ),
      decoration: InputDecoration(
        label: Text(
          "Password",
          style: TextStyle(
            color: theme_colors.text_light,
          ),
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: theme_colors.text_light,
        ),
        suffixIcon: GestureDetector(
          onTap: toggle_obscure,
          child: Icon(
            text_obscure ? Icons.remove_red_eye_outlined : Icons.remove_red_eye,
            color: theme_colors.text_light,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        fillColor: theme_colors.input_background,
        filled: true,
        errorText: widget.error_text,
      ),
    );
  }
}
