import 'package:employee_tracking_system/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';


Future<void> main() async {

  // Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
    requestPermission();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email And Password Login',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),

      debugShowCheckedModeBanner: false,
      //sigint authentication start from here then go to home page
     home: const LoginScreen(),
    );
  }

  requestPermission() async {
    var status = await Permission.location.request();
    if(status.isGranted){
      print("Location Granted");
    }else if(status.isDenied){
      requestPermission();
    } else if (status.isPermanentlyDenied){
      openAppSettings();
    }
  }

}