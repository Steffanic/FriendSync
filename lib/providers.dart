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

class FriendGroupProvider extends ChangeNotifier {
  final FirebaseAuth? auth;
  final DatabaseReference? db;
  final firebase_storage.FirebaseStorage? storage;

  List<GroupMetaData> friendGroups;
  late Map<String, List> memberLists = {};
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
    final grpOrEmpty =
        friendGroups.where((grp) => grp.groupID == groupID).toList();
    if (grpOrEmpty.isEmpty) {
      throw GroupNotFoundException(groupID);
    } else {
      return grpOrEmpty[0];
    }
  }

  List<Member> getMemberList(String groupID) {
    return memberLists.isEmpty
        ? []
        : memberLists[groupID]!.map((memID) => getMemberByID(memID)).toList();
  }

  Member getMemberByID(String memberID) {
    return members.where((mem) => mem.memberID == memberID).toList()[0];
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
      print("$e occurred!");
    }
  }

  void _listenToMemberLists() {
    try {
      _memberListStream = db!.child(MEMBER_LIST_PATH).onValue.listen((event) {
        var listOfMembers = event.snapshot.value;
        listOfMembers.map((String key, value) {
          memberLists.putIfAbsent(key, () => value);
          return MapEntry(key, value);
        });
        notifyListeners();
      });
    } catch (e) {
      print("Oh damn, son! $e went down.");
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
      print("$e has occurred!");
    }
  }

  @override
  void dispose() {
    _friendGroupStream.cancel();
    super.dispose();
  }

  bool isInGroup(Member newMember, String groupID) {
    List<Member> currentMemberList = getMemberList(groupID);
    if (currentMemberList
        .where((mem) => mem.memberID == newMember.memberID)
        .isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  void addGroupToRTDB(
      String groupImageURL,
      String groupName,
      String groupTagline,
      int groupSize,
      bool isFavoriteGroup,
      Uint8List file) {
    DatabaseReference friendGroupRef = db!.child(FRIEND_GROUP_PATH).push();
    newGroupID = friendGroupRef.key;
    uploadGroupPhoto(file, newGroupID);
    friendGroupRef.set({
      'groupName': groupName,
      'groupTagline': groupTagline,
      'groupImageURL': groupImageURL,
      'groupSize': groupSize,
      'isFavoriteGroup': isFavoriteGroup
    });

    DatabaseReference memberListRef =
        db!.child(MEMBER_LIST_PATH).child(newGroupID);
    memberListRef.update({'0': auth!.currentUser!.uid});

    notifyListeners();
  }

  Future<void> uploadGroupPhoto(Uint8List file, String groupID) async {
    try {
      var groupPhotoRef = firebase_storage.FirebaseStorage.instance
          .ref('groupPhotos/')
          .child("$groupID.png");

      await groupPhotoRef.putData(file);
      newGroupPhotoURL = await groupPhotoRef.getDownloadURL();
      notifyListeners();

      // ignore: nullable_type_in_catch_clause
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  void addMemberToGroupRTDB(String groupID, Member newMember) {
    // This function should add the newMember's ID to the list of members in
    // the group with ID groupID. Maybe it should also check to see if the member is in the members table in the DB.

    //
    // if(newMember not in "members/" table) {
    //   add NewMember to "members/" table;
    // }
    //

    // To add a member to a group's member list in the DB, pull a reference to the member_lists table and the specified groupID. Then call update with the new list.

    DatabaseReference memberListReference =
        db!.child(MEMBER_LIST_PATH + '/$groupID');
    int memberListLength;
    memberListReference
        .get()
        .then((snapshot) => memberListLength = snapshot.value.entries.length);
    memberListReference
        .update({'${getMemberList(groupID).length}': newMember.memberID});
    notifyListeners();
  }
}
