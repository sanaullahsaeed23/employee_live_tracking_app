import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:employee_tracking_system/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee_tracking_system/Map.dart';

import '../NavBar.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _homeState();
}

class _homeState extends State<AdminHome> {
  //AUTHENTICATION VARIABLES
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Vehicle Tracking- Admin"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(

              stream: FirebaseFirestore.instance
                  .collection('loggedInUsers')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                // used for when the application completed connection with firestore
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                // checks if the collection has any data or not?
                if (snapshot.hasData && snapshot.data?.size == 0) {
                  return const Center(
                    child: Text(
                      "No employee available on the field",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                  );
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                              snapshot.data!.docs[index]['Name'].toString()),
                          subtitle: Row(
                            children: [
                              Text(snapshot.data!.docs[index]['Latitude']
                                  .toString()),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(snapshot.data!.docs[index]['Longitude']
                                  .toString()),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.directions),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Map(snapshot
                                      .data!
                                      .docs[index]
                                      .id))); // Get the document id for map
                            },
                          ),
                        );
                      });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

}
