import 'package:flutter/material.dart';
import 'package:profiledemo/styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(Icons.account_circle, size: MediaQuery.of(context).size.width*0.8,color: blue,),
      ),
    );
  }
}
