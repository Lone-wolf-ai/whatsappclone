import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String s;
  const ErrorScreen({super.key, required this.s});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(s),);
  }
}