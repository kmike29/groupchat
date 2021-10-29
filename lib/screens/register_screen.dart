import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:groupchat/constants.dart';

import 'groups_sceen.dart';

class RegisterScreen extends StatefulWidget {
  static const String id = 'register_screen';

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<RegisterScreen>
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
    String email = "";
    String password = "";
    String cpwd = "";
    String cemail = "";
    String username = "";
    String firstName = "";
    String lastName = "";
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;




    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: kTextFieldDecoration.copyWith(
                hintText: 'Enter your email',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return ('Enter a valid email');
                }
              },
              onChanged: (String value) {
                email = value;
                print(email);
              },
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: kTextFieldDecoration.copyWith(
                hintText: 'Confirm your email',
              ),
              onChanged: (String value) {
                cemail = value;
              },
              validator: (String? value) {
                if (email != cemail) {
                  return ('Email Not matching');
                }
              },
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              obscureText: true,
              decoration: kTextFieldDecoration.copyWith(
                hintText: 'Enter your password (at least 8 characters)',
              ),
              onChanged: (String value) {
                password = value;
              },
              validator: (String? value) {
                if (value == null || value.isEmpty || value.length < 8) {
                  return ('At least 8 characters');
                }
              },
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              obscureText: true,
              decoration: kTextFieldDecoration.copyWith(
                hintText: 'Confirm your password',
              ),
              onChanged: (String value) {
                cpwd = value;
              },
              validator: (String? value) {
                if (password != cpwd) {
                  return ('Passwords dont match');
                }
              },
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    try {
                      final newUser = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: email.trim(), password: password.trim()).then((value)
                      {
                        CollectionReference users = FirebaseFirestore
                          .instance.collection('users');
                          users.add({'email': email}).then((value) {
                        print("User Added");

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                            const Text('Your account was created! Log in'),
                          ),
                        );
                        Navigator.of(context).pop();
                      }).catchError(
                              (error) => print("Failed to add user: $error"));});

                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'The password provided is too weak!'),
                          ),
                        );
                      } else if (e.code == 'email-already-in-use') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'The account already exists for that email.'),
                          ),
                        );
                      }
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
