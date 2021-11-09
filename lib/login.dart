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

  LogInPage({this.auth, this.db, this.storage});

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
              flex: 4,
              child: Image(
                  image: NetworkImage(
                      "https://img.freepik.com/free-vector/mobile-login-concept-illustration_114360-135.jpg?size=338&ext=jpg")),
            ),
            Flexible(
                flex: 3,
                child: LogInForm(auth: auth, db: db, storage: storage)),
          ],
        ),
      ),
    );
  }
}
