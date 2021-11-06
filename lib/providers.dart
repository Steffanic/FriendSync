import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';

class FriendGroupProvider extends ChangeNotifier {
  List<GroupMetaData> friendGroups;
  List<List> memberLists;
  List<Member> members;
  List<Member>
      currentGroupMemberList; //When in the Group Page screen, this stores the members.
  final _db = FirebaseDatabase.instance.reference();

  static const FRIEND_GROUP_PATH = 'friendGroups';
  static const MEMBER_LIST_PATH = 'member_lists';
  static const MEMBER_PATH = 'members';

  late StreamSubscription<Event> _friendGroupStream;

  late StreamSubscription<Event> _memberListStream;

  FriendGroupProvider(
      {this.friendGroups = const [],
      this.memberLists = const [],
      this.members = const [],
      this.currentGroupMemberList = const []}) {
    _listenToFriendGroups();
    _listenToMembers();
    _listenToMemberLists();
  }

  GroupMetaData getGroupByID(int groupID) {
    return friendGroups.where((grp) => grp.groupID == groupID).toList()[0];
  }

  List getMemberList(int groupID) {
    return memberLists.isEmpty
        ? []
        : memberLists[groupID].map((memID) => getMemberByID(memID)).toList();
  }

  Member getMemberByID(String memberID) {
    return members.where((mem) => mem.memberID == memberID).toList()[0];
  }

  void _listenToFriendGroups() {
    _friendGroupStream = _db.child(FRIEND_GROUP_PATH).onValue.listen((event) {
      friendGroups = event.snapshot.value
          .map((grp) {
            Map<String, dynamic> gMD = Map<String, dynamic>.from(grp);
            return GroupMetaData.fromRTDB(
                (event.snapshot.value).indexOf(grp), gMD);
          })
          .toList()
          .cast<GroupMetaData>();
      print(friendGroups);
      notifyListeners();
    });
  }

  void _listenToMemberLists() {
    _memberListStream = _db.child(MEMBER_LIST_PATH).onValue.listen((event) {
      memberLists = [...event.snapshot.value];
      notifyListeners();
    });
  }

  void _listenToMembers() {
    var memberFuture = _db.child(MEMBER_PATH).onValue.listen((event) {
      var memberMap = Map<String, dynamic>.from(event.snapshot.value);
      members = memberMap.entries
          .map((mem) => Member(
              memberID: mem.key,
              memberEmail: mem.value["email"],
              memberName: mem.value['name'],
              memberProfilePicture: mem.value['profilePictureURL']))
          .toList();
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _friendGroupStream.cancel();
    super.dispose();
  }

  /*bool isInGroup(Member newMember, int groupID) {
    var group = friendGroups.where((grp) => grp.groupID == groupID).toList()[0];
    if (group.groupMembers
        .where((mem) => mem.memberID == newMember.memberID)
        .isEmpty) {
      return false;
    } else {
      return true;
    }
  }*/

  void addGroup(GroupMetaData groupMetaData) {
    friendGroups = <GroupMetaData>[...friendGroups, groupMetaData];
    notifyListeners();
  }

  /*void addMember(int groupID, Member newMember) {
    GroupPageState group = getGroupByID(groupID);
    print(group);
    group.groupMembers = [...group.groupMembers, newMember];
    group.groupSize = group.groupMembers.length;
    notifyListeners();
  }*/
}
