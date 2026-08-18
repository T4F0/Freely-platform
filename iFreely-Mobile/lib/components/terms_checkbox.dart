
import 'package:flut/consts/theme_colors.dart';
import 'package:flutter/material.dart';

class TermsCheckbox extends StatefulWidget {
  const TermsCheckbox({
    super.key,
  });

  @override
  State<TermsCheckbox> createState() => _TermsCheckboxState();
}
class _TermsCheckboxState extends State<TermsCheckbox> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: 50,
          child: Checkbox(
            value: checked,
            onChanged: (val) {
              setState(() {
                checked = val ?? false;
              });
            },
            activeColor: theme_colors.primary_color,
          ),
        ),
        Expanded(
          child: Text(
            "By continuing you agree to terms and conditions",
            style: TextStyle(
              fontSize: 15,
              color: theme_colors.text_black,
            ),
          ),
        ),
      ],
    );
  }
}
