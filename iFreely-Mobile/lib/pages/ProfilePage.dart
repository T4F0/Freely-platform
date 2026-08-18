import 'package:flut/bloc/freelancer_jobs/freelancer_jobs_bloc.dart';
import 'package:flut/bloc/profile/profile_bloc.dart';
import 'package:flut/consts/routes.dart';
import 'package:flut/consts/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  String id;

  ProfilePage({super.key, this.id = ""});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void init() async {}
  @override
  void initState() {
    context.read<FreelancerJobsBloc>().add(FreelancerLoadJobs());
    context.read<ProfileBloc>().add(InitProfileInfo(id: widget.id));

    super.initState();
  }

  void edit_profile() {
    Navigator.pushNamed(context, Routes.edit_profile);
  }

  void logout() {
    Navigator.pushReplacementNamed(context, Routes.login_page);
  }

  @override
  Widget build(BuildContext context) {
    var __info = {
      "description":
          "Quis eiusmod deserunt cillum laboris magna cupidatat esse labore irure quis cupidatat in. Mollit in laborum tempor Lorem incididunt irure.",
      "completed_jobs": "60",
      "money_made": "500",
      "active_jobs": "2",
    };

    void on_update(typ, val) {
      context.read<ProfileBloc>().add(
            UpdateProfileInfo(
              {
                typ: val,
              },
            ),
          );
    }

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _appbar(),
          body: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  state.user.photo.length == 0
                      ? Image.asset("assets/pfp.png")
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            state.user.photo,
                            width: 100,
                            height: 100,
                          ),
                        ),
                  SizedBox(height: 16),
                  _pfp_info(state),
                  SizedBox(height: 16),
                  Text(
                    state.user.bio,
                    // __info["description"] as String,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  _stats(__info),
                  SizedBox(height: 32),
                  _presonal_info(context, state, on_update),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Container _presonal_info(
      BuildContext context, ProfileState state, void on_update(typ, val)) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personal info",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 16),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  _infoArea("Money", state.user.moneySum.toString() + " DA"),
                  SizedBox(height: 16),
                  _infoArea("Email", state.user.email),
                  SizedBox(height: 16),
                  _infoArea("CCP", state.user.ccp),
                  SizedBox(height: 16),
                  _infoArea("phone number", state.user.phoneNumber),
                  SizedBox(height: 16),
                  _infoArea("date of birth", state.user.dateOfBirth),
                ],
              ))
        ],
      ),
    );
  }

  Row _infoArea(text, val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(val.length != 0 ? val : "unavaiable",
            style: TextStyle(
                fontSize: 16,
                color: val.length == 0 ? Colors.grey : Colors.black)),
      ],
    );
  }

  Widget _stats(Map<String, Object> __info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Job info",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        BlocBuilder<FreelancerJobsBloc, FreelancerJobsState>(
          builder: (context, state) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                stat_column("Active Jobs", state.active_jobs.length.toString()),
                stat_column("Jobs Completed", state.archived_jobs.length.toString()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget stat_column(title, stat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          stat,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme_colors.text_light,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _pfp_info(ProfileState state) {
    return Column(
      children: [
        Text(
          state.user.firstName + " " + state.user.lastName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 4),
        Text(
          state.user.role,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  AppBar _appbar() {
    return AppBar(
      title: Text(
        "Profile",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.white,
      actions: [
        IconButton(onPressed: edit_profile, icon: Icon(Icons.edit)),
        IconButton(onPressed: logout, icon: Icon(Icons.login)),
      ],
    );
  }
}

class ShowAndEdit extends StatefulWidget {
  const ShowAndEdit({
    super.key,
    required this.title,
    required this.value,
    required this.on_update,
  });

  final String title;
  final String value;
  final Function on_update;

  @override
  State<ShowAndEdit> createState() => _ShowAndEditState();
}

class _ShowAndEditState extends State<ShowAndEdit> {
  var editing = false;
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    controller.text = widget.value;
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              editing = !editing;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    !editing ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                    color: theme_colors.text_light,
                  ),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                widget.value,
                style: TextStyle(
                  color: theme_colors.text_light,
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: editing,
          maintainAnimation: true,
          maintainState: true,
          child: Column(
            children: [
              SizedBox(height: 4),
              TextFormField(
                controller: controller,
                style: TextStyle(
                  color: theme_colors.text_black,
                ),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                ),
              ),
              Column(
                children: [
                  SizedBox(height: 4),
                  Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      onPressed: () => widget.on_update(controller.text),
                      child: Text("update"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
