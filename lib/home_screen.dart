import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:employee_tracking_system/login.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  //constructor
  final String email;
  final double? _latitude;
  final double? _longitude;

  final File? _image;

  const HomeScreen(this.email, this._latitude, this._longitude, this._image,
      {Key? key})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  // Thsese variables are from location package and only used to just change the location countinously
  final Location _location = Location();
  StreamSubscription<Location>? _locationSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void demo(){
    LoginScreen l = new LoginScreen();
   // var d = l.
  }

  @override
  Widget build(BuildContext context) {
    final logoutButton = Material(
      elevation: 5, // shadow
      borderRadius: BorderRadius.circular(30),
      color: Colors.redAccent,
      child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth:
              MediaQuery.of(context).size.width, //todo: mediaquery in widty ?
          onPressed: () {
            FirebaseAuth.instance.signOut();
            //Delete the user from loggedInUser database when user click logout button/ when user is offline

            DocumentReference<Map<String, dynamic>> log = FirebaseFirestore
                .instance
                .collection('loggedInUsers')
                .doc(widget.email);

            FirebaseFirestore.instance
                .collection('loggedInUsers')
                .doc(widget.email)
                .delete();

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          child: const Text(
            "LogOut",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen - ETS"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            const Text(
              "Employee Details",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 23.0,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 25),

           // Email Text

            Expanded(
              flex: 2,
              child: Container(
                width: 250,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.red),
                ),
                child: widget._image == null
                    ? const Center(
                        child: Text("No image Selected"),
                      )
                    : Image.file(widget._image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 15),

            Text(
              'Your Eamil : ' + widget.email,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),

            // Longitude Value
            Text(
              'Longitude : ' + widget._longitude.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),

            // Latitude Value
            Text(
              'Latitude : ' + widget._latitude.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),

            const SizedBox(height: 30),
            logoutButton,
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
