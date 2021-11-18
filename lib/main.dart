/*
   Copyright 2021 Patrick Steffanic

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   */

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';
import 'package:friend_sync/forms.dart';
import 'package:friend_sync/login.dart';
import 'package:friend_sync/providers.dart';
import 'package:friend_sync/settings.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
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
            FirebaseAuth _auth = FirebaseAuth.instance;
            final _db = FirebaseDatabase.instance.reference();
            final firebase_storage.FirebaseStorage _storage =
                firebase_storage.FirebaseStorage.instance;

            final GoogleAuthProvider _googleProvider = GoogleAuthProvider();

            return ChangeNotifierProvider<FriendGroupProvider>(
                create: (context) => FriendGroupProvider(
                    auth: _auth,
                    db: _db,
                    storage: _storage,
                    googleProvider: _googleProvider),
                child: HomePage(
                  auth: _auth,
                  db: _db,
                  storage: _storage,
                  googleProvider: _googleProvider,
                ));
          }

          return MaterialApp(
              home: Container(
            child: Text("Loading..."),
          ));
        });
  }
}
