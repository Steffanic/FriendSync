import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';

class FriendGroupProvider extends ChangeNotifier {
  List<GroupPageState> friendGroups;

  FriendGroupProvider({required this.friendGroups});

  GroupPageState getGroupByID(int groupID) {
    return friendGroups.where((grp) => grp.groupID == groupID).toList()[0];
  }

  bool isInGroup(Member newMember, int groupID) {
    var group = friendGroups.where((grp) => grp.groupID == groupID).toList()[0];
    if (group.groupMembers
        .where((mem) => mem.memberID == newMember.memberID)
        .isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  void addGroup(GroupPageState groupState) {
    friendGroups = <GroupPageState>[...friendGroups, groupState];
    notifyListeners();
  }

  void addMember(int groupID, Member newMember) {
    GroupPageState group = getGroupByID(groupID);
    print(group);
    group.groupMembers = [...group.groupMembers, newMember];
    group.groupSize = group.groupMembers.length;
    notifyListeners();
  }
}
