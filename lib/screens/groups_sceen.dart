import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:groupchat/tabs/friends_screen.dart';
import 'package:groupchat/tabs/group_tab.dart';
import 'package:groupchat/tabs/search_screen.dart';
import 'package:groupchat/tabs/setting_screen.dart';

import 'group_chat.dart';

var currentUser = FirebaseAuth.instance.currentUser;

class GroupScreen extends StatefulWidget {
  static const String id = 'group_screen';

  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<GroupScreen> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('groups')
      .where('users', arrayContains: currentUser!.email)
      .snapshots();
  FirebaseAuth auth = FirebaseAuth.instance;

  int _selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[
    GroupTab(),
    FriendsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String name = "";



    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,color: Colors.black),
            label: 'Home',
            activeIcon:  Icon(Icons.home,color: Colors.blueAccent),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.groups,color: Colors.black),
            label: 'friends',
            activeIcon: Icon(Icons.groups,color: Colors.blueAccent),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,color: Colors.black),
            label: 'settings',
            activeIcon: Icon(Icons.settings,color: Colors.blueAccent),
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
