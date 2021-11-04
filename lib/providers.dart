import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';

class FriendGroupProvider extends ChangeNotifier {
  List<GroupMetaData> friendGroups;
  final _db = FirebaseDatabase.instance.reference();

  static const FRIEND_GROUP_PATH = 'friendGroups';

  late StreamSubscription<Event> _friendGroupStream;

  FriendGroupProvider({this.friendGroups = const []}) {
    _listenToFriendGroups();
  }

  GroupMetaData getGroupByID(int groupID) {
    return friendGroups.where((grp) => grp.groupID == groupID).toList()[0];
  }

  void _listenToFriendGroups() {
    _friendGroupStream = _db.child(FRIEND_GROUP_PATH).onValue.listen((event) {
      print(friendGroups);
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
