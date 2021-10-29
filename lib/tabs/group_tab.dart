import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:groupchat/screens/group_chat.dart';
import 'package:groupchat/screens/groups_sceen.dart';
import 'package:styled_widget/styled_widget.dart';

var currentUser = FirebaseAuth.instance.currentUser;

class GroupTab extends StatefulWidget {
  static const String id = 'group_tab';

  @override
  _GroupTabState createState() => _GroupTabState();
}

class _GroupTabState extends State<GroupTab> {

  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance.collection('groups').where('users',arrayContains: currentUser!.email).snapshots();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String name = "";


    return Scaffold(
      appBar: AppBar(
        title: Text("Groups"),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data()! as Map<String, dynamic>;

              return ListTile(
                title: Text(data['name']),
                //subtitle: Text(data['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupChatScreen(name:
                      data['name'],group_id: document.id,admin:data['admins']
                          .contains(currentUser!.email)),
                    ),
                  );
                },
              ).card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Stack(
                    overflow: Overflow.visible,
                    children: <Widget>[
                      Positioned(
                        right: -40.0,
                        top: -40.0,
                        child: InkResponse(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: CircleAvatar(
                            child: Icon(Icons.close),
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                onChanged: (String value) {
                                  name = value;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Enter the name',
                                ),
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a valid email';
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RaisedButton(
                                child: Text("Create group"),
                                onPressed: () {
                                  CollectionReference groups = FirebaseFirestore
                                      .instance
                                      .collection('groups');
                                  groups
                                      .add({
                                    'name': name,
                                    'users':[currentUser!.email],
                                    'admins':[currentUser!.email]
                                  })
                                      .then((value) => print("group Added"))
                                      .catchError((error) =>
                                      print("Failed to add user: $error"));
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Group Added!'),
                                    ),
                                  );

                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
