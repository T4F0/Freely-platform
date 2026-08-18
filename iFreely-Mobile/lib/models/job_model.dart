import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flut/models/register_model.dart';
import 'package:flut/models/user_model.dart';
import 'package:flutter/material.dart';

class JobModel extends Equatable {
  late String author_id;
  String job_title = "";
  String experience = "";
  String job_size = "";
  String description = "";
  String deadline = "";
  String wilaya = "";
  String modality = "";
  String frequency = "";
  String payment_structure = "";
  int rate = 0;
  String payment_method = "";
  String boost = "";
  List<File> files = const [];
  String username;




  JobModel({
  this.job_title = "",
  this.experience = "",
  this.job_size = "",
  this.description = "",
  this.deadline = "",
  this.wilaya = "",
  this.modality = "",
  this.frequency = "",
  this.payment_structure = "",
  this.rate = 0,
  this.payment_method = "",
  this.boost = "",
  this.files = const [],
  this.username = "",
  });

  void CreateJobModel(String author_id){
    this.author_id = author_id;
  }



  @override
  List<Object> get props => [
        author_id
      ];
  @override
  String toString() {
    return 'JobModel{job_title: $job_title, experience: $experience, job_size: $job_size, description: $description, deadline: $deadline, wilaya: $wilaya, modality: $modality, frequency: $frequency, payment_structure: $payment_structure, rate: $rate, payment_method: $payment_method, boost: $boost}';
    // return "JobModel{job_title : $job_title}";
  }
}
