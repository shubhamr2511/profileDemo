import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService {
  CollectionReference users = FirebaseFirestore.instance.collection("users");

  Future<Map<String, dynamic>> getUserDataById(String uid) async {
    DocumentSnapshot document = await users.doc(uid).get();
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    return data;
  }

  Future<void> addUser(uid, json) {
    print(json);
    return users
        .doc(uid)
        .set(json)
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  userExists(String uid) async {
    return (await users.doc(uid).get()).exists;
  }
}
