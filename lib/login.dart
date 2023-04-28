import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:employee_tracking_system/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:employee_tracking_system/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:employee_tracking_system/register.dart';
import 'package:employee_tracking_system/admin_module/home_admin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Thsese variables are from location package and only used to just change the location countinously
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  // Image file variable
  File? imageFile;
  String? downloadUrl;

  // form key
  final _formKey = GlobalKey<FormState>();

  // todo: What are Text controller
  // editing controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String dropdownValue = 'Role';
  late bool exist;

  // todo: firebase auth = ?
  // firebase
  final _auth = FirebaseAuth.instance;

  // string for displaying the error Message
  String? errorMessage;

  // Lcation variables
  double? p_latitude;
  double? p_longitude;

  UserModel userModel = UserModel();

  @override
  Widget build(BuildContext context) {
    // User Role, admin and user
    final role = Container(
      padding: const EdgeInsets.fromLTRB(45, 0, 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12, width: 2),
      ),
      child: DropdownButton<String>(
        value: dropdownValue,
        isExpanded: true,
        icon: const Icon(Icons.arrow_downward),
        elevation: 16,
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
          });
        },
        items: <String>['Role', 'Admin', 'User']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
    // Email Textfield......
    final emailfield = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,

      //most important
      //here we write validation which type data it will get
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        }
        // reg expression for email validation
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please Enter a valid email");
        }
        return null;
      },
      onSaved: (value) {
        emailController.text = value!;
      },

      textInputAction: TextInputAction.next,

      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.mail),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Email Address", // placeholder
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );

    //password textfield
    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: true,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Password is required for login");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid Password(Min. 6 Character)");
        }
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.vpn_key),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Password",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final loginButton = Material(
      elevation: 5, // shadow
      borderRadius: BorderRadius.circular(30),
      color: Colors.brown,
      child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            signIn(emailController.text, passwordController.text);
          },
          child: const Text(
            "Login",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("ETS - Login"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 140,
                      child: Image.asset(
                        "assets/logo.jpg",
                        fit: BoxFit.cover, //todo: Boxfit ?
                      ),
                    ),
                    const SizedBox(height: 25),
                    role,
                    const SizedBox(height: 15),
                    emailfield,
                    const SizedBox(height: 15),
                    passwordField,
                    const SizedBox(height: 15),
                    loginButton,
                    SizedBox(height: 15),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Register()));
                            },
                            child: const Text(
                              "SignUp",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          )
                        ])
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

// login function
  Future signIn(String email, String password) async {
    Future<void> userSigned = FirebaseAuth.instance.signOut();
    if (_formKey.currentState!.validate()) {
      try {
        final User? user = _auth.currentUser;
        final userID = user?.uid;
        await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then(
              (uid) async => {
                // Logic for role based login

                if (dropdownValue == "Admin")
                  {
                    await FirebaseFirestore.instance
                        .collection("admins")
                        .doc(userID)
                        .get()
                        .then((doc) {
                      exist = doc.exists;
                      if (exist) {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const AdminHome()));
                        Fluttertoast.showToast(msg: "Admin Login Successful");
                      } else {
                        Fluttertoast.showToast(
                            msg:
                                "No account found for this email. Register/Signup");
                      }
                    })
                  }
                else if (dropdownValue == "User")
                  {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(userID)
                        .get()
                        .then((doc) {
                      exist = doc.exists;
                      if (exist) {
                        // message
                        Fluttertoast.showToast(msg: "User Login Successfully");

                        // current position function
                        getCurrentPosition();

                        // Checking if user is logged in then don't fetch location in background and if the user is
                        // signed in then fetch the location
                        if (FirebaseAuth.instance.currentUser == null) {
                          _location.enableBackgroundMode(enable: false);
                        } else {
                          _location.enableBackgroundMode(enable: true);
                        }

                        // Continously listening to the user location
                        listenLocaion();

                        // opening camera
                        image_picker(source: ImageSource.camera);
                      } else {
                        Fluttertoast.showToast(
                            msg:
                                "No account found for this email. Register/Signup");
                      }
                    })
                  }
                else
                  {
                    Fluttertoast.showToast(
                        msg:
                            "No account found for this email. Register/Signup"),
                  }
              },
            );
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        print(error.code);
      }
    }
  }

  Future image_picker({required ImageSource source}) async {
    Fluttertoast.showToast(
      msg: "Turning Camera",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blueAccent,
      textColor: Colors.white,
      fontSize: 20.0,
    );

    final image = await ImagePicker().pickImage(source: source);

    if (image?.path != null) {
      setState(() {
        imageFile = File(image!.path);
        uploadImage();
        Fluttertoast.showToast(msg: "Tick");

        // moving to home page
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HomeScreen(
                emailController.text, p_longitude, p_latitude, imageFile)));
      });
    }
  }

  void getCurrentPosition() async {
    // permission checking
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Permission not given");
      await Geolocator.requestPermission();
    } else {
      LocationData _currentPosition = await _location.getLocation();
      p_longitude = _currentPosition.longitude;
      p_latitude = _currentPosition.latitude;

      // Inserting location latlan in the firebase database
      postToLoggedInUser(p_latitude!, p_longitude!);
    }
  } // getCurrentPosition

// Listen to current location of user and changing it continously
  Future<void> listenLocaion() async {
    _locationSubscription = _location.onLocationChanged.handleError((onError) {
      // iF error happened in listening the location
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((LocationData currentLocation) async {
// Inserting location latlan in the firebase database

      if (FirebaseAuth.instance.currentUser == null) {
        print("Logged out");
        // SystemNavigator.pop();
        _locationSubscription?.cancel();
      } else {
        double? lat = currentLocation.latitude;
        double? long = currentLocation.longitude;
        postToLoggedInUser(lat!, long!);
      }
    });
  }

  void postToLoggedInUser(double latitude, double longitude) {
    try {
      // First get the role of admin b/c only for users we need the location tracker
      final User? user = _auth.currentUser;
      final userID = user?.uid;
      if (dropdownValue == "User") {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get()
          .then((DocumentSnapshot<Map<String, dynamic>> snapshot) async {
        String name = snapshot.get('fullName');
        print(name);

          await FirebaseFirestore.instance
              .collection("users")
              .doc(userID)
              .get()
              .then((doc) {
            exist = doc.exists;
            if (exist) {
              FirebaseFirestore.instance
                  .collection('loggedInUsers')
                  .doc(emailController.text)
                  .set(
                {
                  'Name': name,
                  'Email ID': emailController.text,
                  'Longitude': longitude,
                  'Latitude': latitude,
                },
                SetOptions(merge: true),
              );
              Fluttertoast.showToast(msg: "Sending your Location");

              print("Latitude :" + latitude.toString());
              print("Longitude :" + longitude.toString());
              Fluttertoast.showToast(msg: "User Login Successful");
            } else {
              Fluttertoast.showToast(
                  msg: "No account found for this email. Register/Signup");
            }
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // uploading image of the employee to firebase storage (cloud storage) then
  // getting the download Url and then adding that url to cloudFirestore

  Future uploadImage() async {
    String postId = DateTime.now().millisecondsSinceEpoch.toString();
    String userId = emailController.text;

    Reference reference = FirebaseStorage.instance
        .ref()
        .child('$userId/images')
        .child("post_$postId"); // path Saving file to storage in firebase
    await reference.putFile(imageFile!); // taking the photo clicked by camera

    downloadUrl =
        await reference.getDownloadURL(); // getting the url of that image
    print(downloadUrl);

    // uplaod image file url to cloud firestore/firebase database
    FirebaseFirestore.instance
        .collection('loggedInUsers')
        .doc(emailController.text)
        .set(
      {
        'downloadUrl': downloadUrl,
      },
      SetOptions(merge: true),
    );
  }
}
