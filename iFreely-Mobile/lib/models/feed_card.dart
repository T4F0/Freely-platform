// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flut/models/attachement.dart';
import 'package:flut/models/user_model.dart';
import 'package:flut/repos/auth_repo.dart';
import 'package:flutter/material.dart';


class FeedCard extends Equatable {
  String id;
  String title;
  String username;
  String description;
  int price;
  String deadline;

  String logo;
  String payment_type;
  DateTime post_date;
  Duration expected_duration;
  List<dynamic> attachements = []; 
  List<dynamic> skills = ["Python","Backend","Django"]; 
  String payement_method = "cpp";

  UserModel? client; // need kanyo to send me user


  FeedCard({
    required this.logo,
    required this.title,
    required this.id,
    required this.username,
    required this.description,
    required this.post_date,
    required this.payment_type,
    required this.price,
    required this.expected_duration,
    required this.attachements,
    required this.deadline,
    this.skills = const ["Python"],
    
  }) {
    if(this.logo == "") {
      this.logo =  "assets/django.png";

    }
  }



  factory FeedCard.fromJson(data) {
    return FeedCard(
      logo: "assets/django.png",
      id: data["_id"],
      title: data["title"],
      username: data["clientInfo"] != null ? (data["clientInfo"]["firstName"] + " " +  data["clientInfo"]["lastName"]) : "",
      description: data["description"],
      post_date: DateTime.now(),
      payment_type: data["payment_structure"] ,//["hourly","milestone"][Random().nextInt(2)],
      price: data["price"],
      deadline: data["deadline"],
      skills: data.containsKey("tags") ?  data["tags"] : [],
      
      expected_duration: Duration(days: Random().nextInt(30)),
      attachements: data.containsKey("attachments") ?  data["attachments"] : [],
    );
  }

  factory FeedCard.empty() {
    return FeedCard(
      id: "",
      logo: "",
      title: "",
      username: "",
      description: "",
      post_date: DateTime.now(),
      payment_type: "",
      price: 1,
      expected_duration: Duration(days: Random().nextInt(30)),
      attachements: [Attachement.random(),Attachement.random()],
      deadline : "",
    );
  }

  @override
  List<Object> get props => [
        id,
        logo,
        title,
        username,
        description,
        post_date,
        payment_type,
        price,    
        expected_duration,    
      ];



  @override
  String toString() {
    return "FeedCard($title $price\$)";
  }
}
