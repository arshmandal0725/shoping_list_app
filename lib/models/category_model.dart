import 'package:flutter/material.dart';

enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other
}
class Category {
  const Category(this.title, this.colors);

  final String title;
  final Color colors;
}
