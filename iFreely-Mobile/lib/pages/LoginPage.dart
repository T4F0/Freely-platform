import 'package:flut/bloc/login/login_bloc.dart';
import 'package:flut/components/custom_inputfiled.dart';
import 'package:flut/components/login_register_footer.dart';
import 'package:flut/components/password_input.dart';
import 'package:flut/consts/routes.dart';
import 'package:flut/consts/theme_colors.dart';
import 'package:flut/models/user_model.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flut/ui/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";
  bool is_activated = false;

  // external logic
  on_login_submit(BuildContext context) {
    context.read<LoginBloc>().add(LoginSubmit(email, password));
  }

  on_network_error(context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Network Error")));
  }

  // internal logic
  void on_change_useremail(val) {
    email = val;
    enable_button();
  }

  void on_change_password(val) {
    password = val;
    enable_button();
  }

  void enable_button() {
    if (!is_activated && password != "" && email != "") {
      setState(() {
        is_activated = true;
      });

      return;
    }
    if (is_activated && (password == "" || email == "")) {
      setState(() {
        is_activated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          if (context.read<AuthRepo>().user_model!.role == FREELACNER) {
            Navigator.pushReplacementNamed(
                context, Routes.freelancer_main_page);
          } else {
            Navigator.pushReplacementNamed(context, Routes.client_main_page);
          }
        }
      },
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.error == LoginError.network) {
            on_network_error(context);
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _top_section(),
                _login_btn(),
                SizedBox(height: 5),
                _bottom_section(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _login_btn() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return GradientButton(
          activated: state.status != LoginStatus.loading && is_activated,
          callback: () {
            on_login_submit(context);
          },
          widget: SizedBox(
            height: 30,
            child: state.status != LoginStatus.loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/icons/login_door.svg"),
                      SizedBox(width: 10),
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : SizedBox(width: 30, child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget _bottom_section(BuildContext context) {
    return LoginRegisterFooter(
        context: context, text: "Register", route: Routes.register_page);
  }

  Widget _top_section() {
    String useremail_error_msg = "invalid email";
    String password_error_msg = "invalid password";

    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.only(top: AppBar().preferredSize.height),
          child: Column(
            children: [
              Text(
                "Hi there,",
                style: TextStyle(color: theme_colors.text_black),
              ),
              SizedBox(height: 10),
              Text(
                "Wellcome Back",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: theme_colors.text_black,
                ),
              ),
              SizedBox(height: 80),
              CustomTextField(
                text: "Email",
                icon: Icons.email,
                callback: on_change_useremail,
                error_text: state.error == LoginError.email
                    ? useremail_error_msg
                    : null,
              ),
              SizedBox(height: 20),
              PasswordField(
                update_password: on_change_password,
                error_text: state.error == LoginError.password
                    ? password_error_msg
                    : null,
              ),
              SizedBox(height: 15),
              // GestureDetector(
                // onTap: () {},
                // child: Text(
                  // "Forgot your password?",
                  // style: TextStyle(
                    // decoration: TextDecoration.underline,
                    // decorationColor: theme_colors.text_light,
                    // color: theme_colors.text_light,
                  // ),
                // ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
