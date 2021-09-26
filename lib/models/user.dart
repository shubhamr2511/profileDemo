import 'package:firebase_auth/firebase_auth.dart';
import 'package:profiledemo/services/storageServices.dart';

class UserModel {
  String? name;
  String? email;
  String? city;
  String? about;
  String? phone;
  String? imageUrl;

  UserModel(
      {required this.name,
      required this.email,
      required this.city,
      this.about =
          "Lorem Ipsum, sometimes referred to as 'lipsum', is the placeholder text used in design when creating content. It helps designers plan out where the content will sit, without needing to wait for the content to be written and approved. It originally comes from a Latin text, but to today's reader, it's seen as gibberish.",
      required this.phone,
      this.imageUrl});

  UserModel.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.email = json['email'];
    this.city = json['city'];
    this.about = json['about'];
    this.phone = json['phone'];
    this.imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['city'] = this.city;
    data['about'] = this.about;
    data['phone'] = this.phone;
    data['imageUrl'] = this.imageUrl;
    return data;
  }

  getDetails() {
    print("name : $name");
    print("city : $city");
    print("email : $email");
    print("phone : $phone");
  }
}
