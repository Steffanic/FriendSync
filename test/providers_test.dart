import 'package:friend_sync/arguments.dart';
import 'package:friend_sync/home.dart';
import 'package:friend_sync/providers.dart';
import 'package:test/test.dart';

void main() {
  group("Requesting friend group from provider.", () {
    test(
        "Request friend group by ID using ID='0' and expect to get a GroupNotFoundException.",
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

    test("Request friend group by ID using an ID known to be in groupList and expecting that group's metadata back.", () {
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
}
