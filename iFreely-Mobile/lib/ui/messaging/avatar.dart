
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String image;
  final bool active;
  const Avatar({
    super.key,
    required this.image,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image(
          image: AssetImage(image),
          // width: 40,
        ),
        Visibility(
          visible: active,
          child: Positioned(
            top: 4,
            left: 4,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                  color: Color(0xFF2BEF83),
                  borderRadius: BorderRadius.circular(100)),
            ),
          ),
        ),
      ],
    );
  }
}
