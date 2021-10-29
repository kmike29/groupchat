import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/tabs/private_messages.dart';
import 'package:groupchat/tabs/search_screen.dart';
import 'package:styled_widget/styled_widget.dart';

import '../constants.dart';

class FriendsScreen extends StatefulWidget {
  static const String id = 'register_screen';

  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var friends;

    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser!.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        friends = doc.data() as Map<String, dynamic>;
      });
    });

    var user;

    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('dm')
        .where('users', arrayContains: currentUser!.email)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("Friends"),
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
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

              return ListTile(
                title: currentUser!.email==data['users'][0] ? Text(data['users'][1]) : Text(data['users'][0]),
                //subtitle: Text(data['name']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PrivateChatScreen(name: document.id,friend: currentUser!.email==data['users'][0] ? data['users'][1] : data['users'][0],),
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
          Navigator.pushNamed(context, SearchScreen.id);
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
