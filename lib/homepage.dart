import 'package:flutter/material.dart';
import 'package:object_detection/realtime/live_camera.dart';
import 'package:object_detection/screens/Todos.dart';
import 'package:object_detection/static%20image/static.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Homepage extends StatefulWidget {
  final List<CameraDescription> cameras;
  Homepage({Key key, @required this.cameras}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState(cameras);
}

class _HomepageState extends State<Homepage> {
  List<CameraDescription> cameras;
  _HomepageState(this.cameras);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User firebaseUser;

  bool isLoading = true;

  getUser() async {
    User user = _auth.currentUser;
    await user?.reload();
    user = _auth.currentUser;

    if (user != null) {
      setState(() {
        this.firebaseUser = user;
        this.isLoading = false;
      });
    } else {
      Navigator.pushReplacementNamed(context, "/signin");
    }
  }

  signoutScreen(context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, "/signin");
  }

  // initCamera() async {
  //   cameras = await availableCameras();
  // }

  @override
  void initState() {
    super.initState();
    this.getUser();
  }

  getUserName() {
    if (firebaseUser != null) {
      return firebaseUser.displayName;
    } else {
      return "User";
    }
  }

  getEmail() {
    if (firebaseUser != null) {
      return firebaseUser.email;
    } else {
      return "example@example.com";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            child: Icon(Icons.add_task_outlined),
            backgroundColor: Colors.blue,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Todos(user: firebaseUser.uid)));
            },
          ),
          SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            heroTag: "btn2",
            child: Icon(Icons.logout),
            backgroundColor: Colors.red,
            onPressed: () {
              signoutScreen(context);
            },
          ),
        ],
      ),
      appBar: AppBar(
        title: Text("Object Detector App"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: aboutDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(50.0),
                  child: Image(
                    image: AssetImage("assets/logo.png"),
                    height: 100,
                    width: 100,
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.only(top: 50.0),
                    child: Text(
                      'Welcome, ${getUserName()}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.only(top: 10.0, bottom: 50.0),
                    child: Text(
                      'you are logged in as ${getEmail()}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ButtonTheme(
                          minWidth: 170,
                          child: ElevatedButton(
                            child: Text("Detect in Image"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StaticImage(),
                                ),
                              );
                            },
                          ),
                        ),
                        ButtonTheme(
                          minWidth: 160,
                          child: ElevatedButton(
                            child: Text("Real Time Detection"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LiveFeed(cameras),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  aboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: "Object Detector App",
      applicationLegalese: "By Utkarsh, Sushanto and Vedant",
      applicationVersion: "1.0",
    );
  }
}
