import 'package:flut/consts/server.dart';
import 'package:flutter/material.dart';

void init_user(String userId,BuildContext context) {
  Socket ws = Socket();
  ws.io.connect();
  ws.io.emit("init", userId);
}
