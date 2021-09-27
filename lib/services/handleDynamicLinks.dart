
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:profiledemo/models/user.dart';
import 'package:profiledemo/screens/components.dart';
import 'package:profiledemo/services/storageServices.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../styles.dart';

class DynamicLinks {
  final dynamicLink = FirebaseDynamicLinks.instance;

  static Future<void> handleDynamicLink() async {
    print("Searching dynamic link...");
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLinkData) async {
      print("dynamiclinkData: ");
      print(dynamicLinkData!.link);
      print(dynamicLinkData.link.queryParameters);
      await handleSuccessLinking(dynamicLinkData);
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    await handleSuccessLinking(data!);
  }

  static Future<String> createProfileLink(String profileUrl) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      uriPrefix: 'https://profiledemo.page.link',
      link: Uri.parse('https://profiledemo.page.link/profile?url=$profileUrl'),
      androidParameters: AndroidParameters(
        packageName: 'profiledemo.page.link',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Profile',
      ),
    );
    final finalLink = await dynamicLinkParameters.buildShortLink();
    final Uri dynamicUrl = finalLink.shortUrl;
    print(dynamicUrl);
    return dynamicUrl.toString();
  }

  static Future handleSuccessLinking(
    PendingDynamicLinkData data,
  ) async {
    final Uri? deepLink = data.link;
    if (deepLink != null) {
      final queryParameters = deepLink.queryParameters;
      // if (queryParameters.length > 0) {
      String? target = queryParameters['url'];
      if (target != null) {
        UserModel userModel =
            UserModel.fromJson(await StorageService().getUserDataById(target));
        Get.to(()=>
            // ProfilePage(uid: target, user: userModel)
            BuildPage(target, userModel));
        print(target);
      }
      // }

    }
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
                  onPressed: () async {
                    var link = await DynamicLinks.createProfileLink(uid);
                    Share.share(link);
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

class BuildPage extends StatelessWidget {
  final target;
  final userModel;
  const BuildPage(this.target, this.userModel, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          actions: [
            
            // SizedBox(width: 20,)
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child:
              ListView(padding: EdgeInsets.symmetric(vertical: 16), children: [
            Container(
              child: userModel.imageUrl == null || userModel.imageUrl == ""
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
                                      userModel.name == null
                                          ? Text("name")
                                          : Text(
                                              userModel.name!,
                                              style: headline6,
                                            ),
                                      IconButton(
                                        onPressed: () async {
                                          var link = await DynamicLinks
                                              .createProfileLink(target);
                                          Share.share(link);
                                        },
                                        icon: Icon(Icons.share),
                                        highlightColor: white,
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        userModel.city!,
                                        style: subtitle18,
                                      ),
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
                              userModel.imageUrl!,
                              fit: BoxFit.fill,
                              width: MediaQuery.of(context).size.width,
                            ),
                            _buildGradient(),
                            _buildUserDetails(userModel, target),
                          ],
                        ),
                      ),
                    ),
            ),
            space(20),
            DetailButton(
              onTap: () async {
                String url = 'tel:' + userModel.phone!;
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              text: userModel.phone!,
              icon: Icon(Icons.phone_android_outlined),
            ),
            space(20),
            DetailButton(
              onTap: () async {
                launch(
                    'mailto:${userModel.email}?subject=This is Subject Title&body=This is Body of Email');
              },
              text: userModel.email!,
              icon: Icon(Icons.email),
            ),
            space(20),
            DetailBox(
              fieldName: "About",
              fieldtext: userModel.about!,
            )
          ]),
        ));
  }
}

// buildPage(target, userModel) {
//   return Scaffold(
//       appBar: AppBar(
//         title: Text("Profile"),
//         actions: [
//           FlatButton(
//               onPressed: () {
//                 AuthService.signOut();
//               },
//               child: Row(
//                 children: [
//                   Text('Sign Out  ',
//                       style: TextStyle(
//                           fontSize: 14,
//                           color: red,
//                           fontWeight: FontWeight.bold)),
//                   Icon(CupertinoIcons.arrow_uturn_right, color: red)
//                 ],
//               )),
//           // SizedBox(width: 20,)
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: ListView(padding: EdgeInsets.symmetric(vertical: 16), children: [
//           Container(
//             child: userModel.imageUrl == null || userModel.imageUrl == ""
//                 ? Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                               color: blue,
//                               border: Border.all(),
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(16))),
//                           padding:
//                               EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                           child: Center(
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     userModel.name == null
//                                         ? Text("name")
//                                         : Text(
//                                             userModel.name!,
//                                             style: headline6,
//                                           ),
//                                     IconButton(
//                                       onPressed: () async {
//                                         var link = await DynamicLinks
//                                             .createProfileLink(target);
//                                         Share.share(link);
//                                       },
//                                       icon: Icon(Icons.share),
//                                       highlightColor: white,
//                                     )
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       userModel.city!,
//                                       style: subtitle18,
//                                     ),
//                                     Icon(Icons.location_city)
//                                   ],
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   )
//                 : AspectRatio(
//                     aspectRatio: 1 / 1,
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(24),
//                       child: Stack(
//                         children: [
//                           Image.network(
//                             userModel.imageUrl!,
//                             fit: BoxFit.fill,
//                             // width: MediaQuery.of(context).size.width,
//                           ),
//                           _buildGradient(),
//                           _buildUserDetails(userModel, target),
//                         ],
//                       ),
//                     ),
//                   ),
//           ),
//           space(20),
//           DetailButton(
//             onTap: () async {
//               String url = 'tel:' + userModel.phone!;
//               if (await canLaunch(url)) {
//                 await launch(url);
//               } else {
//                 throw 'Could not launch $url';
//               }
//             },
//             text: userModel.phone!,
//             icon: Icon(Icons.phone_android_outlined),
//           ),
//           space(20),
//           DetailButton(
//             onTap: () async {
//               launch(
//                   'mailto:${userModel.email}?subject=This is Subject Title&body=This is Body of Email');
//             },
//             text: userModel.email!,
//             icon: Icon(Icons.email),
//           ),
//           space(20),
//           DetailBox(
//             fieldName: "About",
//             fieldtext: userModel.about!,
//           )
//         ]),
//       ));
// }
