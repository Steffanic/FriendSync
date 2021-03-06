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

const double IMAGE_MARGIN = 6.0;
const String GENERIC_MEMBER_URL =
    "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";

class Member {
  final String memberName;
  final String memberEmail;
  final String memberProfilePicture;
  final String memberID; //Firebase User ID.
  final String memberStatus;
  final List<String> friendList;
  final List<String> groupList;

  const Member({
    this.memberID = "0",
    this.memberName = "Patrick Steffanic",
    this.memberEmail = "email@gmail.com",
    this.memberProfilePicture = "https://i.imgur.com/cWgJmWt.jpg",
    this.memberStatus = "Down to hang out this weekend!",
    this.friendList = const [],
    this.groupList = const [],
  });

  factory Member.fromRTDB(String memID, Map<String, dynamic> memMap) {
    List<String> memFriendList = [];
    for (String key in memMap['friendList'].keys) {
      memFriendList.add(memMap['friendList'][key]);
    }

    List<String> memGroupList = [];
    if (memMap.keys.contains('groupList')) {
      for (String key in memMap['groupList'].keys) {
        memGroupList.add(memMap['groupList'][key]);
      }
    }
    return Member(
        memberID: memID,
        memberEmail: memMap['email'],
        memberName: memMap['name'],
        memberProfilePicture: memMap['profilePictureURL'],
        memberStatus: memMap['status'],
        friendList: memFriendList,
        groupList: memGroupList);
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
