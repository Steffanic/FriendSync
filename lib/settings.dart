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
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/home.dart';
import 'package:friend_sync/utility.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsPage extends StatefulWidget {
  final FirebaseAuth? auth;
  final DatabaseReference? db;

  SettingsPage({this.auth, this.db});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in before building.
    checkForLoggedInUser(context, widget.auth!);

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () => _onItemTapped(0),
                      child: Icon(Icons.arrow_left_rounded)),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final gSign = GoogleSignIn();
                  if (gSign.currentUser != null) {
                    await gSign.signOut().then((value) async {
                      await widget.auth!.signOut().then((_) {
                        return Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return HomePage(
                            auth: widget.auth,
                            db: widget.db,
                          );
                        }));
                      });
                    });
                  }
                  await widget.auth!.signOut().then((_) {
                    return Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return HomePage(
                        auth: widget.auth,
                        db: widget.db,
                      );
                    }));
                  });
                },
                child: Text("Log Out."),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pop(context);
    }
    if (index == 1) {}
  }
}
