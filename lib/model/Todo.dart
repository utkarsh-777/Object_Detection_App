import 'package:firebase_database/firebase_database.dart';

class Todo {
  String _id;
  String _title;
  String _description;
  String _photoUrl;
  bool _isCompleted;

  //constructor for add
  Todo(
    this._title,
    this._description,
    this._photoUrl,
    this._isCompleted,
  );

  //constructor for edit
  Todo.withId(this._id, this._title, this._description, this._photoUrl,
      this._isCompleted);

  //getters
  String get id => this._id;
  String get title => this._title;
  String get description => this._description;
  bool get isCompleted => this._isCompleted;
  String get photoUrl => this._photoUrl;

  //setters
  set title(String title) => this._title = title;
  set description(String description) => this._description = description;
  set isCompleted(bool isCompleted) => this._isCompleted = isCompleted;
  set photoUrl(String photoUrl) => this._photoUrl = photoUrl;

  Todo.fromSnapshot(DataSnapshot snapshot) {
    this._id = snapshot.key;
    this._title = snapshot.value['title'];
    this._description = snapshot.value['description'];
    this._isCompleted = snapshot.value['isCompleted'];
    this._photoUrl = snapshot.value['photoUrl'];
  }

  Map<String, dynamic> toJson() {
    return {
      "title": _title,
      "description": _description,
      "isCompleted": _isCompleted,
      "photoUrl": _photoUrl,
    };
  }
}
