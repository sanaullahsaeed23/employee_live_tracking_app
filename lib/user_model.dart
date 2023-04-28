//This Model is for Signup because in signup we have to store data on data base
// and fetch this data from firebase

class UserModel {
  String? uid;
  String? email;
  String? fullName;
  String? role;


  UserModel({this.uid, this.email, this.fullName, this.role, });

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      fullName: map['firstName'],
      role: map['role'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
    };
  }
}
