import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:groupchat/constants.dart';
import 'groups_sceen.dart';


class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen>
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
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String email="";
    String password="";

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;




    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              onChanged: (value) {
                if (value == null || value.isEmpty ) {
                  print ('Please enter a valid email');
                }
                email = value;
              },
              decoration:
              kTextFieldDecoration.copyWith(hintText: 'Enter your email',
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              onChanged: (value) {
                password = value;
              },
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password'),
            ),



            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed:() async{
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email,
                        password: password
                    );

                    Navigator.pushNamed(context, GroupScreen.id);
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          const Text('No user found for that email.'),
                        ),
                      );
                    } else if (e.code == 'wrong-password') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          const Text('Wrong password provided for that user.'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
