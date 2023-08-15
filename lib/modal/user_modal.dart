import 'package:firebase_database/firebase_database.dart';

class UserModal{

  String? phone;
  String? email;
  String? name;
  String? id;

  UserModal({this.phone, this.name, this.id, this.email,});

  UserModal.fromSnapshot(DataSnapshot snap){
    phone = (snap.value as dynamic)["phone"];
    email = (snap.value as dynamic)["email"];
    name = (snap.value as dynamic)["name"];
    id = snap.key;


  }


}