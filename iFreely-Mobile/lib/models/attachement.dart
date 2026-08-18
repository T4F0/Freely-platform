// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:lorem_ipsum/lorem_ipsum.dart';

enum AttachementType { generic, pdf, word }

class Attachement extends Equatable {
  String name;
  String size;
  AttachementType type = AttachementType.generic;

  Attachement({
    type = AttachementType.generic,
    required this.name,
    required this.size,
  });

  static AttachementType get_file_type(String name) {
    try {
      String extention = name.split(".")[1];
      if (extention == "pdf") {
        return AttachementType.pdf;
      } else if (extention == "word") {
        return AttachementType.word;
      }
    } catch (e) {}

    return AttachementType.generic;
  }

  factory Attachement.random() => Attachement.create(
        loremIpsum(words: 1) + ["pdf", "word"][Random().nextInt(2)],
        (((Random().nextInt(40) + 10).toDouble()) / 10).toString(),
      );

  factory Attachement.create(String name, String size) => Attachement(
        type: Attachement.get_file_type(name),
        name: name,
        size: size + " Mb",
      );

  String get icon {
    return [
      "assets/icons/pdf-file-typ.svg",
      "assets/icons/pdf-file-typ.svg",
      "assets/icons/word-file-type.svg",
    ][type.index];
  }

  @override
  List<Object?> get props => [name, size, type];
}
