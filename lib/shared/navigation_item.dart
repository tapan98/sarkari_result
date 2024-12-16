import 'package:flutter/material.dart';

class NavigationItem {
  final String label;
  final Icon icon;
  final Widget destination;
  NavigationItem(
      {required this.label, required this.icon, required this.destination});
}
