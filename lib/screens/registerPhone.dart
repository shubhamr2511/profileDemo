import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profiledemo/models/user.dart';
import 'package:profiledemo/screens/otpScreen.dart';
import 'package:profiledemo/screens/profilePage.dart';
import 'package:profiledemo/services/handleDynamicLinks.dart';
import 'package:profiledemo/services/signIn.dart';
import 'package:profiledemo/services/storageServices.dart';
import 'package:profiledemo/styles.dart';
import 'package:get/get.dart';

var _canTap = false.obs;

class RegisterPhonePage extends StatefulWidget {
  @override
  _RegisterPhonePageState createState() => _RegisterPhonePageState();
}

class _RegisterPhonePageState extends State<RegisterPhonePage> {
  String? _verificationCode;
  @override
  void initState() {
    
    // TODO: implement initState
    super.initState();
  }
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
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              content: Container(
                                height: 50,
                                width: 50,
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          );
                          _verifyPhone();
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

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${phone.text}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              UserModel user = UserModel.fromJson(
                  await StorageService().getUserDataById(value.user!.uid));
              Get.offAll(ProfilePage(user: user, uid: value.user!.uid));
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message!)));
          Get.back();
          Get.back();
        },
        codeSent: (String verficationID, int? resendToken) {
          setState(() {
            _verificationCode = verficationID;
          });
          Get.offAll(
              OtpScreen(verificationId: _verificationCode, phone: phone.text));
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            _verificationCode = verificationID;
          });
          Get.back();
          Get.back();
        },
        timeout: Duration(seconds: 120));
  }
}
