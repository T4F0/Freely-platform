// ignore_for_file: avoid_print

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flut/bloc/feed/feed_bloc.dart';
import 'package:flut/consts/hive_consts.dart';
import 'package:flut/consts/server.dart';
import 'package:flut/models/feed_card.dart';
import 'package:flut/models/job_model.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flut/repos/graphql.dart';
import 'package:hive/hive.dart';

class JobCreationRepo {
  AuthRepo _authRepo;
  JobCreationRepo(this._authRepo);

  Future<void>? post_job(JobModel job_model) async {
    Response? res;

    print(job_model);
    

    try {
      res = await Dio().post(
        GRAPHQL_SERVER,
        data: GraphQLRequester.post_job(
          _authRepo.user_model!.id,
          job_model,
        ),
        options: Options(
          headers: {
            "authorization": _authRepo.user_model!.token,
          },
          validateStatus: (a) => true,
        ),
      );
    } catch (e) {
      print("[Error] dio error JobCreationRepo.post_job");
      print("res: " + res.toString());
      print("error: " + e.toString());
      throw ("[Error] Failed to create job");
    }
    print(res);

    // print("job created!");
    // print(res);
  }
}
