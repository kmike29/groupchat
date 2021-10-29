import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:groupchat/constants.dart';

class PrivateChatScreen extends StatefulWidget {
  static const String id = 'private_chat_screen';
  final String name;
  final String friend;

  PrivateChatScreen({Key? key, required this.name, required this.friend})
      : super(key: key);

  @override
  _PrivateChatState createState() => _PrivateChatState();
}

class _PrivateChatState extends State<PrivateChatScreen> {
  final messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String messageText = "";

    var user,other;

    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser!.email)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        user = doc.id;
      });
    });

    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.friend)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        other = doc.id;
      });
    });

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: (int selected) {
              setState(() {
                switch (selected) {
                  case 1:
                    CollectionReference dms =
                        FirebaseFirestore.instance.collection('dm');
                    CollectionReference users =
                    FirebaseFirestore.instance.collection('users');

                    dms
                        .doc(widget.name)
                        .delete()
                        .then((value) =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Member Removed"),
                              ),
                            ))
                        .catchError(
                            (error) => print("Failed to update user: $error"));

                    users
                        .doc(other)
                        .update({'friends': FieldValue.arrayRemove([currentUser!.email])})
                        .then((value) => print("User Updated"))
                        .catchError((error) =>
                        print("Failed to update user: $error"));

                    users
                        .doc(user)
                        .update({'friends': FieldValue.arrayRemove([widget.friend])})
                        .then((value) => print("User Updated"))
                        .catchError((error) =>
                        print("Failed to update user: $error"));
                    Navigator.of(context).pop();
                    break;
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Unfriend'),
              ),
            ],
          )
        ],
        title: Text(widget.friend),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            PMessagesStream(dm: widget.name),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      CollectionReference messages =
                          FirebaseFirestore.instance.collection('p_messages');

                      messages.add({
                        'text': messageText,
                        'sender': currentUser!.email,
                        'dm': widget.name,
                        'date': DateTime.now()
                      });

                      messageTextController.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PMessagesStream extends StatelessWidget {
  final String dm;
  const PMessagesStream({Key? key, required this.dm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('p_messages')
          .where('dm', isEqualTo: dm)
          .orderBy('date',descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message.get('text');
          final messageSender = message.get('sender');

          final messageBubble = MessageBubble(
            id: message.id,
            sender: messageSender,
            text: messageText,
            isMe: currentUser!.email == messageSender,
          );

          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.sender,
      required this.text,
      required this.isMe,
      required this.id});

  final String sender;
  final String text;
  final bool isMe;
  final String id;

  @override
  Widget build(BuildContext context) {
    int value;
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))
                  : BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
              elevation: 5.0,
              color: isMe ? Colors.lightBlueAccent : Colors.white,
              child: !isMe
                  ? Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black54,
                          fontSize: 15.0,
                        ),
                      ),
                    )
                  : TextButton(
                      onLongPress: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          content: const Text('Delete the Message?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                CollectionReference messages = FirebaseFirestore
                                    .instance
                                    .collection('p_messages');
                                messages
                                    .doc(this.id)
                                    .delete()
                                    .then((value) => print(" Deleted"))
                                    .catchError((error) =>
                                        print("Failed to delete : $error"));

                                Navigator.pop(context, 'yes');
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {},
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black54,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    )),
        ],
      ),
    );
  }
}
