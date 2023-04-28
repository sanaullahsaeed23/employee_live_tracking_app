import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee_tracking_system/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Map extends StatefulWidget {
  String user_id;
  Map(this.user_id, {Key? key}) : super(key: key);
  // const Map({Key? key}) : super(key: key);

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final Location location = Location();
  late GoogleMapController _controller;
  late  bool _added = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      body: StreamBuilder(
        // stream builder for google map
        stream: FirebaseFirestore.instance
            .collection('loggedInUsers')
            .snapshots(), // firestore initialization and getting data snapshots
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {

          if(_added==true) {
            myMap(snapshot);
          }

          // builder the essential property of Streambuilder
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return GoogleMap(
            mapType: MapType.normal,
            markers: {
              Marker(
                position: LatLng(
                  // here getting the latitude and longitude if the user id of firebase
                  // (element.id) matches withe the id coming from login(widget.userId)
                  snapshot.data?.docs.singleWhere(
                      (element) => element.id == widget.user_id)['Latitude'],
                  snapshot.data?.docs.singleWhere(
                      (element) => element.id == widget.user_id)['Longitude'],
                ),
                markerId: const MarkerId('m1'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueMagenta),
              ),
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(
                // here getting the latitude and longitude if the user id of firebase
                // (element.id) matches withe the id coming from login(widget.userId)
                snapshot.data?.docs.singleWhere(
                        (element) => element.id == widget.user_id)['Latitude'],
                snapshot.data?.docs.singleWhere(
                        (element) => element.id == widget.user_id)['Longitude'],
              ),
              zoom: 14.47,
            ),onMapCreated: (GoogleMapController controller) async {
              setState(() {
                _controller = controller;
                _added = true;
              });
          },
          );
        },
      ),
    );
  }
  
  Future<void> myMap(AsyncSnapshot<QuerySnapshot> snapshot) async{
    // animate the camera....
    await _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
      // here getting the latitude and longitude if the user id of firebase
      // (element.id) matches withe the id coming from login(widget.userId)
      snapshot.data?.docs.singleWhere(
              (element) => element.id == widget.user_id)['Latitude'],
      snapshot.data?.docs.singleWhere(
              (element) => element.id == widget.user_id)['Longitude'],
    ), zoom: 14.47,
    )));
  }
}
