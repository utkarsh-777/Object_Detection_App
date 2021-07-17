import 'package:flutter/material.dart';
import 'package:object_detection/screens/AddTodos.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:object_detection/screens/EditTodos.dart';

class Todos extends StatefulWidget {
  Todos({Key key}) : super(key: key);

  @override
  _TodosState createState() => _TodosState();
}

class _TodosState extends State<Todos> {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  navigateToEditTodos(id) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => EditTodos(id: id)));
  }

  getImage(snapshot) {
    if (snapshot.value['photoUrl'] == "empty") {
      return DecorationImage(image: AssetImage("assets/todo.png"));
    } else {
      return DecorationImage(image: NetworkImage(snapshot.value['photoUrl']));
    }
  }

  getColor(isCompleted) {
    if (isCompleted) {
      return Colors.lightGreen;
    } else {
      return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.orangeAccent,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddTodos()));
        },
      ),
      body: Container(
        child: FirebaseAnimatedList(
          duration: const Duration(milliseconds: 300),
          query: _databaseReference,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            return GestureDetector(
              onTap: () {
                navigateToEditTodos(snapshot.key);
              },
              child: Card(
                color: getColor(snapshot.value['isCompleted']),
                elevation: 3,
                child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, image: getImage(snapshot)),
                      ),
                      Container(
                        margin: EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${snapshot.value['title']}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${snapshot.value['description']}",
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
            );
          },
        ),
      ),
    );
  }
}
