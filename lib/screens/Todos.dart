import 'package:flutter/material.dart';
import 'package:object_detection/screens/AddTodos.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:object_detection/screens/EditTodos.dart';

class Todos extends StatefulWidget {
  final String user;
  Todos({Key key, @required this.user}) : super(key: key);

  @override
  _TodosState createState() => _TodosState(user);
}

class _TodosState extends State<Todos> {
  String user;
  _TodosState(this.user);

  bool isLoading = true;
  List todoData = [];

  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  navigateToEditTodos(BuildContext context, id, user) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => EditTodos(id: id, user: user)));
  }

  getImage(photoUrl) {
    if (photoUrl == "empty") {
      return DecorationImage(image: AssetImage("assets/todo.png"));
    } else {
      return DecorationImage(image: NetworkImage(photoUrl));
    }
  }

  getColor(isCompleted) {
    if (isCompleted) {
      return Colors.lightGreen;
    } else {
      return Colors.redAccent;
    }
  }

  getData() async {
    _databaseReference.child(user).onValue.listen(
      (event) {
        List data = [];
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> values = event.snapshot.value;
          values.forEach((key, values) {
            data.add({
              'key': key,
              'title': values['title'],
              'description': values['description'],
              'isCompleted': values['isCompleted'],
              'photoUrl': values['photoUrl']
            });
          });
        }
        setState(() {
          todoData = data;
          isLoading = false;
        });
        print(todoData.length);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warehouse'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.orangeAccent,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddTodos(user: user)));
        },
      ),
      body: Container(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : todoData.length > 0
                  ? ListView.builder(
                      itemCount: todoData.length,
                      itemBuilder: (BuildContext context, int index) =>
                          (Container(
                        child: Container(
                          child: GestureDetector(
                            onTap: () {
                              navigateToEditTodos(
                                  context, todoData[index]['key'], user);
                            },
                            child: Card(
                              color: getColor(todoData[index]['isCompleted']),
                              elevation: 3,
                              child: Container(
                                margin: EdgeInsets.all(10.0),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: getImage(
                                              todoData[index]['photoUrl'])),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${todoData[index]['title']}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "${todoData[index]['description']}",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                    )
                  : Center(
                      child: Text(
                        'Nothing here!',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    )),
    );
  }
}
