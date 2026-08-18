// SVG assets not working/not available
// fixed some navigation

import 'package:flut/bloc/messaging/messaging_bloc.dart';
import 'package:flut/bloc/register/register_bloc.dart';
import 'package:flut/components/custom_inputfiled.dart';
import 'package:flut/components/login_register_footer.dart';
import 'package:flut/components/password_input.dart';
import 'package:flut/consts/routes.dart';
import 'package:flut/consts/theme_colors.dart';
import 'package:flut/models/register_model.dart';
import 'package:flut/models/user_model.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flut/ui/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:textfield_tags/textfield_tags.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterModel model = RegisterModel.init();
  int current_stage = 0;

  void set_stage(idx) {
    if (idx < 0 || idx > 3) {
      throw ("[Error] Invalid registeration stage got '${idx}'");
    }

    setState(() {
      current_stage = idx;
    });
  }

  _show_error_snackbar(register_error) {
    String error_msg = "";
    switch (register_error) {
      case RegisterError.email:
        error_msg = "email already used";
        break;
      case RegisterError.network:
        error_msg = "network problem";
        break;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error_msg)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.status == RegisterStatus.failed) {
          _show_error_snackbar(state.error);
        } else if (state.status == RegisterStatus.success) {
          BlocProvider.of<MessagingBloc>(context).add(
            MessagingCreateUser(
              RepositoryProvider.of<AuthRepo>(context).user_model!.id,
              RepositoryProvider.of<AuthRepo>(context)
                  .user_model!
                  .role
                  .toLowerCase(),
              RepositoryProvider.of<AuthRepo>(context).user_model!.firstName +
                  " " +
                  RepositoryProvider.of<AuthRepo>(context).user_model!.lastName,
            ),
          );

          if (state.role == FREELACNER) {
            Navigator.pushReplacementNamed(
                context, Routes.freelancer_main_page);
          } else {
            Navigator.pushReplacementNamed(context, Routes.client_main_page);
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: [
            RegisterFirstPage(set_stage: set_stage),
            RegisterSecondPage(set_stage: set_stage),
            BlocBuilder<RegisterBloc, RegisterState>(builder: (context, state) {
              print(state.role);
              if (state.role == FREELACNER) {
                return FreelancerRegister(
                  set_stage: set_stage,
                );
              }
              return ClientRegister(
                set_stage: set_stage,
              );
            }),
          ][current_stage],
        ),
      ),
    );
  }
}

class RegisterFirstPage extends StatefulWidget {
  final set_stage;
  const RegisterFirstPage({super.key, required this.set_stage});

  @override
  State<RegisterFirstPage> createState() => _RegisterFirstPageState();
}

class _RegisterFirstPageState extends State<RegisterFirstPage> {
  bool btn_active = false;
  var first_name = "";
  var last_name = "";
  var email = "";
  var password = "";

  void on_change_firstname(val) {
    first_name = val;
    activate_register_button();
  }

  void on_change_lastname(val) {
    last_name = val;
    activate_register_button();
  }

  void on_change_email(val) {
    email = val;
    activate_register_button();
  }

  void on_change_password(val) {
    password = val;
    activate_register_button();
  }

  void activate_register_button() {
    if (!btn_active &&
        first_name != "" &&
        last_name != "" &&
        email != "" &&
        password != "") {
      setState(() {
        btn_active = true;
      });
      return;
    }

    if (btn_active &&
        !(first_name != "" &&
            last_name != "" &&
            email != "" &&
            password != "")) {
      setState(() {
        btn_active = false;
      });
    }
  }

  next_stage() {
    context.read<RegisterBloc>().add(
          RegisterFirstStageSubmit(
            first_name = first_name,
            last_name = last_name,
            email = email,
            password = password,
          ),
        );
    widget.set_stage(1);
  }

  @override
  void initState() {
    RegisterState state = context.read<RegisterBloc>().state;
    first_name = state.first_name;
    last_name = state.last_name;
    email = state.email;
    password = state.password;

    activate_register_button();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      "Hi there,",
                      style: TextStyle(
                        color: theme_colors.text_black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Create an account",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: theme_colors.text_black,
                      ),
                    ),
                    SizedBox(height: 10),
                    _input_area(state)
                  ],
                ),
                SizedBox(height: 20),
                GradientButton(
                  activated: btn_active,
                  widget: Center(
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  callback: () {
                    next_stage();
                  },
                ),
                SizedBox(height: 20),
                LoginRegisterFooter(
                  context: context,
                  text: "Login",
                  route: Routes.login_page,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Column _input_area(RegisterState state) {
    return Column(
      children: [
        CustomTextField(
          text: "First Name",
          icon: Icons.person_2_outlined,
          callback: on_change_firstname,
          intial_value: state.first_name,
        ),
        SizedBox(height: 10),
        CustomTextField(
          text: "Last Name",
          icon: Icons.person_2_outlined,
          callback: on_change_lastname,
          intial_value: state.last_name,
        ),
        SizedBox(height: 10),
        CustomTextField(
          text: "Email",
          icon: Icons.email_outlined,
          callback: on_change_email,
          intial_value: state.email,
        ),
        SizedBox(height: 10),
        PasswordField(
          update_password: on_change_password,
          intial_value: state.password,
        ),
        SizedBox(height: 10),
        // TermsCheckbox(),
        SizedBox(height: 15),
      ],
    );
  }
}

class RegisterSecondPage extends StatefulWidget {
  final set_stage;
  const RegisterSecondPage({super.key, required this.set_stage});
  @override
  State<RegisterSecondPage> createState() => _RegisterSecondPageState();
}

class _RegisterSecondPageState extends State<RegisterSecondPage> {
  bool is_activated_second_stage = false;
  String birthday = "Birthday";
  String phone_number = "";
  String wilaya = "";
  String job_title = "";
  String role = CLIENT;

  void update_date(DateTime time) {
    setState(() {
      birthday =
          "${time.year.toString()}-${time.month.toString()}-${time.day.toString()}";
    });
    toggle_next_btn();
  }

  void update_phone_number(val) {
    phone_number = val;
    toggle_next_btn();
  }

  void update_wilaya(val) {
    wilaya = val;
    toggle_next_btn();
  }

  void update_job_title(val) {
    job_title = val;
    toggle_next_btn();
  }

  void upload_image() async {
    final ImagePicker picker = ImagePicker();
    await picker.pickImage(source: ImageSource.gallery);
  }

  void toggle_next_btn() {
    if (!is_activated_second_stage &&
        phone_number != "" &&
        wilaya != "" &&
        job_title != "" &&
        birthday != "Birthday") {
      setState(() {
        is_activated_second_stage = true;
      });
      return;
    }

    if (is_activated_second_stage &&
        !(phone_number != "" &&
            wilaya != "" &&
            job_title != "" &&
            birthday != "Birthday")) {
      setState(() {
        is_activated_second_stage = false;
      });
    }
  }

  next_stage() {
    context.read<RegisterBloc>().add(
          RegisterSecondStageSubmit(
            birthday = birthday,
            phone_number = phone_number,
            wilaya = wilaya,
            job_title = job_title,
            role = role,
          ),
        );
    widget.set_stage(2);
  }

  @override
  void initState() {
    RegisterState state = context.read<RegisterBloc>().state;
    birthday = state.birthday;
    phone_number = state.phone_number;
    wilaya = state.wilaya;
    job_title = state.job_title;
    toggle_next_btn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              _upload_pp(context),
              SizedBox(height: 50),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    _input_area(context, state),
                    SizedBox(height: 10),
                    _footer(context),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Column _input_area(BuildContext context, RegisterState state) {
    return Column(
      children: [
        CustomTextField(
          text: "Phone Number",
          icon: Icons.phone_enabled_outlined,
          callback: update_phone_number,
          intial_value: state.phone_number,
        ),
        SizedBox(height: 10),
        CustomTextField(
          text: "Wilaya",
          icon: Icons.place_outlined,
          callback: update_wilaya,
          intial_value: state.wilaya,
        ),
        SizedBox(height: 10),
        Container(
          child: DropdownButton(
            value: role,
            items: [CLIENT, FREELACNER].map<DropdownMenuItem<String>>((e) {
              return DropdownMenuItem(
                child: Text(e),
                value: e,
              );
            }).toList(),
            onChanged: (String? val) {
              setState(() {
                role = val ?? role;
              });
            },
            isExpanded: true,
          ),
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: theme_colors.input_background,
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // CustomTextField(
        // text: "Job Title",
        // icon: Icons.work_outline,
        // callback: update_job_title,
        // intial_value: state.job_title,
        // ),
        SizedBox(height: 10),
        TextFormField(
          initialValue: state.birthday,
          readOnly: true,
          onTap: () {
            showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2019, 1),
              lastDate: DateTime(2025, 12),
            ).then((pickedDate) {
              update_date(pickedDate!);
            });
          },
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.calendar_month_outlined,
              color: theme_colors.text_light,
            ),
            hintText: birthday,
            hintStyle: TextStyle(
              color: theme_colors.text_light,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            fillColor: theme_colors.input_background,
            filled: true,
          ),
        ),
      ],
    );
  }

  Row _footer(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            widget.set_stage(0);
          },
          child: Text(
            "Back",
            style: TextStyle(
              fontSize: 17,
              color: theme_colors.text_light,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            next_stage();
          },
          child: Text(
            "Next",
            style: TextStyle(
              fontSize: 17,
              color: theme_colors.accent_text_black,
            ),
          ),
        ),
      ],
    );
  }

  Stack _upload_pp(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 20,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Text(
              "Finish setting up your account",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: theme_colors.text_black,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Positioned(
          child: Image.asset("assets/register_upload_img.png"),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Upload your profile picture",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme_colors.text_black,
                  ),
                ),
                SizedBox(height: 20),
                GradientButton(
                  borderRadius: 20.0,
                  width: MediaQuery.of(context).size.width - 100,
                  activated: true,
                  callback: () {
                    upload_image();
                  },
                  widget: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/register_gallery.svg",
                        width: 20,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Upload",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FreelancerRegister extends StatefulWidget {
  final set_stage;
  const FreelancerRegister({
    super.key,
    required this.set_stage,
  });

  @override
  State<FreelancerRegister> createState() => _FreelancerRegisterState();
}

class _FreelancerRegisterState extends State<FreelancerRegister> {
  String education = "";
  String work_expertise = "";
  String rate = "";
  String skills = "";
  String bio = "";

  bool btn_active = false;
  void on_change_education(val) {
    education = val;
    toggle_next_btn();
  }

  void on_change_xp(val) {
    work_expertise = val;
    toggle_next_btn();
  }

  void on_change_rate(val) {
    rate = val;
    toggle_next_btn();
  }

  void on_change_bio(val) {
    bio = val;
    toggle_next_btn();
  }

  void toggle_next_btn() {
    if (!btn_active &&
        education != "" &&
        work_expertise != "" &&
        bio != "" &&
        rate != "") {
      setState(() {
        btn_active = true;
      });
      return;
    }

    if (btn_active &&
        !(education != "" && work_expertise != "" && bio != "" && rate != "")) {
      setState(() {
        btn_active = false;
      });
    }
  }

  next_stage() {
    context.read<RegisterBloc>().add(
          RegisterFinishSubmitFreelancer(
            education,
            work_expertise,
            rate,
            skills,
            bio,
          ),
        );
    // widget.on_finish_registeration();
  }

  late StringTagController _stringTagController;

  @override
  void initState() {
    _stringTagController = StringTagController();
    RegisterState state = context.read<RegisterBloc>().state;
    education = state.education;
    work_expertise = state.work_expertise;
    rate = state.rate;
    skills = state.skills;

    super.initState();
  }

  @override
  void dispose() {
    _stringTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.only(
            top: AppBar().preferredSize.height,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            children: [
              Column(
                children: [
                  Text(
                    "Tell us more about you",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: theme_colors.text_black,
                    ),
                  ),
                  SizedBox(height: 40),
                  _input_area(state),
                ],
              ),
              _tags(context),
              Expanded(child: SizedBox()),
              _footer()
            ],
          ),
        );
      },
    );
  }

  Widget _tags(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 10),
          child: Text(
            "Skills",
            style: TextStyle(
              color: theme_colors.text_light,
            ),
          ),
        ),
        TextFieldTags(
          textfieldTagsController: _stringTagController,
          textSeparators: [" "],
          inputFieldBuilder: (ctx, inputFieldValues) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                onTap: () {
                  _stringTagController.getFocusNode?.requestFocus();
                },
                controller: inputFieldValues.textEditingController,
                focusNode: inputFieldValues.focusNode,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF864AF9),
                      width: 3.0,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF864AF9),
                      width: 3.0,
                    ),
                  ),
                  hintText:
                      inputFieldValues.tags.isNotEmpty ? '' : "Enter skill...",
                  errorText: inputFieldValues.error,
                  prefixIconConstraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8),
                  prefixIcon: inputFieldValues.tags.isNotEmpty
                      ? SingleChildScrollView(
                          controller: inputFieldValues.tagScrollController,
                          scrollDirection: Axis.vertical,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 8,
                              left: 8,
                            ),
                            child: Wrap(
                                runSpacing: 4.0,
                                spacing: 4.0,
                                children:
                                    inputFieldValues.tags.map((String tag) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                      color: Color(0xFF864AF9),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          child: Text(
                                            '#$tag',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          onTap: () {
                                            //print("$tag selected");
                                          },
                                        ),
                                        const SizedBox(width: 4.0),
                                        InkWell(
                                          child: const Icon(
                                            Icons.cancel,
                                            size: 14.0,
                                            color: Color.fromARGB(
                                                255, 233, 233, 233),
                                          ),
                                          onTap: () {
                                            inputFieldValues.onTagRemoved(tag);
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                }).toList()),
                          ),
                        )
                      : null,
                ),
                onChanged: inputFieldValues.onTagChanged,
                onSubmitted: inputFieldValues.onTagSubmitted,
              ),
            );
          },
        ),
      ],
    );
  }

  Column _input_area(RegisterState state) {
    return Column(
      children: [
        CustomTextField(
          text: "Work experience",
          icon: Icons.timeline,
          callback: on_change_xp,
          intial_value: state.work_expertise,
        ),
        SizedBox(height: 15),
        CustomTextField(
          text: "Education",
          icon: Icons.school,
          callback: on_change_education,
          intial_value: state.education,
        ),
        SizedBox(height: 15),
        SizedBox(height: 15),
        CustomTextField(
          text: "give us your rate",
          icon: Icons.payment,
          callback: on_change_rate,
          intial_value: state.rate,
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget _footer() {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  widget.set_stage(1);
                },
                child: Text(
                  "Back",
                  style: TextStyle(
                    fontSize: 17,
                    color: theme_colors.text_light,
                  ),
                ),
              ),
              TextButton(
                onPressed:
                    state.status == RegisterStatus.loading ? null : next_stage,
                child: state.status != RegisterStatus.loading
                    ? Text(
                        "Finish",
                        style: TextStyle(
                          fontSize: 17,
                          color: theme_colors.accent_text_black,
                        ),
                      )
                    : CircularProgressIndicator(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ClientRegister extends StatefulWidget {
  final set_stage;
  const ClientRegister({
    super.key,
    required this.set_stage,
  });

  @override
  State<ClientRegister> createState() => _ClientRegisterState();
}

class _ClientRegisterState extends State<ClientRegister> {
  String interests = "";
  String bio = "";

  next_stage() {
    context.read<RegisterBloc>().add(
          RegisterFinishSubmitClient(interests),
        );
  }

  late StringTagController _stringTagController;

  @override
  void initState() {
    _stringTagController = StringTagController();
    RegisterState state = context.read<RegisterBloc>().state;
    interests = state.intersts;
    super.initState();
  }

  @override
  void dispose() {
    _stringTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.only(
            top: AppBar().preferredSize.height,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            children: [
              Column(
                children: [
                  Text(
                    "What interests you",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: theme_colors.text_black,
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text(
                      "Bio",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: theme_colors.text_light,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "tell us more about you...",
                      isDense: true,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 74, 137, 92),
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              _tags(context),
              Expanded(child: SizedBox()),
              _footer()
            ],
          ),
        );
      },
    );
  }

  Widget _tags(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 10),
          child: Text(
            "Interests",
            style: TextStyle(
              color: theme_colors.text_light,
            ),
          ),
        ),
        SizedBox(height: 16),
        TextFieldTags(
          textfieldTagsController: _stringTagController,
          textSeparators: [" "],
          inputFieldBuilder: (ctx, inputFieldValues) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: TextField(
                onTap: () {
                  _stringTagController.getFocusNode?.requestFocus();
                },
                controller: inputFieldValues.textEditingController,
                focusNode: inputFieldValues.focusNode,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF864AF9),
                      width: 3.0,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF864AF9),
                      width: 3.0,
                    ),
                  ),
                  hintText: inputFieldValues.tags.isNotEmpty ? '' : "...",
                  errorText: inputFieldValues.error,
                  prefixIconConstraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8),
                  prefixIcon: inputFieldValues.tags.isNotEmpty
                      ? SingleChildScrollView(
                          controller: inputFieldValues.tagScrollController,
                          scrollDirection: Axis.vertical,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              bottom: 8,
                              left: 8,
                            ),
                            child: Wrap(
                                runSpacing: 4.0,
                                spacing: 4.0,
                                children:
                                    inputFieldValues.tags.map((String tag) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                      color: Color(0xFF864AF9),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          child: Text(
                                            '#$tag',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          onTap: () {
                                            //print("$tag selected");
                                          },
                                        ),
                                        const SizedBox(width: 4.0),
                                        InkWell(
                                          child: const Icon(
                                            Icons.cancel,
                                            size: 14.0,
                                            color: Color.fromARGB(
                                                255, 233, 233, 233),
                                          ),
                                          onTap: () {
                                            inputFieldValues.onTagRemoved(tag);
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                }).toList()),
                          ),
                        )
                      : null,
                ),
                onChanged: inputFieldValues.onTagChanged,
                onSubmitted: inputFieldValues.onTagSubmitted,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _footer() {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  widget.set_stage(1);
                },
                child: Text(
                  "Back",
                  style: TextStyle(
                    fontSize: 17,
                    color: theme_colors.text_light,
                  ),
                ),
              ),
              TextButton(
                onPressed:
                    state.status == RegisterStatus.loading ? null : next_stage,
                child: state.status != RegisterStatus.loading
                    ? Text(
                        "Finish",
                        style: TextStyle(
                          fontSize: 17,
                          color: theme_colors.accent_text_black,
                        ),
                      )
                    : CircularProgressIndicator(),
              ),
            ],
          ),
        );
      },
    );
  }
}
