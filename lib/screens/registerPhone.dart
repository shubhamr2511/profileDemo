import 'package:flutter/material.dart';
import 'package:profiledemo/screens/otpScreen.dart';
import 'package:profiledemo/services/signIn.dart';
import 'package:profiledemo/styles.dart';
import 'package:get/get.dart';

var _canTap = false.obs;

class RegisterPhonePage extends StatelessWidget {
  final TextEditingController phone = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            space(12),
            Text("Register Your Phone Number", style: headline5White),
            space(16),
            Text(
                "Your number is safe with us.\nWe won't share your details with anyone.",
                style: subtitle1White60),
            space(130),
            TextField(
              controller: phone,
              onChanged: (text) {
                if (phone.text.length < 10) {
                  _canTap.value = false;
                } else {
                  _canTap.value = true;
                }
              },
              decoration: InputDecoration(
                // counterText: "",
                prefix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("+91  "),
                    Container(
                      height: 24,
                      width: 2,
                      color: grey,
                    ),
                    Text("  ")
                  ],
                ),
                labelText: "Phone Number",
              ),
              keyboardType: TextInputType.number,
              maxLength: 10,
              style: bodyText2White60,
            ),
            Obx(() => FlatButton(
                  onPressed: _canTap.value
                      ? () {
                          Get.to(OtpScreen(phone: phone.text));
                        }
                      : null,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: blue,
                    ),
                    child: Center(
                      child: Text("Register", style: button),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
