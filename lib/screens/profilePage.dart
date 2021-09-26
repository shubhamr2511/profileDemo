import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profiledemo/models/user.dart';
import 'package:profiledemo/services/signIn.dart';
import 'package:profiledemo/styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'components.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;
  final String uid;
  const ProfilePage({required this.uid, required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(user.getDetails());
    return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          actions: [
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
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child:
              ListView(padding: EdgeInsets.symmetric(vertical: 16), children: [
            Container(
              child: user.imageUrl == null || user.imageUrl == ""
                  ? Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: blue,
                                border: Border.all(),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Center(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      user.name == null
                                          ? Text("name")
                                          : Text(
                                              user.name!,
                                              style: headline6,
                                            ),
                                      IconButton(
                                        onPressed: () {
                                          Share.share(
                                              "https://app.profiledemo.com?" +
                                                  uid);
                                        },
                                        icon: Icon(Icons.share),
                                        highlightColor: white,
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(user.city!, style: subtitle18,),
                                      Icon(Icons.location_city)
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : AspectRatio(
                      aspectRatio: 1 / 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            Image.network(
                              user.imageUrl!,
                              fit: BoxFit.fill,
                              width: MediaQuery.of(context).size.width,
                            ),
                            _buildGradient(),
                            _buildUserDetails(user, uid),
                          ],
                        ),
                      ),
                    ),
            ),
            space(20),
            DetailButton(
              onTap: () async {
                String url = 'tel:' + user.phone!;
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              text: user.phone!,
              icon: Icon(Icons.phone_android_outlined),
            ),
            space(20),
            DetailButton(
              onTap: () async {
                launch(
                    'mailto:${user.email}?subject=This is Subject Title&body=This is Body of Email');
              },
              text: user.email!,
              icon: Icon(Icons.email),
            ),
            space(20),
            DetailBox(
              fieldName: "About",
              fieldtext: user.about!,
            )
          ]),
        ));
  }
}

Widget _buildGradient() {
  return Positioned.fill(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.4, 0.95],
        ),
      ),
    ),
  );
}

Widget _buildUserDetails(UserModel user, uid) {
  return Positioned(
      left: 10,
      bottom: 10,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                user.name == null
                    ? Text("name")
                    : Text(
                        user.name!,
                        style: headline5,
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                      ),
                      IconButton(
                                    onPressed: () {
                                      Share.share(
                                          "https://app.profiledemo.com?" +
                                              uid);
                                    },
                                    icon: Icon(Icons.share),
                                    highlightColor: white,
                                  )
              ],
            ),
            Row(children: [
              Icon(Icons.location_city, color: Colors.white),
              user.city == null
                  ? Text('city')
                  : Text(
                      " " + user.city! + "  ",
                      style: subtitle1,
                    ),
            ])
          ],
        ),
      ]));
}
