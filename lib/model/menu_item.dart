import 'package:flutter/widgets.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final Color color;

  MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
  });
}
