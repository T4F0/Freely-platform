
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ClientInfo extends StatelessWidget {
  const ClientInfo({
    super.key,
    required this.client_info,
  });

  final Map<String, Object> client_info;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Client Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 30),
        Image.asset(client_info["profile-picture"] as String),
        SizedBox(height: 12),
        Text(
          client_info["name"] as String,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        SizedBox(height: 12),
        Text(
          client_info["bio"] as String,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xCC141414),
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...() {
              var stars = [];
              for (var i = 0; i < (client_info["stars"] as num); i++) {
                stars.add(Container(
                  margin: EdgeInsets.symmetric(horizontal: 1),
                  child: SvgPicture.asset("assets/icons/star.svg"),
                ));
              }
    
              return stars;
            }()
          ],
        )
      ],
    );
  }
}

class ColumnTextText extends StatelessWidget {
  final text;
  final title;

  const ColumnTextText({
    super.key,
    required this.text,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(
            color: Color(0xFF6F7482),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class ColumnIconText extends StatelessWidget {
  final icon;
  final text;
  const ColumnIconText({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          icon,
          width: 24,
          height: 24,
          color: Colors.black.withOpacity(0.6),
        ),
        SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(
            color: Colors.black.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
