import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:profiledemo/models/user.dart';
import 'package:profiledemo/screens/otpScreen.dart';
import 'package:profiledemo/screens/profilePage.dart';
import 'package:profiledemo/screens/registerPhone.dart';
import 'package:profiledemo/services/storageServices.dart';
import 'package:profiledemo/styles.dart';
import 'package:get/get.dart';

String _phone = "";
String _smsCode = "";

class AuthService {
  static FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  static setPhone(phone){
    _phone = phone;
  }
  static setSmsCode(smsCode){
    _smsCode = smsCode;
  }

  static Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await _firebaseAuth.signInWithCredential(credential);
  }

  static phoneSignIn(String phoneNumber) async {
    

    _onVerificationCompleted(PhoneAuthCredential credential) async {
      print("verification completed ${credential.smsCode}");
      await _firebaseAuth.signInWithCredential(credential);
    }

    _onVerificationFailed(FirebaseAuthException e) async {
      if (e.code == 'invalid-phone-number') {
        print("The phone number entered is invalid!");
      }
    }

    _onCodeSent(String verificationId, int? resendToken) async {
      // Get.to(OtpScreen(phone: _phone ,verificationId:,));
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: _smsCode);

    // Sign the user in (or link) with the credential
    await _firebaseAuth.signInWithCredential(credential);
      // this.verificationId = verificationId;
      // print(forceResendingToken);
      // print("code sent");
    }

    _onCodeAutoRetrievalTimeout(String verificationId) async {
      return null;
    }

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _onCodeAutoRetrievalTimeout,
    );
  }

  static signUpWithEmailAndPassword(
      String name, String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      userCredential.user!.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  static signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Signed in";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        BotToast.showText(
            contentColor: almostWhite,
            textStyle: TextStyle(color: black),
            text: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        BotToast.showText(
            contentColor: almostWhite,
            textStyle: TextStyle(color: black),
            text: 'Wrong password provided for that user.');
      } else {
        BotToast.showText(
            contentColor: almostWhite,
            textStyle: TextStyle(color: black),
            text: e.message!);
      }
    }
  }

  static signOut() async {
    User? user = _firebaseAuth.currentUser;
    if (user!.providerData.contains('google.com')) {
      print("google sign out");
      await GoogleSignIn().signOut();
    } else
      await _firebaseAuth.signOut();
      Get.offAll(RegisterPhonePage());
  }
  
}
