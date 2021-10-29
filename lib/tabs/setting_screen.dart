import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/constants.dart';

class SettingsScreen extends StatefulWidget {
  static const String id = 'Settings_screen';

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            Colors.yellow,
                            Colors.deepOrange,
                            Colors.redAccent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: ()  async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                      Navigator.pop(context);

                    },
                    child: const Text('Log out'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            Colors.yellow,
                            Colors.deepOrange,
                            Colors.redAccent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      primary: Colors.white,
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.currentUser!.delete().then((value) =>
                        {

                        });
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'requires-recent-login') {
                          print('The user must reauthenticate before this operation can be executed.');
                        }
                      }
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Delete account'),
                  ),
                ],
              ),
            ),
          ],
        ),

      )  ,

    );
  }
}
