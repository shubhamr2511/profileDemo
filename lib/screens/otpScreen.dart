import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:profiledemo/models/user.dart';
import 'package:profiledemo/screens/NewUserpage.dart';
import 'package:profiledemo/screens/profilePage.dart';
import 'package:profiledemo/services/signIn.dart';
import 'package:profiledemo/services/storageServices.dart';
import 'package:profiledemo/styles.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:get/get.dart';

var _canContinue = false.obs;

class OtpScreen extends StatefulWidget {
  final String phone;

  OtpScreen({required this.phone, Key? key}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? _verificationCode;
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
                InkWell(
                  onTap: () {
                    print("tap");
                    pinController.clear();
                    // _verifyPhone(false);
                  },
                  child: Text(
                    " Resend Code",
                    style: bodyText2.copyWith(color: blue),
                  ),
                ),
              ],
            ),
          ),
          space(22),
          Obx(
            () => FlatButton(
              onPressed: !_canContinue.value
                  ? null
                  : () async {
                      try {
                        await FirebaseAuth.instance
                            .signInWithCredential(PhoneAuthProvider.credential(
                                verificationId: _verificationCode!,
                                smsCode: pinController.text))
                            .then((value) async {
                          if (value.user != null) {
                            if (await StorageService().userExists(value.user!.uid)) {
                              UserModel user = UserModel.fromJson(
                                  await StorageService()
                                      .getUserDataById(value.user!.uid));

                              Get.offAll(ProfilePage(user: user, uid: value.user!.uid,));
                            } else {
                              Get.off(NewUserpage(newUser: value.user,));
                            }
                          }
                        });
                      } catch (e) {
                        print(e);
                      }
                     
                    }
                    ,
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
                Get.back();

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
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phone}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              UserModel user = UserModel.fromJson(await StorageService().getUserDataById(value.user!.uid));
              Get.offAll(ProfilePage(user: user, uid:value.user!.uid));
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          BotToast.showText(
                            contentColor: almostWhite,
                            textStyle: TextStyle(color: black),
                            text:
                                e.message!,
                            duration: Duration(seconds: 3));
        },
        codeSent: (String verficationID, int? resendToken) {
          setState(() {
            _verificationCode = verficationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 120));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verifyPhone();
  }
}
