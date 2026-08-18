// ignore_for_file: must_be_immutable
import 'package:flut/consts/theme_colors.dart';
import 'package:flutter/material.dart';

class StyledButton extends StatelessWidget {
  StyledButton({
    super.key,
    required this.callback,
    required this.text,
    this.border_radius = 12,
  });

  final Function callback;
  final Widget text;
  double? border_radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          blurRadius: 10,
          color: Color(0x409E24D7),
        ),
      ]),
      child: ElevatedButton(
        onPressed: () {
          callback();
        },
        child: text,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(border_radius!),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            theme_colors.btn_gradient[0].withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
