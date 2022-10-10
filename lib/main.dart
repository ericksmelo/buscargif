import 'package:flutter/material.dart';
import 'pages/homePage.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
    theme: ThemeData(
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 3, color: Colors.greenAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 3, color: Colors.amberAccent),
        ),
      ),
    ),
  ));
}
