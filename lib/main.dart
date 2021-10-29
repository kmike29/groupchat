import 'package:flutter/material.dart';
import 'package:groupchat/screens/group_chat.dart';
import 'package:groupchat/screens/groups_sceen.dart';
import 'package:groupchat/screens/welcome_screen.dart';
import 'package:groupchat/screens/register_screen.dart';
import 'package:groupchat/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:groupchat/tabs/search_screen.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FlashChat());
}

class FlashChat extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<FlashChat> {
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch(e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        GroupScreen.id: (context) => GroupScreen(),
        SearchScreen.id: (context) => SearchScreen(),

        //GroupChatScreen.id: (context) => GroupChatScreen(),

      },
    );
  }
}
