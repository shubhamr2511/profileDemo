import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profiledemo/models/user.dart';
import 'package:profiledemo/screens/components.dart';
import 'package:profiledemo/screens/profilePage.dart';
import 'package:profiledemo/screens/registerPhone.dart';
import 'package:profiledemo/services/signIn.dart';
import 'package:profiledemo/services/storageServices.dart';
import 'package:profiledemo/styles.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

var _canContinue = false.obs;

class NewUserpage extends StatelessWidget {
  User? newUser;
  final TextEditingController name = new TextEditingController();
  final TextEditingController email = new TextEditingController();
  final TextEditingController city = new TextEditingController();
  final TextEditingController about = new TextEditingController();
  final TextEditingController imageUrl = new TextEditingController();
  final TextEditingController github = new TextEditingController();
  NewUserpage({required this.newUser, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
            FlatButton(
                onPressed: () {
                  AuthService.signOut();
                },
                child: Row(
                  children: [
                    Text('Sign Out  ',
                        style: TextStyle(
                            fontSize: 14,
                            color: red,
                            fontWeight: FontWeight.bold)),
                    Icon(CupertinoIcons.arrow_uturn_right, color: red)
                  ],
                )),
            // SizedBox(width: 20,)
          ],),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Welcome!', style: headline5White),
          SizedBox(height: 20),
          SizedBox(
            width: 280,
            child: Text(
              'We are glad to see you...',
              style: bodyText2White60,
            ),
          ),
          SizedBox(height: 50),
          TextField(
            controller: name,
            onChanged: (_) => _canContinue.value = _validate(),
            decoration: InputDecoration(
              // counterText: "",

              labelText: "Full Name",
            ),
            keyboardType: TextInputType.name,
            maxLength: 20,
            style: bodyText2White60,
          ),
          space(20),
          TextField(
            controller: email,
            onChanged: (_) => _canContinue.value = _validate(),
            decoration: InputDecoration(
              // counterText: "",

              labelText: "email Adress",
            ),
            keyboardType: TextInputType.emailAddress,
            style: bodyText2White60,
          ),
          space(20),
          TextField(
            controller: city,
            onChanged: (_) => _canContinue.value = _validate(),
            decoration: InputDecoration(
              // counterText: "",

              labelText: "where do you live?",
            ),
            keyboardType: TextInputType.streetAddress,
            style: bodyText2White60,
          ),
          space(20),
          TextField(
            minLines: 2,
            maxLines: 4,
            controller: about,
            onChanged: (_) => _canContinue.value = _validate(),
            decoration: InputDecoration(
              // counterText: "",

              labelText: "tell us about yourself...",
            ),
            keyboardType: TextInputType.multiline,
            style: bodyText2White60,
          ),
          // space(20),
          // TextField(
          //   controller: imageUrl,
          //   decoration: InputDecoration(
          //     // counterText: "",

          //     labelText: "Enter your image Url(you can leave it empty)",
          //   ),
          //   keyboardType: TextInputType.url,
          //   style: bodyText2White60,
          // ),
          space(20),
          TextField(
            controller: github,
            decoration: InputDecoration(
              // counterText: "",

              labelText: "Enter your Github ID",
            ),
            keyboardType: TextInputType.name,
            style: bodyText2White60,
          ),
          space(50),
          Obx(() => FlatButton(
                onPressed: _canContinue.value
                
                    ? () async {
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
                        UserModel user = UserModel(
                            name: name.text,
                            email: email.text,
                            city: city.text,
                            phone: newUser!.phoneNumber,
                            about: about.text,
                            imageUrl: imageUrl.text,
                            github: github.text);
                        await StorageService()
                            .addUser(newUser!.uid, user.toJson());
                        Get.offAll(ProfilePage(user: user, uid: newUser!.uid,));
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
    );
  }

  _validate() {
    if (about.text.length < 1 ||
        email.text.length < 1 ||
        name.text.length < 1 ||
        city.text.length < 1 ) {
      return false;
    } else {
      return true;
    }
  }
}
