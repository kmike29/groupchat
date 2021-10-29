import 'package:firestore_search/firestore_search.dart';
import 'package:flutter/material.dart';
import 'package:groupchat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class SearchScreen extends StatefulWidget {
  static const String id = 'search_screen';

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<SearchScreen>
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
    final messageTextController = TextEditingController();
    var searchText = "";
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



    Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('users')
        .where('username', arrayContains: searchText)
        .snapshots();
    FirebaseAuth auth = FirebaseAuth.instance;

    return FirestoreSearchScaffold(

      firestoreCollectionName: 'users',
      searchBy: 'email',
      scaffoldBody: const Center(child: Text(' Search Users')),
      dataListFromSnapshot: DataModel().dataListFromSnapshot,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<DataModel>? dataList = snapshot.data;

          return ListView.builder(
              itemCount: dataList?.length ?? 0,
              itemBuilder: (context, index) {
                final DataModel data = dataList![index];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(data.mail.toString()),
                      //subtitle: Text(data['name']),
                      onTap:  () {

                        if(data.mail.toString()!=currentUser!.email){

                          showDialog<String>(
                            context: context,
                            builder: (BuildContext
                            context) =>
                                AlertDialog(
                                  content: const Text(
                                      'Befriend this user?'),
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
                                        CollectionReference users = FirebaseFirestore.instance.collection('users');

                                        users.doc(user).get().then((querySnapshot) {
                                          var datau = querySnapshot.data()
                                          as Map<String,
                                              dynamic>;
                                          var friends = datau['friends'];
                                          print("friends");
                                          print(friends);


                                          if (!friends.contains(data.mail.toString())) {
                                            CollectionReference dm = FirebaseFirestore.instance.collection('dm');
                                            dm.add({'users': [data.mail.toString(),currentUser!.email],})
                                                .then((value) => print("User Added"))
                                                .catchError(
                                                    (error) => print("Failed to add user: $error"));

                                            users
                                                .doc(user)
                                                .update({'friends': FieldValue.arrayUnion([data.mail.toString()])})
                                                .then((value) => print("User Updated"))
                                                .catchError((error) =>
                                                print("Failed to update user: $error"));

                                            users
                                                .doc(data.id)
                                                .update({'friends': FieldValue.arrayUnion([currentUser!.email])})
                                                .then((value) => print("User Updated"))
                                                .catchError((error) =>
                                                print("Failed to update user: $error"));

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text('You have a new friend!'),
                                              ),
                                            );

                                            Navigator.of(context).pop();

                                          }else{
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                    'Already a Friend'
                                                        ' '),
                                              ),
                                            );
                                            Navigator.of(context).pop();

                                          }

                                        } );
                                      },
                                      child: Text('Yes'),
                                    ),
                                  ],
                                ),
                          );

}else {
                              ScaffoldMessenger.of(
                                  context)
                                  .showSnackBar(
                                SnackBar(
                                  content: const Text('You cant add yourself😅!'),
                                ),
                              );
                              Navigator.of(context).pop();

                        }
                          }
                    )
                  ],
                );
              });
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text('No Results Returned'),
            );
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class DataModel {
  final String? mail;
  final String? username;
  final String? id;

  DataModel({this.mail, this.username,this.id});

  //Create a method to convert QuerySnapshot from Cloud Firestore to a list of objects of this DataModel
  //This function in essential to the working of FirestoreSearchScaffold

  List<DataModel> dataListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      final Map<String, dynamic> dataMap =
          snapshot.data() as Map<String, dynamic>;

      return DataModel(mail: dataMap['email'], username: dataMap['username'],id:snapshot.id);
    }).toList();
  }
}
