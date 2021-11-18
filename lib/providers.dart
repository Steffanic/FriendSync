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
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';
import 'package:image_picker/image_picker.dart';

class GroupNotFoundException implements Exception {
  String groupID;
  GroupNotFoundException(this.groupID);
}

class MemberListNotFoundException implements Exception {
  String groupID;
  MemberListNotFoundException(this.groupID);
}

class MemberNotFoundException implements Exception {
  String memberID;
  MemberNotFoundException(this.memberID);
}

class MemberListEmptyException implements Exception {}

class FriendGroupProvider extends ChangeNotifier {
  final FirebaseAuth? auth;
  final DatabaseReference? db;
  final firebase_storage.FirebaseStorage? storage;
  final GoogleAuthProvider? googleProvider;

  List<GroupMetaData> friendGroups;
  late Map<String, Map<String, dynamic>> memberLists = {};
  List<Member> members;
  String newGroupID;
  String newGroupPhotoURL;

  static const FRIEND_GROUP_PATH = 'friendGroups';
  static const MEMBER_LIST_PATH = 'member_lists';
  static const MEMBER_PATH = 'members';

  late StreamSubscription<Event> _friendGroupStream;

  late StreamSubscription<Event> _memberListStream;

  FriendGroupProvider({
    this.auth,
    this.db,
    this.storage,
    this.googleProvider,
    this.friendGroups = const [],
    this.members = const [],
    this.newGroupID = "",
    this.newGroupPhotoURL = "",
  }) {
    _listenToFriendGroups();
    _listenToMembers();
    _listenToMemberLists();
  }

  GroupMetaData getGroupByID(String groupID) {
    updateGroupSize(groupID);
    final grpOrEmpty =
        friendGroups.where((grp) => grp.groupID == groupID).toList();
    if (grpOrEmpty.isEmpty) {
      throw GroupNotFoundException(groupID);
    } else {
      return grpOrEmpty[0];
    }
  }

  Map<String, dynamic> getMemberList(String groupID) {
    try {
      return memberLists.isEmpty
          ? throw MemberListEmptyException()
          : memberLists[groupID]!;
    } catch (e) {
      print("$e done did happened.");
      if (e.runtimeType == MemberListEmptyException) {
        rethrow;
      }
      print(e);
      throw MemberListNotFoundException(groupID);
    }
  }

  Member getMemberByID(String memberID) {
    final memberOrEmpty =
        members.where((mem) => mem.memberID == memberID).toList();
    if (memberOrEmpty.isEmpty) {
      throw MemberNotFoundException(memberID);
    } else {
      return memberOrEmpty[0];
    }
  }

  String getCurrentMemberID() {
    return auth!.currentUser!.uid;
  }

  void _listenToFriendGroups() {
    try {
      _friendGroupStream = db!.child(FRIEND_GROUP_PATH).onValue.listen((event) {
        friendGroups = Map<String, dynamic>.from(event.snapshot.value)
            .entries
            .map((grp) {
              Map<String, dynamic> gMD = Map<String, dynamic>.from(grp.value);
              return GroupMetaData.fromRTDB(grp.key, gMD);
            })
            .toList()
            .cast<GroupMetaData>();
        print(friendGroups);
        notifyListeners();
      });
    } catch (e) {
      print("You should be testing if this is a cast error $e");
    }
  }

  void _listenToMemberLists() {
    try {
      _memberListStream = db!.child(MEMBER_LIST_PATH).onValue.listen((event) {
        var listOfMembers =
            Map<String, Map<String, dynamic>>.from(event.snapshot.value);
        print(listOfMembers.values);
        memberLists = listOfMembers;
        notifyListeners();
      });
    } catch (e) {
      print("You should be testing if this is a cast error $e");
    }
  }

  void _listenToMembers() {
    try {
      var memberFuture = db!.child(MEMBER_PATH).onValue.listen((event) {
        var memberMap = Map<String, dynamic>.from(event.snapshot.value);
        members = memberMap.entries
            .map((mem) => Member.fromRTDB(mem.key, mem.value))
            .toList();
        notifyListeners();
      });
    } catch (e) {
      print("You should be testing if this is a cast error $e");
    }
  }

  @override
  void dispose() {
    _friendGroupStream.cancel();
    super.dispose();
  }

  bool isInGroup(Member newMember, String groupID) {
    List currentMemberList = getMemberList(groupID)
        .entries
        .map((value) => getMemberByID(value.value))
        .toList();
    if (currentMemberList
        .where((mem) => mem.memberID == newMember.memberID)
        .isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> addGroupToRTDB(String groupName, String groupTagline,
      int groupSize, bool isFavoriteGroup, Uint8List file) async {
    DatabaseReference friendGroupRef = db!.child(FRIEND_GROUP_PATH).push();
    newGroupID = friendGroupRef.key;
    friendGroupRef.set({
      'groupName': groupName,
      'groupTagline': groupTagline,
      'groupImageURL': await uploadGroupPhoto(file, newGroupID),
      'groupSize': groupSize,
      'isFavoriteGroup': isFavoriteGroup
    });

    addMemberToGroupRTDB(Member(memberID: auth!.currentUser!.uid), newGroupID);

    notifyListeners();
  }

  Future<String> uploadGroupPhoto(Uint8List file, String groupID) async {
    try {
      var groupPhotoRef = firebase_storage.FirebaseStorage.instance
          .ref('groupPhotos/')
          .child("$groupID.png");

      await groupPhotoRef.putData(file);
      return groupPhotoRef.getDownloadURL();
      // ignore: nullable_type_in_catch_clause
    } on FirebaseException catch (e) {
      print(e);
      rethrow;
    }
  }

  void addMemberToGroupRTDB(Member newMember, String groupID) {
    // This function should add the newMember's ID to the list of members in
    // the group with ID groupID. Maybe it should also check to see if the member is in the members table in the DB.

    //
    // if(newMember not in "members/" table) {
    //   add NewMember to "members/" table;
    // }
    //

    // To add a member to a group's member list in the DB, pull a reference to the member_lists table and the specified groupID. Then call update with the new list.

    DatabaseReference memberListReference =
        db!.child(MEMBER_LIST_PATH).child('/$groupID');
    memberListReference.update({newMember.memberID: newMember.memberID});

    updateGroupSize(groupID);
    notifyListeners();
  }

  void removeMemberFromGroupRTDB(Member member, String groupID) {
    DatabaseReference memberListReference =
        db!.child(MEMBER_LIST_PATH + '/$groupID');
    memberListReference.child(member.memberID).remove();
    updateGroupSize(groupID);
    notifyListeners();
  }

  void updateGroupSize(String groupID) {
    DatabaseReference memberCountReference =
        db!.child(FRIEND_GROUP_PATH).child(groupID).child("groupSize");
    memberCountReference.set(getMemberList(groupID).length);
  }

  void toggleFavoriteGroup(String groupID) {
    DatabaseReference favoriteGroupReference =
        db!.child(FRIEND_GROUP_PATH).child(groupID).child("isFavoriteGroup");
    favoriteGroupReference
        .get()
        .then((value) => favoriteGroupReference.set(!value.value));
  }
}
