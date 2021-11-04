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

class GroupMetaData {
  String groupImageURL;
  String groupName;
  String groupTagline;
  int groupID;
  int groupSize;
  bool isFavoriteGroup;

  GroupMetaData(this.groupID, this.groupImageURL, this.groupName,
      this.groupTagline, this.groupSize, this.isFavoriteGroup);

  factory GroupMetaData.fromRTDB(int grpID, Map<String, dynamic> grpMD) {
    return GroupMetaData(grpID, grpMD["groupImageURL"], grpMD["groupName"],
        grpMD["groupTagline"], grpMD["groupSize"], grpMD["isFavoriteGroup"]);
  }
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
