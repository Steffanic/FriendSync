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

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';
import 'package:friend_sync/forms.dart';
import 'package:friend_sync/group.dart';
import 'package:friend_sync/login.dart';
import 'package:friend_sync/providers.dart';
import 'package:friend_sync/settings.dart';
import 'package:friend_sync/utility.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;



class HomePage extends StatefulWidget {
  final FirebaseAuth? auth;
  final DatabaseReference? db;
  final firebase_storage.FirebaseStorage? storage;
  final GoogleAuthProvider? googleProvider;

  HomePage({Key? key, this.auth, this.db, this.storage, this.googleProvider})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isUserLoggedIn = false;

  _HomePageState();

  @override
  void initState() {
    isUserLoggedIn = checkForLoggedInUser(context, widget.auth!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isUserLoggedIn) {
      return LogInPage(
        auth: widget.auth,
        db: widget.db,
        storage: widget.storage,
        googleProvider: widget.googleProvider,
      );
    }
    // get friend group metadata from db

    return MaterialApp(
      title: "Friend Sync",
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(auth: widget.auth!),
        '/group': (context) => GroupPage(
              auth: widget.auth!,
            ),
        '/group_settings': (context) => SettingsPage(
              auth: widget.auth,
              db: widget.db,
              context: context,
            ),
        '/user_settings': (context) => SettingsPage(
              auth: widget.auth,
              db: widget.db,
              context: context,
            ),
        '/settings': (context) => SettingsPage(
              auth: widget.auth,
              db: widget.db,
              context: context,
            ),
        '/add_new_group': (context) => AddNewGroupPage(auth: widget.auth)
      },
    );
  }
}

class MainPage extends StatefulWidget {
  //Consider making Stateless
  final FirebaseAuth auth;
  MainPage({Key? key, required this.auth}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  _MainPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.blue])),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child:
                  CurrentUserStatusCard(userID: widget.auth.currentUser!.uid),
              flex: 2,
            ),
            Expanded(
              child: Consumer<FriendGroupProvider>(
                builder: (context, friendGroupProvider, child) => Container(
                  margin: EdgeInsets.only(left: 32, right: 32),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GridView.count(
                      crossAxisSpacing: 25,
                      crossAxisCount: 2,
                      clipBehavior: Clip.antiAlias,
                      children: [
                        ...friendGroupProvider.friendGroups!
                            .map((groupMetaData) {
                          friendGroupProvider
                              .updateGroupSize(groupMetaData.groupID);
                          return FriendGroupCard(
                            groupMetaData: groupMetaData,
                          );
                        }).toList(),
                        AddNewGroupCard()
                      ],
                    ),
                  ),
                ),
              ),
              flex: 4,
            )
          ],
        ),
      ),
    ));
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
    if (index == 1) {
      Navigator.pushNamed(context, "/settings")
          .then((value) => checkForLoggedInUser(context, widget.auth));
    }
  }
}

class CurrentUserStatusCard extends StatelessWidget {
  final String? userID;

  CurrentUserStatusCard({this.userID});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.purple[100],
      ),
      // Begin row
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              flex: 3,
              child: Consumer<FriendGroupProvider>(
                builder: (context, friendGroupProvider, child) => Container(
                  margin: EdgeInsets.all(IMAGE_MARGIN),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    image: DecorationImage(
                        image: NetworkImage(friendGroupProvider
                            .getMemberByID(userID!)
                            .memberProfilePicture)),
                    shape: BoxShape.circle,
                  ), //Profile picture
                ),
              )),
          Expanded(
            flex: 6,
            child: Container(
                margin: EdgeInsets.all(6),
                child: Consumer<FriendGroupProvider>(
                  builder: (context, friendGroupProvder, child) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                          flex: 4,
                          child: FittedBox(
                              child: Text(
                            friendGroupProvder
                                .getMemberByID(userID!)
                                .memberName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: "Noto Sans"),
                          ))),
                      Flexible(
                          flex: 2,
                          child: Text(
                              friendGroupProvder
                                  .getMemberByID(userID!)
                                  .memberStatus,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontFamily: "Noto Sans"))),
                    ],
                  ),
                )),
          ),
          Flexible(
              flex: 1,
              child: Container(
                margin: EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pushNamed(context, "/settings"),
                      child: const Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(
                      Icons.person,
                      color: Colors.green,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class FriendGroupCard extends StatelessWidget {
  final GroupMetaData groupMetaData;

  FriendGroupCard({required this.groupMetaData});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        // Design decision to go with square tiles
        aspectRatio: 1,
        child: Consumer<FriendGroupProvider>(
          builder: (context, friendGroupProvider, child) => InkWell(
            // Tapping on a group page tile will bring you to a new group page
            // it passes the details about the group that was selected as arguments.
            onTap: () {
              Navigator.pushNamed(context, '/group',
                  arguments: groupMetaData.groupID);
            },
            child: Container(
              height: 150,
              margin: EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.purple[100],
              ),
              // Begin row
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                      flex: 5,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                                // This is the group's profile picture
                                flex: 5,
                                child: Container(
                                  margin: EdgeInsets.all(IMAGE_MARGIN),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                            groupMetaData.groupImageURL)),
                                    shape: BoxShape.circle,
                                  ), //Profile picture
                                )),
                            Flexible(
                                // These are the favorite icon
                                // and number of member icon
                                flex: 2,
                                child: Container(
                                    margin:
                                        const EdgeInsets.only(right: 6, top: 6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        (groupMetaData.isFavoriteGroup
                                            ? Icon(Icons.star,
                                                color: Colors.yellow)
                                            : Icon(Icons.star_border,
                                                color: Colors.white)),
                                        SizedBox(
                                          width: 35,
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                        "${groupMetaData.groupSize}")),
                                                Icon(
                                                  Icons.person,
                                                  color: Colors.green,
                                                ),
                                              ]),
                                        ),
                                      ],
                                    )))
                          ])),
                  Expanded(
                    flex: 2,
                    child: Container(
                        margin: EdgeInsets.all(8),
                        child: FittedBox(
                            child: Text(
                          groupMetaData.groupName,
                          style: TextStyle(fontFamily: "Noto Sans"),
                        ))),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class AddNewGroupCard extends StatelessWidget {
  AddNewGroupCard();
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1,
        child: InkWell(
            // Tapping on a group page tile will bring you to a new group page
            // it passes the details about the group that was selected as arguments.
            onTap: () {
              Navigator.pushNamed(
                context,
                '/add_new_group',
              );
            },
            child: Container(
                margin: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.purple[100],
                ),
                // Begin row
                child: const FittedBox(
                    fit: BoxFit.fill,
                    child: Icon(
                      Icons.add_circle,
                    )))));
  }
}

class BlankCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.purple[100],
          ),
          // Begin row
        ));
  }
}
