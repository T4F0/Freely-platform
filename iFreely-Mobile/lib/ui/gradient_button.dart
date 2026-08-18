// ignore_for_file: must_be_immutable
import 'package:flut/consts/theme_colors.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final Function callback;
  final Widget widget;
  final bool activated;
  double borderRadius = 16.0;
  double width = -1;

  GradientButton({
    super.key,
    required this.callback,
    required this.widget,
    this.activated = false,
    this.borderRadius = 16.0,
    this.width = -1,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: width == -1 ?  250 : width,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              theme_colors.btn_gradient[0].withOpacity(activated ? 1 : 0.7),
              theme_colors.btn_gradient[1].withOpacity(activated ? 1 : 0.7),
            ],
          ),
          boxShadow: activated
              ? [
                  BoxShadow(
                    blurRadius: 16.0,
                    offset: Offset(0, 4),
                    spreadRadius: 4,
                    color: Color(0x4DCF4EFC),
                  ),
                ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: activated
              ? () {
                  callback();
                }
              : null,
          child: widget,
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              foregroundColor: MaterialStateProperty.all(Colors.transparent),
              shadowColor: MaterialStateProperty.all(Colors.transparent),
              padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(vertical: 15, horizontal: 10)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              )),
        ),
      ),
    );
  }
}
