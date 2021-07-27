import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:object_detection/model/Todo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:object_detection/screens/Todos.dart';
import 'dart:io';
import 'package:path/path.dart';

class EditTodos extends StatefulWidget {
  final String id, user;
  EditTodos({Key key, @required this.id, this.user}) : super(key: key);

  @override
  _EditTodosState createState() => _EditTodosState(id, user);
}

class _EditTodosState extends State<EditTodos> {
  String id, user;
  _EditTodosState(this.id, this.user);

  String _title = "";
  String _description = "";
  bool _isCompleted = false;
  String _photoUrl = "empty";

  //handle text editing controller

  TextEditingController _tiController = TextEditingController();
  TextEditingController _deController = TextEditingController();
  //TextEditingController _iCController = TextEditingController();

  bool isLoading = true;

  //db reference
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    this.getTodo(id);
  }

  getTodo(id) async {
    _databaseReference.child(user).child(id).onValue.listen((event) async {
      Todo _todo = Todo.fromSnapshot(event.snapshot);

      _tiController.text = _todo.title;
      _deController.text = _todo.description;

      setState(() {
        this._title = _todo.title;
        this._description = _todo.description;
        this._isCompleted = _todo.isCompleted;
        this._photoUrl = _todo.photoUrl;

        isLoading = false;
      });
    });
  }

  updateTodo(BuildContext context) async {
    if (_title.isNotEmpty && _description.isNotEmpty && _photoUrl.isNotEmpty) {
      Todo updatedTodo =
          Todo.withId(id, _title, _description, _photoUrl, _isCompleted);

      await _databaseReference
          .child(user)
          .child(id)
          .set(updatedTodo.toJson())
          .whenComplete(() => navigateToLastScreen(context));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Fields Required"),
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
        this._photoUrl = await _storageReference.getDownloadURL();
      });
    });
  }

  navigateToLastScreen(BuildContext context) {
    Navigator.pop(context);
  }

  getImage() {
    if (_photoUrl == "empty") {
      return AssetImage("assets/todo.png");
    } else {
      return NetworkImage(_photoUrl);
    }
  }

  deleteTodo(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete?'),
          content: Text('Delete warehouse'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _databaseReference.child(user).child(id).remove();
                Navigator.of(context).pop();
                navigateToLastScreen(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View / Edit warehouse"),
      ),
      body: Container(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.all(20.0),
                child: ListView(
                  children: <Widget>[
                    //image view
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
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                      fit: BoxFit.cover,
                                      image: getImage(),
                                    ))),
                          ),
                        )),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _title = value;
                          });
                        },
                        controller: _tiController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _description = value;
                          });
                        },
                        controller: _deController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    ),
                    //
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Completed',
                            style: TextStyle(fontSize: 17.0),
                          ), //Text
                          SizedBox(width: 10),
                          Checkbox(
                            value: this._isCompleted,
                            onChanged: (bool value) {
                              setState(() {
                                this._isCompleted = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    //
                    SizedBox(
                      height: 50.0,
                    ),
                    // update and delete button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 20.0, right: 50.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding:
                                  EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                              primary: Colors.orangeAccent,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              updateTodo(context);
                            },
                            child: Icon(
                              Icons.update,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 20.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding:
                                  EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                              primary: Colors.red,
                            ),
                            onPressed: () {
                              deleteTodo(context);
                            },
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
