import 'package:flut/bloc/profile/profile_bloc.dart';
import 'package:flut/consts/routes.dart';
import 'package:flut/consts/theme_colors.dart';
import 'package:flut/ui/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  void initState() {
    context.read<ProfileBloc>().add(InitProfileInfo());
    super.initState();
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
    void update_profile() {
      Navigator.pop(context);
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
                  Image.asset("assets/pfp.png"),
                  _textField("First name", state.user.firstName),
                  SizedBox(height: 16),
                  _textField("Last name", state.user.lastName),
                  SizedBox(height: 16),
                  _textField("Bio", __info["description"] as String,
                      max_lines: 4),
                  SizedBox(height: 16),
                  _textField("Email", state.user.email),
                  SizedBox(height: 16),
                  _textField("CCP", state.user.ccp),
                  SizedBox(height: 16),
                  _textField("Phone number", state.user.phoneNumber),
                  SizedBox(height: 16),
                  _textField("Date of birth", state.user.dateOfBirth),
                  SizedBox(height: 16),
                  GradientButton(
                    callback: update_profile,
                    widget: Text(
                      "Update Profile",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    activated: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Column _textField(title, value, {max_lines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        TextFormField(
          initialValue: value.length == 0 ? "..." : value,
          maxLines: max_lines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            fillColor: theme_colors.input_background.withOpacity(0.5),
            filled: true,
          ),
        ),
      ],
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
      ],
    );
  }

  AppBar _appbar() {
    return AppBar(
      title: Text(
        "Edit Profile",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.white,
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
