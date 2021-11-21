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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/forms.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class LogInPage extends StatelessWidget {
  final FirebaseAuth? auth;
  final DatabaseReference? db;
  final firebase_storage.FirebaseStorage? storage;
  final GoogleAuthProvider? googleProvider;

  LogInPage({this.auth, this.db, this.storage, this.googleProvider});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Expanded(
              flex: 2,
              child: Text(
                "Log in:",
                style: TextStyle(fontSize: 36),
              ),
            ),
            const Flexible(
              flex: 2,
              child: Image(
                  image: NetworkImage(
                      "https://img.freepik.com/free-vector/mobile-login-concept-illustration_114360-135.jpg?size=338&ext=jpg")),
            ),
            Flexible(
                flex: 3,
                child: LogInForm(
                  auth: auth,
                  db: db,
                  storage: storage,
                  googleProvider: googleProvider,
                )),
          ],
        ),
      ),
    );
  }
}
