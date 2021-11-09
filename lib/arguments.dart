import 'package:flutter/material.dart';

class Member {
  final String memberName;
  final String memberEmail;
  final String memberProfilePicture;
  final String memberID; //Firebase User ID.
  final List<String> friendList;

  const Member(
      {this.memberID = "0",
      this.memberName = "Patrick Steffanic",
      this.memberEmail = "email@gmail.com",
      this.memberProfilePicture = "https://i.imgur.com/cWgJmWt.jpg",
      this.friendList = const []});

  factory Member.fromRTDB(String memID, Map<String, dynamic> memMap) {
    return Member(
        memberID: memID,
        memberEmail: memMap['email'],
        memberName: memMap['name'],
        memberProfilePicture: memMap['profilePictureURL'],
        friendList: List<String>.from(memMap['friendList']));
  }
}

class GroupMetaData {
  String groupImageURL;
  String groupName;
  String groupTagline;
  String groupID;
  int groupSize;
  bool isFavoriteGroup;

  GroupMetaData(this.groupID, this.groupImageURL, this.groupName,
      this.groupTagline, this.groupSize, this.isFavoriteGroup);

  factory GroupMetaData.fromRTDB(String grpID, Map<String, dynamic> grpMD) {
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
