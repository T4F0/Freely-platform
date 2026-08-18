import 'package:flut/consts/theme_colors.dart';
import 'package:flut/ui/icon_button.dart';
import 'package:flut/ui/text_devider.dart';
import 'package:flutter/material.dart';

class LoginRegisterFooter extends StatelessWidget {
  final String text;
  final String route;

  const LoginRegisterFooter({
    super.key,
    required this.context,
    required this.text,
    required this.route,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        TextDivider(),
        SizedBox(height: 20),
        CustomIconButton(
          callback: () {},
        ),
        SizedBox(height: 20),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Dont have an account yet?",
                style: TextStyle(
                  color: theme_colors.text_black,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, route);
                },
                child: Text(
                  text,
                  style: TextStyle(
                    color: theme_colors.accent_text_black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
