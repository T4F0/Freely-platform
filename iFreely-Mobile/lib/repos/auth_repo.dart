import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flut/bloc/login/login_bloc.dart';
import 'package:flut/bloc/register/register_bloc.dart';
import 'package:flut/consts/hive_consts.dart';
import 'package:flut/consts/routes.dart';
import 'package:flut/consts/server.dart';
import 'package:flut/models/proposal_model.dart';
import 'package:flut/models/user_model.dart';
import 'package:flut/repos/graphql.dart';
import 'package:hive/hive.dart';

class DebugHelper {
  //DEBUG: random string generator
  static String getRandomString(int length) {
    String _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
}

class AuthRepo {
  UserModel? user_model = null;

  Future<UserModel?> default_login(String email, String password) async {
    // email = "abdouchappa@gmail.com"; // client
    // email = "abdouolicastro@gmail.com"; // frelancer
    // password = "nullnull";

    Response res;
    try {
      res = await Dio().post(GRAPHQL_SERVER,
          data: GraphQLRequester.login(email, password),
          options: Options(
            validateStatus: (status) => true,
          ));
    } catch (e) {
      print("[DIO ERROR] in login:");
      print(e);
      throw LoginError.network;
    }
    print(res);

    Map<String, dynamic> data = res.data as Map<String, dynamic>;
    if (data["errors"] != null) {
      String msg = data["errors"][0]["message"] as String;
      if (msg.contains("User not found")) {
        throw LoginError.email;
      } else if (msg.contains("Invalid password")) {
        throw LoginError.password;
      } else {
        print(data["errors"]);
        throw LoginError.network;
      }
    }

    data = data["data"];
    user_model = UserModel.fromLogin(data["login"]);

    return user_model;
  }

  Future<UserModel?> register(RegisterState state) async {
    var res;

    //DEBUG: always generate a random string to
    state.email = DebugHelper.getRandomString(5) + "gmail.com";

    try {
      res = await Dio().post(GRAPHQL_SERVER,
          data: GraphQLRequester.register_client(state),
          options: Options(
            validateStatus: (status) => true,
          ));
    } catch (e) {
      print("[DIO ERROR] in register:");
      print(e);
      throw RegisterError.network;
    }

    Map<String, dynamic> data = res.data as Map<String, dynamic>;
    if (data["errors"] != null) {
      String msg = data["errors"][0]["message"] as String;
      if (msg.contains("Email already exists")) {
        throw RegisterError.email;
      } else {
        print(data["errors"]);
        throw RegisterError.network;
      }
    }

    data = data["data"];
    user_model = UserModel.fromRegister(data["createClient"]);

    return user_model;
  }

  Future<UserModel?> register_freelancer(RegisterState state) async {
    print("[log] register_freelancer");
    var res;

    state.email = DebugHelper.getRandomString(5) + "gmail.com";

    try {
      res = await Dio().post(GRAPHQL_SERVER,
          data: GraphQLRequester.register_freelancer(state),
          options: Options(
            validateStatus: (status) => true,
          ));
    } catch (e) {
      print("[DIO ERROR] in register freelancer:");
      print(e);

      throw RegisterError.network;
    }

    Map<String, dynamic> data = res.data as Map<String, dynamic>;
    if (data["errors"] != null) {
      String msg = data["errors"][0]["message"] as String;
      if (msg.contains("Email already exists")) {
        throw RegisterError.email;
      } else {
        print(data["errors"]);
        throw RegisterError.network;
      }
    }
    data = data["data"];
    user_model = UserModel.fromRegister(data["createFreelancer"]);

    return user_model;
  }

  Future<void> load_auth_from_session() async {
    if (user_model == null && await Hive.boxExists(HiveConsts.USER_SESSION)) {
      var box = await Hive.openBox(HiveConsts.USER_SESSION);
      user_model = UserModel.loadFromHive(box);
    }
  }

  static Future<void> init_intial_route() async {
    if (await Hive.boxExists(HiveConsts.USER_SESSION)) {
      var token = (await Hive.openBox(HiveConsts.USER_SESSION))
          .get(HiveConsts.JWT_TOKEN);
      var role =
          (await Hive.openBox(HiveConsts.USER_SESSION)).get(HiveConsts.ROLE);
      if (await AuthRepo.is_token_valid(token)) {
        if (role == FREELACNER) {
          Routes.intial_route = Routes.freelancer_main_page;
        } else {
          Routes.intial_route = Routes.client_main_page;
        }
      }
    }
  }

  static Future<bool> is_token_valid(String token) async {
    var res;
    try {
      res = await Dio().post(
        GRAPHQL_SERVER,
        data: GraphQLRequester.seasion(token),
      );
    } catch (e) {
      print("[Error] doi failed AuthRepo.is_token_valid");
      print(e);
      return false;
    }
    Map<String, dynamic> data = res.data as Map<String, dynamic>;
    if (data["errors"] == null) {
      return true;
    }
    return false;
  }

  Future<UserModel> load_profile_info(String id) async {
    // load text data
    var res;

    try {
      res = await Dio().post(
        GRAPHQL_SERVER,
        data: user_model!.role == CLIENT
            ? GraphQLRequester.get_profile_client(
                id.length == 0 ? user_model!.id : id)
            : GraphQLRequester.get_profile_freelancer(
                id.length == 0 ? user_model!.id : id),
        options: Options(headers: {
          "authorization": user_model!.token,
        }, validateStatus: (s) => true),
      );
    } catch (e) {
      print("[DIO ERROR] when loading textual profile:");
      print(res);
      rethrow;
    }
    Map<String, dynamic> text_data = res.data as Map<String, dynamic>;
    text_data = text_data["data"];
    UserModel profile_user_model = UserModel.fromProfile(
        user_model!.role == CLIENT
            ? text_data["clientProfile"]["client"]
            : text_data["freelancerProfile"]["freelancer"]);
    profile_user_model.token = user_model!.token;
    return profile_user_model;
  }

  Future<UserModel> update_client_profile(input) async {
    var res;
    try {
      res = await Dio().post(
        GRAPHQL_SERVER,
        data: GraphQLRequester.update_client(
          phoneNumber: input["Phone"] ?? null,
          willaya: input["Wilalya"] ?? null,
          lastName: input["Last Name"] ?? null,
          firstName: input["First Name"] ?? null,
          dateOfBirth: input["Birthday"] ?? null,
          ccp: input["CCP"] ?? null,
        ),
        options: Options(
          headers: {
            "authorization": user_model!.token,
          },
        ),
      );
    } catch (e) {
      print("[DIO ERROR] when loading textual profile:");
      rethrow;
    }
    Map<String, dynamic> data = res.data as Map<String, dynamic>;
    data = data["data"];
    print(data);
    UserModel profile_user_model = UserModel.fromProfile(data["updateClient"]);
    profile_user_model.token = user_model!.token;

    return profile_user_model;
  }

  Future<Map<String, dynamic>> loadJobs() async {
    var res;
    try {
      res = await Dio().post(
        GRAPHQL_SERVER,
        data: GraphQLRequester.load_client_dash(user_model!.id),
        options: Options(
          headers: {
            "authorization": user_model!.token,
          },
        ),
      );
    } catch (e) {
      print("[DIO ERROR] when loading jobs:");
      rethrow;
    }
    Map<String, dynamic> data = res.data["data"]["clientDash"];
    return data;
  }

  Future<List<ProposalModel>> get_proposals(String id) async {
    var res;
    try {
      res = await Dio().post(
        GRAPHQL_SERVER,
        data: GraphQLRequester.load_jobs_requests(user_model!.id, id),
        options: Options(
          headers: {
            "authorization": user_model!.token,
          },
          validateStatus: (status) => true,
        ),
      );
    } catch (e) {
      rethrow;
    }
    print(res);

    if ((res.data as Map<String, dynamic>).containsKey("errors") ||
        res.data["data"]["getJobRequests"]["requests"] == null) {
      return [];
    }

    var data = res.data["data"]["getJobRequests"]["requests"] as List;
    List<ProposalModel> props = [];
    for (int i = 0; i < data.length; i++) {
      props.add(ProposalModel.fromJson(data[i]));
    }
    return props;
  }

  void accept_job(String freelancerID, String jobID) async {
    var res;
    try {
      res = await Dio().post(
        GRAPHQL_SERVER,
        data: GraphQLRequester.accept_job(user_model!.id, freelancerID, jobID),
        options: Options(
          headers: {
            "authorization": user_model!.token,
          },
          validateStatus: (status) => true,
        ),
      );
    } catch (e) {
      rethrow;
    }
    throw res.data["data"]["acceptJob"]["message"];
  }

  Future<Map<String, dynamic>> load_freelancer_dash() async {
    var res;
    try {
      res = await Dio().post(
        GRAPHQL_SERVER,
        data: GraphQLRequester.freelancer_dash(user_model!.id),
        options: Options(
          headers: {
            "authorization": user_model!.token,
          },
          validateStatus: (status) => true,
        ),
      );
    } catch (e) {
      rethrow;
    }
    return res.data["data"]["freelancerDash"];
  }

  Future<List<dynamic>> load_talents() async {
    var res;
    try {
      res = await Dio().post(
        GRAPHQL_SERVER,
        data: GraphQLRequester.freelancers(user_model!.id),
        options: Options(
          headers: {
            "authorization": user_model!.token,
          },
          validateStatus: (status) => true,
        ),
      );
    } catch (e) {
      rethrow;
    }

    return res.data["data"]["talents"] as List<dynamic>;
  }

  Future<void> load_one_proposal(String id) async {
    print("LOAD ON PROP ${id}");

    var res;
    try {
      res = await Dio().post(
        GRAPHQL_SERVER,
        data: GraphQLRequester.get_job_requests(user_model!.id, id),
        options: Options(
          headers: {
            "authorization": user_model!.token,
          },
          validateStatus: (status) => true,
        ),
      );
    } catch (e) {
      rethrow;
    }

    print(id);
    print(user_model!.id);
    print(user_model!.token);
    print(res);
  }
}
