import 'package:friend_sync/arguments.dart';
import 'package:friend_sync/home.dart';
import 'package:friend_sync/providers.dart';
import 'package:test/test.dart';

void main() {
  group("Requesting friend group from provider.", () {
    test(
        "Request friend group by ID using an empty friendGroups and expect to get a GroupNotFoundException.",
        () {
      //Arrange
      final fgp = FriendGroupProvider();
      String groupID = "0";

      //Act
      try {
        GroupMetaData gMD = fgp.getGroupByID(groupID);
      } on GroupNotFoundException catch (e) {
        print("Group ${e.groupID} could not be found.");

        //Assert
        expect(e.groupID, groupID);
      }
    });

    test(
        "Request friend group by ID using an ID not in friendGroups and expect to get a GroupNotFoundException.",
        () {
      //Arrange
      final fgp = FriendGroupProvider();
      var prototypeGroup =
          GroupMetaData("KnownID", "fakeimage.png", "group", "", 1, true);
      fgp.friendGroups = [prototypeGroup];
      String groupID = "0";

      //Act
      try {
        GroupMetaData gMD = fgp.getGroupByID(groupID);
      } on GroupNotFoundException catch (e) {
        print("Group ${e.groupID} could not be found.");

        //Assert
        expect(e.groupID, groupID);
      }
    });

    test(
        "Request friend group by ID using an ID known to be in groupList and expecting that group's metadata back.",
        () {
      //Arrange
      final fgp = FriendGroupProvider();
      var prototypeGroup =
          GroupMetaData("KnownID", "fakeimage.png", "group", "", 1, true);
      fgp.friendGroups = [prototypeGroup];
      String groupID = "KnownID";
      GroupMetaData? gMD;

      //Act
      try {
        gMD = fgp.getGroupByID(groupID);
      } on GroupNotFoundException catch (e) {
        print("Group ${e.groupID} could not be found.");
      }

      //Assert
      expect(gMD, prototypeGroup);
    });
  });

  group("Requesting member list from provider.", () {
    test(
        "Request a memberlist from empty memberLists and expect a MemberListEmptyException.",
        () {
      //Arrange
      final fgp = FriendGroupProvider();

      String groupID = "KnownID";

      List<dynamic>? memList;

      //Act
      try {
        memList = fgp.getMemberList(groupID);
      } catch (e) {
        print("Member list is empty.");

        //Assert
        expect(e, MemberListEmptyException);
      }

      expect(memList, null);
    });

    test(
        "Request a memberlist not in memberLists and expect MemberListNotFoundException.",
        () {
      //Arrange
      final fgp = FriendGroupProvider();
      var prototypeMemberList = Map<String, List<String>>.from({
        "groupID": const ["KnownID"]
      });
      fgp.memberLists = prototypeMemberList;
      String groupID = "WrongID";
      List<dynamic>? memList;

      //Act
      try {
        memList = fgp.getMemberList(groupID);
      } on MemberListNotFoundException catch (e) {
        print("Member list for group ${e.groupID} could not be found.");

        //Assert
        expect(e.groupID, groupID);
      }

      expect(memList, null);
    });

    test(
        "Request a memberlist that is known to be in memberList and expect that memberlist.",
        () {
      //Arrange
      final fgp = FriendGroupProvider();
      var prototypeMemberList = Map<String, List<String>>.from({
        "groupID": const ["KnownID"]
      });
      fgp.memberLists = prototypeMemberList;
      String groupID = "groupID";
      List<dynamic>? memList;

      //Act
      try {
        memList = fgp.getMemberList(groupID);
      } on MemberListNotFoundException catch (e) {
        print("Member list for group ${e.groupID} could not be found.");
      }

      //Assert
      expect(memList, prototypeMemberList['groupID']);
    });
  });
}
