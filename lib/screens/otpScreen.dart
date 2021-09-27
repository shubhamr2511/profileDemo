import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profiledemo/models/user.dart';
import 'package:profiledemo/screens/NewUserpage.dart';
import 'package:profiledemo/screens/profilePage.dart';
import 'package:profiledemo/screens/registerPhone.dart';
import 'package:profiledemo/services/signIn.dart';
import 'package:profiledemo/services/storageServices.dart';
import 'package:profiledemo/styles.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:get/get.dart';
import 'dart:async';

var _canContinue = false.obs;
var _canResend = false.obs;

class OtpScreen extends StatefulWidget {
  final String phone;
  String? verificationId;
  OtpScreen({required this.phone, required this.verificationId, Key? key})
      : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  void initState() {
    _start.value = 90;
    startTimer();
    // TODO: implement initState
    super.initState();
  }

  Timer? _timer;
  var _start = 90.obs;

  void startTimer() {
    _canResend.value = false;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start.value == 0) {
          timer.cancel();
          _canResend.value = true;
        } else {
          _start.value--;
        }
      },
    );
  }

  final TextEditingController pinController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: [
          space(12),
          Text("OTP Verification", style: headline5White),
          space(16),
          Text("Enter the 6 digit code sent to ", style: subtitle1White60),
          space(8),
          Text("+91 " + widget.phone, style: subtitle1White),
          space(102),
          PinCodeTextField(
            controller: pinController,
            appContext: context,
            enablePinAutofill: true,
            length: 6,
            obscureText: false,
            animationType: AnimationType.fade,
            pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(6),
                fieldHeight: 50,
                fieldWidth: 50,
                borderWidth: 1,
                activeFillColor: darkGrey,
                selectedFillColor: darkGrey,
                activeColor: almostWhite,
                inactiveFillColor: darkGrey,
                selectedColor: almostWhite,
                inactiveColor: Colors.transparent),
            cursorHeight: 28,
            animationDuration: Duration(milliseconds: 300),
            backgroundColor: Colors.transparent,
            textStyle: headline5White,
            enableActiveFill: true,
            keyboardType: TextInputType.number,
            //errorAnimationController: errorController,
            //controller: textEditingController,
            onCompleted: (v) {
              print("Completed");
              // _verifyPin(pinController.text, user);
            },
            onChanged: (value) {
              if (pinController.text.length < 6) {
                _canContinue.value = false;
              } else {
                _canContinue.value = true;
              }
            },
            beforeTextPaste: (text) {
              print("Allowing to paste $text");
              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
              //but you can show anything you want here, like your pop up saying wrong paste format or etc
              return true;
            },
            onSubmitted: (pin) async {
              // _verifyPin(pin, user);
            },
          ),
          space(8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Didn't receive code?",
                  style: bodyText2White,
                ),
                Obx(
                  () => InkWell(
                    onTap: _canResend.value
                        ? () {
                            print("tap");
                            pinController.clear();
                            _verifyPhone();
                            _start.value = 90;
                            startTimer();
                          }
                        : null,
                    child: Text(
                      " Resend Code ",
                      style: bodyText2.copyWith(
                          color: _canResend.value ? blue : grey),
                    ),
                  ),
                ),
                Obx(() => Text("${_start.value}",
                    style: bodyText2.copyWith(
                        color: _canResend.value ? grey : white)))
              ],
            ),
          ),
          space(22),
          Obx(
            () => FlatButton(
              onPressed: !_canContinue.value
                  ? null
                  : () async {
                    print(pinController.text + " " + widget.phone);
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
                      try {
                        await FirebaseAuth.instance
                            .signInWithCredential(PhoneAuthProvider.credential(
                                verificationId: widget.verificationId!,
                                smsCode: pinController.text))
                            .then((value) async {
                          if (value.user != null) {
                            if (await StorageService()
                                .userExists(value.user!.uid)) {
                              UserModel user = UserModel.fromJson(
                                  await StorageService()
                                      .getUserDataById(value.user!.uid));

                              Get.offAll(ProfilePage(
                                user: user,
                                uid: value.user!.uid,
                              ));
                            } else {
                              Get.offAll(NewUserpage(
                                newUser: value.user,
                              ));
                            }
                          }
                        });
                      } catch (e) {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Invalid SMS Code!")));
                        Get.back();
                        Get.back();
                      }
                    },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: blue,
                ),
                child: Center(
                  child: Text("Verify Phone Number", style: button),
                ),
              ),
            ),
          ),
          space(30),
          Center(
            child: InkWell(
              onTap: () {
                Get.offAll(RegisterPhonePage());
              },
              child: Text(
                "Edit Phone Number?",
                style: bodyText2.copyWith(color: blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _verifyPhone() async {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Container(
          height: 50,
          width: 50,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      ),
    );
    print("Sending...");
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phone}',
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
          Get.back();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message!)));
        },
        codeSent: (String verficationID, int? resendToken) {
          setState(() {
            widget.verificationId = verficationID;
          });
          Get.back();
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            widget.verificationId = verificationID;
          });
        },
        timeout: Duration(seconds: 120));
  }
}
