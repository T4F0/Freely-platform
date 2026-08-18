// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flut/models/attachement.dart';
import 'package:flut/models/user_model.dart';
import 'package:lorem_ipsum/lorem_ipsum.dart';

class ProposalModel extends Equatable {
  String userName = "";
  double userRating = 0;
  String userBio = "";
  String userId = "";
  String userPfp = "assets/pfp.png";

  String title = "";
  String description = "";
  String dueDate = "";
  String finalPrice = "";
  List<Attachement> files;

  ProposalModel({
    required this.userName,
    required this.userRating,
    required this.userBio,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.finalPrice,
    required this.files,
    this.userPfp = "assets/pfp.png",
  });

  factory ProposalModel.fromJson(data) {
    print(data);
    return ProposalModel(
      userName: data["firstName"] + " " + data["lastName"],
      description: data["description"],
      dueDate: DateTime.parse(data["deadline"]).year.toString() +
          "-" +
          DateTime.parse(data["deadline"]).month.toString() +
          "-" +
          DateTime.parse(data["deadline"]).day.toString(),
      files: [],
      finalPrice: data["price"].toString(),
      title: "",
      userRating: data["score"],
      userBio: data["bio"],
      userId: data["_id"],
      userPfp: data["photo"] ?? "assets/pfp.png",
    );
  }

  @override
  List<Object?> get props => [
        userName,
        userRating,
        userBio,
        userId,
        title,
        description,
        dueDate,
        finalPrice,
        files,
      ];
}
