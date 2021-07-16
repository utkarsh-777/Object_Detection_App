import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/screens/SignInPage.dart';
import 'package:object_detection/screens/SignUpPage.dart';
import 'package:object_detection/homepage.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  // initialize the cameras when the app starts
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await Firebase.initializeApp();
  // running the app
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignInPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      routes: <String, WidgetBuilder>{
        "/signup": (BuildContext context) => SignUpPage(),
        "/signin": (BuildContext context) => SignInPage(),
        "/home": (BuildContext context) => Homepage(cameras: cameras)
      },
    );
  }
}
