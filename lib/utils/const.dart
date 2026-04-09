import 'package:flutter/material.dart';

import '../model/menu_item.dart' show MenuItem;

final List<MenuItem> menuList = [
  MenuItem(
    title: 'Home',
    icon: Icons.home,
    route: '/home',
    color: Color(0xFFA5795F),
  ),
  MenuItem(
    title: 'Tasks',
    icon: Icons.task,
    route: '/tasks',
    color: Color(0xFF4CAF50),
  ),
  MenuItem(
    title: 'Settings',
    icon: Icons.settings,
    route: '/settings',
    color: Color(0xFFFF9800),
  ),
  MenuItem(
    title: 'Shopping',
    icon: Icons.shop,
    route: 'shop',
    color: Color(0xFFB02735),
  ),
  MenuItem(
    title: 'Cart',
    icon: Icons.shopping_bag,
    route: '/cart',
    color: Color(0xFFA32ED5),
  ),
  MenuItem(
    title: 'Groceries',
    icon: Icons.shopping_bag,
    route: '/groceries',
    color: Color(0xFF3CD52E),
  ),
  MenuItem(
    title: 'Electrics',
    icon: Icons.shopping_bag,
    route: '/electric',
    color: Color(0xFF9D9FB1),
  ),
];
