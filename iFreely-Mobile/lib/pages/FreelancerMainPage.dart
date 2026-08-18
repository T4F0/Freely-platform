import 'package:flut/bloc/nav/nav_bloc.dart';
import 'package:flut/pages/ChatsPage.dart';
import 'package:flut/pages/FeedPage.dart';
import 'package:flut/pages/FreelancerJobs.dart';
import 'package:flut/pages/ProfilePage.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FreelancerMainPage extends StatefulWidget {
  FreelancerMainPage({super.key});

  @override
  State<FreelancerMainPage> createState() => _FreelancerMainPageState();
}

class _FreelancerMainPageState extends State<FreelancerMainPage> {
  @override
  void initState() {
    context.read<AuthRepo>().load_auth_from_session();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NavBloc>(
      create: (context) => NavBloc(),
      child: BlocBuilder<NavBloc, NavState>(
        builder: (context, state) {
          if (state is NavIndex) {
            return Scaffold(
                resizeToAvoidBottomInset: false,
                bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: Colors.white,
                  items: navBarItems,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  currentIndex: state.index,
                  onTap: (int index) {
                    context.read<NavBloc>().add(NavChange(index));
                  },
                ),
                body: <Widget>[
                  FeedPage(),
                  ChatsPage(),
                  FreelancerJobs(),
                  ProfilePage(),
                ][state.index]);
          } else {
            throw Exception("Unknown state: $state");
          }
        },
      ),
    );
  }
}

List<BottomNavigationBarItem> navBarItems = [
  const BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon:
        Icon(Icons.home_outlined, color: Color.fromARGB(255, 180, 136, 194)),
    label: "home",
  ),
  const BottomNavigationBarItem(
    icon: Icon(Icons.chat),
    activeIcon: Icon(Icons.chat, color: Color.fromARGB(255, 180, 136, 194)),
    label: "chat",
  ),
  const BottomNavigationBarItem(
    icon: Icon(Icons.work),
    activeIcon:
        Icon(Icons.work, color: Color.fromARGB(255, 180, 136, 194)),
    label: "work",
  ),
  const BottomNavigationBarItem(
    icon: Icon(Icons.person),
    activeIcon: Icon(Icons.person, color: Color.fromARGB(255, 180, 136, 194)),
    label: "profile",
  ),
];
