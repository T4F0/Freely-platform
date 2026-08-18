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
import 'package:lorem_ipsum/lorem_ipsum.dart';

class FeedRepo {
  AuthRepo _authRepo;
  List<FeedCard> feed = [];

  FeedRepo(this._authRepo);

  Future<List<FeedCard>?> load_freelancer_feed(
      String? date, String? rate, String? type, String? query) async {
    var box = await Hive.openBox(HiveConsts.USER_SESSION);
    String jwt_token = box.get(HiveConsts.JWT_TOKEN);
    String user_id = box.get("id");
    print(user_id);
    Response? res;
    try {
      res = await Dio().post(
        GRAPHQL_SERVER,
        data: GraphQLRequester.load_freelancer_feed(
            user_id, date, rate, type, query),
        options: Options(
          headers: {
            "authorization": jwt_token,
          },
          validateStatus: (s) => true,
        ),
      );
    } catch (e) {
      print("[Error] dio error FeedRepo.load_freelancer_feed");
      print(res);
      print(e);
      throw FeedError.network;
    }
    print(res);

    Map<String, dynamic> data = res.data as Map<String, dynamic>;
    if (data["errors"] != null) {
      print(data["errors"]);
      throw FeedError.network;
    }

    var feed_list = data["data"]["getFreelancerFeed"] as List?;
    if (feed_list == null) {
      return [];
    }

    feed = [];
    for (var i = 0; i < feed_list.length; i++) {
      feed.add(FeedCard.fromJson(feed_list[i]));
    }

    return feed;
  }

  Future<void> generate_jobs() async {
    Response? res;
    try {
      res = await Dio().post(GRAPHQL_SERVER,
          data: GraphQLRequester.post_job(
            _authRepo.user_model!.id,
            JobModel(
              job_title: loremIpsum(words: Random().nextInt(2) + 1),
              description: loremIpsum(words: 30),
              rate: Random().nextInt(500),
            ),
          ),
          options: Options(headers: {
            "authorization": _authRepo.user_model!.token,
          }));
    } catch (e) {
      print("[Error] dio error FeedRepo.generate_jobs");
      print(res);
      print(e);
    }
    print(res);
    print("generate_jobs");
  }

  Future<void>? send_propsal(
      String id, String description, int rate, String deadline) async {
    Response? res;
    print(id);
    print(_authRepo.user_model);
    try {
      res = await Dio().post(
        GRAPHQL_SERVER,
        data: GraphQLRequester.post_proposal(
            _authRepo.user_model!.id, id, description, rate, deadline),
        options: Options(
          headers: {
            "authorization": _authRepo.user_model!.token,
          },
          validateStatus: (s) => true,
        ),
      );
    } catch (e) {
      print("[Error] dio error FeedRepo.send_propsal");
      print(res);

      rethrow;
    }

    throw res.data["data"]["postJobRequest"]["message"];
  }
}
