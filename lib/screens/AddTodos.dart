import 'package:flutter/material.dart';
import 'package:object_detection/model/Todo.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class AddTodos extends StatefulWidget {
  final String user;
  AddTodos({Key key, @required this.user}) : super(key: key);

  @override
  _AddTodosState createState() => _AddTodosState(user);
}

class _AddTodosState extends State<AddTodos> {
  String user;
  _AddTodosState(this.user);

  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _databaseReference = _databaseReference.child(user);
  }

  String _title = '';
  String _description = '';
  String _photoUrl = 'empty';
  bool _isCompleted = false;

  navigateToLastScreen(BuildContext context) {
    Navigator.pop(context);
  }

  saveTodo(BuildContext context) async {
    if (_title.isNotEmpty && _description.isNotEmpty && _photoUrl.isNotEmpty) {
      Todo todo = Todo(_title, _description, _photoUrl, _isCompleted);
      await _databaseReference.push().set(todo.toJson());
      navigateToLastScreen(context);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Field Required"),
              content: Text("All fields are required!"),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'))
              ],
            );
          });
    }
  }

  Future pickImage() async {
    PickedFile file = await ImagePicker().getImage(
        source: ImageSource.gallery, maxHeight: 200.0, maxWidth: 200.0);
    File photo = File(file.path);
    String fileName = basename(photo.path);
    uploadImage(photo, fileName);
  }

  void uploadImage(file, fileName) async {
    Reference _storageReference =
        FirebaseStorage.instance.ref().child(fileName);
    _storageReference.putFile(file).whenComplete(() {
      setState(() async {
        _photoUrl = await _storageReference.getDownloadURL();
      });
    });
  }

  getImage() {
    if (_photoUrl == "empty") {
      return AssetImage("assets/todo.png");
    } else {
      return NetworkImage(_photoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Todo'),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: ListView(
            children: [
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: GestureDetector(
                  onTap: () {
                    this.pickImage();
                  },
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover, image: getImage())),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      this._title = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      this._description = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(100, 20, 100, 20)),
                  onPressed: () {
                    saveTodo(context);
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
