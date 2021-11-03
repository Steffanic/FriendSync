import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';
import 'package:friend_sync/forms.dart';
import 'package:friend_sync/login.dart';
import 'package:friend_sync/providers.dart';
import 'package:friend_sync/settings.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';
import 'group.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var friendGroups = <GroupPageState>[
      GroupPageState(
        [const Member()],
        "Main Squad 💖",
        "The best people in the world.",
        "https://img.huffingtonpost.com/asset/604fc2f2260000cc17d854ff.jpeg",
        1,
        100,
        true,
      ),
      GroupPageState(
        [Member()],
        "Mi Familia",
        "Live, laugh, love",
        "https://media.istockphoto.com/photos/latin-senior-man-serving-the-food-to-his-family-at-dinner-table-picture-id1167975422?k=20&m=1167975422&s=612x612&w=0&h=DvF_AfZwvB3WMTPclXEXf7ysuI4ASowMHcssIDSFKrY=",
        1,
        101,
        false,
      )
    ];

    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("There was an error");
            return MaterialApp(
                home: Scaffold(
                    body: Container(
              child: Text("Error!!!"),
            )));
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            FirebaseAuth auth = FirebaseAuth.instance;

            return HomePage(
              friendGroups: friendGroups,
              user: FirebaseAuth.instance.currentUser,
            );
          }

          return MaterialApp(
              home: Container(
            child: Text("Loading..."),
          ));
        });
  }
}
