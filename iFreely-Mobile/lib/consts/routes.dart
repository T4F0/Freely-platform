import 'package:flut/models/feed_card.dart';
import 'package:flut/pages/ApplyToJobPage.dart';
import 'package:flut/pages/ChatRoom.dart';
import 'package:flut/pages/ChatsPage.dart';
import 'package:flut/pages/ClientMainPage.dart';
import 'package:flut/pages/CreateJobPage.dart';
import 'package:flut/pages/EditProfilePage.dart';
import 'package:flut/pages/FeedDetails.dart';
import 'package:flut/pages/FeedPage.dart';
import 'package:flut/pages/FiltersPopup.dart';
import 'package:flut/pages/FreelancerJobs.dart';
import 'package:flut/pages/FreelancerMainPage.dart';
import 'package:flut/pages/LoginPage.dart';
import 'package:flut/pages/ProfilePage.dart';
import 'package:flut/pages/ProposalPreviewPage.dart';
import 'package:flut/pages/ProposalsPage.dart';
import 'package:flut/pages/RegisterPage.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String main_page = "/";
  static const String freelancer_main_page = "/freelancer-main-page";
  static const String client_main_page = "/client-main-page";

  static const String wellcome_page = "/wellcome-page";
  static const String profile_page = "/profile-page";
  static const String proposals_page = "/proposals-page";
  static const String proposals_preview_page = "/proposals-preview-page";
  static const String login_page = "/login-page";
  static const String register_page = "/register-page";
  static const String feed_details_page = "/feed-details-page";
  static const String feed_page = "/feed-pastatic const";
  static const String feed_filter = "/feed-filter";
  static const String apply_to_job = "/apply-to-job";
  static const String create_job = "/create-job";
  static const String edit_profile = "/edit-profile";
  static const String freelancer_jobs = "/freelancer-jobs";

  static const String chats_page = "/chats";
  static const String chats_room = "/chats/room";

  static String intial_route = login_page;
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case freelancer_jobs:
        return MaterialPageRoute(
          builder: (_) => FreelancerJobs(),
        );

      case freelancer_main_page:
        return MaterialPageRoute(
          builder: (_) => FreelancerMainPage(),
        );
      case edit_profile:
        return MaterialPageRoute(
          builder: (_) => EditProfilePage(),
        );

      case client_main_page:
        return MaterialPageRoute(
          builder: (_) => ClientMainPage(),
        );

      case login_page:
        return MaterialPageRoute(
          builder: (_) => LoginPage(),
        );
      case chats_room:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return ChatRoom(
                id: (settings.arguments! as List)[0],
                otherUserId: (settings.arguments! as List)[1]);
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 1000),
          settings: settings,
        );
      case register_page:
        return MaterialPageRoute(
          builder: (_) => RegisterPage(),
        );
      case feed_page:
        return MaterialPageRoute(
          builder: (_) => FeedPage(),
        );
      case profile_page:
        return MaterialPageRoute(
          builder: (_) => ProfilePage(
            id: (settings.arguments == null)
                ? ""
                : (settings.arguments! as List)[0] as String,
          ),
        );
      case proposals_page:
        return MaterialPageRoute(
          builder: (_) => ProposalsPage(),
        );
      case proposals_preview_page:
        return MaterialPageRoute(
          builder: (_) => ProposalPreviewPage(
              jobID: (settings.arguments! as List)[0] as String,
              jobType: (settings.arguments! as List)[1] as String),
        );
      case feed_details_page:
        return MaterialPageRoute(
          builder: (_) => FeedDetails(
            typ: settings.arguments == null || (settings.arguments as List).length == 0
                ? ""
                : (settings.arguments as List)[0],
          ),
        );
      case feed_filter:
        return MaterialPageRoute(
          builder: (_) => FiltersPopup(),
        );
      case apply_to_job:
        var data = settings.arguments as FeedCard;
        return MaterialPageRoute(
          builder: (_) => ApplyToJobPage(feed_card: data),
        );
      case create_job:
        return MaterialPageRoute(
          builder: (_) => CreateJobPage(),
        );
      case chats_page:
        return MaterialPageRoute(
          builder: (_) => ChatsPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  const Routes();
}
