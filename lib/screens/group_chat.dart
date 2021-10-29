import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:groupchat/constants.dart';

class GroupChatScreen extends StatefulWidget {
  static const String id = 'group_chat_screen';
  final String name;
  bool admin;

  String group_id;

  GroupChatScreen(
      {Key? key,
      required this.name,
      required String this.group_id,
      required this.admin})
      : super(key: key);

  @override
  _GroupChatState createState() => _GroupChatState();
}

var currentUser = FirebaseAuth.instance.currentUser;

class _GroupChatState extends State<GroupChatScreen> {
  final messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String add_username = "";
    String messageText = "";
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('users')
        .where('friends', arrayContains: currentUser!.email)
        .snapshots();

    Stream<DocumentSnapshot> groupStream = FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.group_id)
        .snapshots();

    var userid;

    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: currentUser!.email)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        userid = result.id;
      });
    });

    void doubleDialog() {
      showDialog<String>(
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
                Navigator.pop(context, 'yes');
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      );
    }

    var group_users;
    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.group_id)
        .get()
        .then((querySnapshot) {
      var data = querySnapshot.data() as Map<String, dynamic>;
      group_users = data['users'];
      print("data");
      print(data['users']);
    });

    var tab1 = [
      const PopupMenuItem<int>(
        value: 1,
        child: Text('Add Users'),
      ),
      const PopupMenuItem<int>(
        value: 2,
        child: Text('See list of users'),
      ),
      const PopupMenuItem<int>(
        value: 5,
        child: Text('Add admins'),
      ),
      const PopupMenuItem<int>(
        value: 6,
        child: Text('Remove admins'),
      ),
      const PopupMenuItem<int>(
        value: 3,
        child: Text('Delete group'),
      ),
      const PopupMenuItem<int>(
        value: 4,
        child: Text('Leave group'),
      ),

    ];

    var tab2 = [

      const PopupMenuItem<int>(
        value: 2,
        child: Text('See list of users'),
      ),
      const PopupMenuItem<int>(
        value: 4,
        child: Text('Leave group'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: (int selected) {
              setState(() {
                switch (selected) {
                  case 1:
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
                                Container(
                                    width: 300,
                                    height: 300,
                                    child: StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userid)
                                            .snapshots(),
                                        builder: (context,
                                            AsyncSnapshot<DocumentSnapshot>
                                                snapshot) {
                                          if (!snapshot.hasData) {
                                            return Text("Loading");
                                          }
                                          print(userid);
                                          var userDocument = snapshot.data;
                                          var friends =
                                              userDocument!['friends'];

                                          return ListView.builder(
                                              padding: const EdgeInsets.all(8),
                                              itemCount: friends.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {


                                                return ListTile(
                                                  title: Text(friends[index]),
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                    showDialog<String>(
                                                        context: context,
                                                        builder: (BuildContext
                                                        context) =>
                                                        AlertDialog(
                                                          content: const Text(
                                                              'Add this user?'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context,
                                                                      'Cancel'),
                                                              child: Text('Cancel'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                            CollectionReference groups =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                'groups');

                                                            groups   .doc(widget.group_id)
                                                                .get()
                                                                .then((querySnapshot) {
                                                              var data =
                                                              querySnapshot.data()
                                                              as Map<String,
                                                                  dynamic>;
                                                              group_users =
                                                              data['users'];
                                                              print("Users");
                                                              print(group_users);
                                                              print(friends[index]);

                                                              print(
                                                                  group_users.contains(
                                                                      friends[index]));

                                                              if (!group_users.contains(
                                                                  friends[index])) {
                                                                groups
                                                                    .doc(
                                                                    widget.group_id)
                                                                    .update({
                                                                  'users': FieldValue
                                                                      .arrayUnion([
                                                                    friends[index]
                                                                  ])
                                                                })
                                                                    .then((value) =>
                                                                    ScaffoldMessenger.of(
                                                                        context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                        const Text(
                                                                            'Welcome our new member '),
                                                                      ),
                                                                    ))
                                                                    .catchError(
                                                                        (error) => print(
                                                                        "Failed to update user: $error"));
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                    context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content: const Text(
                                                                        'Already a member'
                                                                            ' '),
                                                                  ),
                                                                );
                                                              }

                                                              Navigator.of(context).pop();

                                                            });

                                                          },
                                                          child: Text('Yes'),
                                                        ),
                                                      ],
                                                    ));



                                                  },
                                                );
                                              });
                                        }))
                              ],
                            ),
                          );
                        });
                    break;
                  case 2:
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
                                Container(
                                  width: 300,
                                  height: 300,
                                  child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('groups')
                                          .doc(widget.group_id)
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<DocumentSnapshot>
                                              snapshot) {
                                        if (!snapshot.hasData) {
                                          return Text("Loading");
                                        }
                                        var ggusers = snapshot.data!["users"];
                                        var gusers =List.from(ggusers);
                                        gusers.remove(currentUser!.email);
                                        /*return Text(gusers!["users"].toString
                                          ());*/
                                        return ListView.builder(
                                            padding: const EdgeInsets.all(8),
                                            itemCount: gusers.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return ListTile(
                                                title: Text(gusers[index]),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  showDialog<String>(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      content: const Text(
                                                          'Remove this user?'),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  'Cancel'),
                                                          child: Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            CollectionReference
                                                                groups =
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'groups');
                                                            groups
                                                                .doc(widget
                                                                    .group_id)
                                                                .update({
                                                                  'users':
                                                                      FieldValue
                                                                          .arrayRemove([
                                                                    gusers[
                                                                        index]
                                                                  ])
                                                                })
                                                                .then((value) =>
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            const Text("Member Removed"),
                                                                      ),
                                                                    ))
                                                                .catchError(
                                                                    (error) =>
                                                                        print(
                                                                            "Failed to update user: $error"));
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text('Yes'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            });
                                      }),
                                )
                              ],
                            ),
                          );
                        });
                    break;
                  case 6:
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
                                Container(
                                  width: 300,
                                  height: 300,
                                  child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('groups')
                                          .doc(widget.group_id)
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                        if (!snapshot.hasData) {
                                          return Text("Loading");
                                        }
                                        var gad = snapshot.data!["admins"];
                                        var gads=List.from(gad);
                                        gads.remove(currentUser!.email);
                                        return ListView.builder(
                                            padding: const EdgeInsets.all(8),
                                            itemCount: gads.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return ListTile(
                                                title: Text(gads[index]),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  showDialog<String>(
                                                    context: context,
                                                    builder: (BuildContext
                                                    context) =>
                                                        AlertDialog(
                                                          content: const Text(
                                                              'Remove admin?'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context,
                                                                      'Cancel'),
                                                              child: Text('Cancel'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                CollectionReference
                                                                groups =
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                    'groups');
                                                                groups
                                                                    .doc(widget
                                                                    .group_id)
                                                                    .update({
                                                                  'admins':
                                                                  FieldValue
                                                                      .arrayRemove([
                                                                    gads[index]
                                                                  ])
                                                                })
                                                                    .then((value) =>
                                                                    ScaffoldMessenger.of(
                                                                        context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                        const
                                                                        Text
                                                                          ("Removed "
                                                                            " admin"),
                                                                      ),
                                                                    ))
                                                                    .catchError(
                                                                        (error) =>
                                                                        print(
                                                                            "Failed to update user: $error"));
                                                                Navigator.of(
                                                                    context)
                                                                    .pop();
                                                              },
                                                              child: Text('Yes'),
                                                            ),
                                                          ],
                                                        ),
                                                  );
                                                },
                                              );
                                            });
                                      }),
                                )
                              ],
                            ),
                          );
                        });
                    break;
                  case 5:
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
                                Container(
                                  width: 300,
                                  height: 300,
                                  child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('groups')
                                          .doc(widget.group_id)
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                        if (!snapshot.hasData) {
                                          return Text("Loading");
                                        }
                                        var ggusers = snapshot.data!["users"];
                                        var gusers =List.from(ggusers);
                                        gusers.remove(currentUser!.email);
                                        /*return Text(gusers!["users"].toString
                                          ());*/
                                        return ListView.builder(
                                            padding: const EdgeInsets.all(8),
                                            itemCount: gusers.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return ListTile(
                                                title: Text(gusers[index]),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  showDialog<String>(
                                                    context: context,
                                                    builder: (BuildContext
                                                    context) =>
                                                        AlertDialog(
                                                          content: const Text(
                                                              'Add admins?'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context,
                                                                      'Cancel'),
                                                              child: Text('Cancel'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                CollectionReference
                                                                groups =
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                    'groups');
                                                                groups
                                                                    .doc(widget
                                                                    .group_id)
                                                                    .update({
                                                                  'admins':
                                                                  FieldValue
                                                                      .arrayUnion([
                                                                    gusers[index]
                                                                  ])
                                                                })
                                                                    .then((value) =>
                                                                    ScaffoldMessenger.of(
                                                                        context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                        const
                                                                        Text
                                                                          ("New admin"),
                                                                      ),
                                                                    ))
                                                                    .catchError(
                                                                        (error) =>
                                                                        print(
                                                                            "Failed to update user: $error"));
                                                                Navigator.of(
                                                                    context)
                                                                    .pop();
                                                              },
                                                              child: Text('Yes'),
                                                            ),
                                                          ],
                                                        ),
                                                  );
                                                },
                                              );
                                            });
                                      }),
                                )
                              ],
                            ),
                          );
                        });
                    break;
                  case 3:
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        content: const Text('Delete the Group?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              CollectionReference groups = FirebaseFirestore
                                  .instance
                                  .collection('groups');
                              groups
                                  .doc(widget.group_id)
                                  .delete()
                                  .then((value) => ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text('Group Deleted '),
                                        ),
                                      ))
                                  .catchError((error) =>
                                      print("Failed to Deleted group: $error"));

                              Navigator.pop(context);
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                    break;
                  case 4:
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        content: const Text('Delete the Group?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              CollectionReference groups = FirebaseFirestore
                                  .instance
                                  .collection('groups');
                              groups
                                  .doc(widget.group_id)
                                  .update({
                                    'users': FieldValue.arrayRemove(
                                        [currentUser!.email])
                                  })
                                  .then((value) => ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text('Group Left'),
                                        ),
                                      ))
                                  .catchError((error) =>
                                      print("Failed to Deleted group: $error"));


                              if(widget.admin){
                                CollectionReference groups = FirebaseFirestore
                                    .instance
                                    .collection('groups');
                                groups
                                    .doc(widget.group_id)
                                    .update({
                                  'admins': FieldValue.arrayRemove(
                                      [currentUser!.email])
                                })
                                    .then((value) => ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: const Text('Group Left'),
                                  ),
                                )).catchError((error) =>
                                    print("Failed to Deleted group: $error"));



                                FirebaseFirestore.instance
                                    .collection('groups')
                                    .doc(widget.group_id)
                                    .get()
                                    .then((querySnapshot) {
                                  var data = querySnapshot.data() as Map<String, dynamic>;
                                  var a1 = data['users'][0];

                                  if( data['admins'].length==0){
                                    groups
                                        .doc(widget.group_id)
                                        .update({
                                      'admins': FieldValue.arrayUnion(
                                          [a1])
                                    });

                                  }

                                });
                              }

                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      ),
                    );
                    break;
                }
              });
            },
            itemBuilder: (BuildContext context) => widget.admin ? tab1 : tab2,
          )
        ],
        title: Text(widget.name),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(group: widget.name),
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
                          FirebaseFirestore.instance.collection('messages');
                      messages.add({
                        'text': messageText,
                        'sender': currentUser!.email,
                        'group': widget.name,
                        'date': DateTime.now()
                      }).catchError(
                          (error) => print("Failed to add user: $error"));


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

class MessagesStream extends StatelessWidget {
  final String group;
  const MessagesStream({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('messages')
          .where('group', isEqualTo: group)
          .orderBy('date', descending: true)
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
  final String id;
  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
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
                                    .collection('messages');
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
