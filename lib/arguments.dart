import 'package:flutter/material.dart';

class Member {
  final String memberName;
  final String memberProfilePicture;
  final int memberID; //This ID only unique within a single group.

  const Member(
      {this.memberID = 0,
      this.memberName = "Patrick Steffanic",
      this.memberProfilePicture = "https://i.imgur.com/cWgJmWt.jpg"});
}

class GroupPageState {
  List<Member> groupMembers;
  String groupName;
  String groupTagline;
  String groupImageURL;
  int groupSize;
  final int groupID;
  bool favoriteGroup;

  GroupPageState(this.groupMembers, this.groupName, this.groupTagline,
      this.groupImageURL, this.groupSize, this.groupID, this.favoriteGroup);
}

class GroupPageArguments {
  final GroupPageState groupState;

  GroupPageArguments(this.groupState);
}
