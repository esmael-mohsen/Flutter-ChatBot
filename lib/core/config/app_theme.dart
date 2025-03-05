
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData.light().copyWith(
  primaryColor: Colors.blue,
  hintColor: Colors.blueAccent,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    shadowColor: Colors.grey,
    elevation: 3,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: Color(0xFF757575),
    ),
    bodyMedium: TextStyle(
      fontSize: 23,
      fontWeight: FontWeight.w700,
      color: Colors.blue,
    ),
  ),
);

ThemeData darkMode = ThemeData.dark().copyWith(
  primaryColor: Colors.blue,
  hintColor: Colors.blueAccent,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    shadowColor: Colors.grey,
    elevation: 3,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: Color(0xFF757575),
    ),
    bodyMedium: TextStyle(
      fontSize: 23,
      fontWeight: FontWeight.w700,
      color: Colors.blue,
    ),
  ),
);