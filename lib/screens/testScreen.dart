import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  final String text;
  const TestScreen({this.text = "test", Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(text)),
    );
  }
}
