import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:profiledemo/models/user.dart';
import 'package:profiledemo/screens/NewUserpage.dart';
import 'package:profiledemo/screens/otpScreen.dart';
import 'package:profiledemo/screens/profilePage.dart';
import 'package:profiledemo/screens/registerPhone.dart';
import 'package:profiledemo/screens/splashScreen.dart';
import 'package:profiledemo/services/handleDynamicLinks.dart';
import 'package:profiledemo/services/signIn.dart';
import 'package:profiledemo/services/storageServices.dart';
import 'package:profiledemo/styles.dart';
import 'package:uni_links/uni_links.dart';

Future<void> initUniLinks() async {
  //TODO
  try {
    final initialLink = await getInitialLink();
    print(initialLink!);
  } on PlatformException {
    print("Exception");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Profile Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        backgroundColor: Colors.black,
        dividerColor: grey,
        scaffoldBackgroundColor: Colors.black,
        splashColor: grey,
        accentColor: Colors.white.withOpacity(0.87),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: grey)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: almostWhite)),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          focusColor: almostWhite,
          labelStyle: bodyText2White60,
          helperStyle: captionWhite60,
        ),
      ),
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  User? user = AuthService.getCurrentUser();

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      getdata(user);
    } else {
      Get.offAll(RegisterPhonePage());
    }
    return SplashScreen();
  }

  @override
  void initState() {
    DynamicLinks.handleDynamicLink();
    // TODO: implement initState
    super.initState();
  }
}

getdata(user) async {
  if (await StorageService().userExists(user.uid)) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get()
        .then((user) {
      Get.offAll(
          ProfilePage(uid: user.id, user: UserModel.fromJson(user.data()!)));
    });
  } else {
    Get.offAll(NewUserpage(newUser: user));
  }
}





// showCupertinoDialog(
//           context: context,
//           builder: (context) => CupertinoAlertDialog(
//             title: Text('Sending Otp...'),
//             content: Container(
//               height: 50,
//               width: 50,
//               child: Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               ),
//             ),
//           ),
//         );