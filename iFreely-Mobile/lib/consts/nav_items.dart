import 'package:flutter/material.dart';

List<BottomNavigationBarItem> navBarItems = [
  const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon:
          Icon(Icons.home_outlined, color: Color.fromARGB(255, 180, 136, 194)),
      label: "home"),
  const BottomNavigationBarItem(
      icon: Icon(Icons.chat),
      activeIcon: Icon(Icons.chat, color: Color.fromARGB(255, 180, 136, 194)),
      label: "chat"),
  const BottomNavigationBarItem(
      icon: Icon(
        Icons.add_box_rounded,
        
      ),
      activeIcon: Icon(Icons.add_box_rounded,
           color: Color.fromARGB(255, 180, 136, 194)),
      label: "create"),
  const BottomNavigationBarItem(
      icon: Icon(Icons.edit_document),
      activeIcon:
          Icon(Icons.edit_document, color: Color.fromARGB(255, 180, 136, 194)),
      label: "gigs"),
  const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      activeIcon: Icon(Icons.person, color: Color.fromARGB(255, 180, 136, 194)),
      label: "profile"),

];
