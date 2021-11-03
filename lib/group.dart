import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friend_sync/providers.dart';
import 'package:friend_sync/utility.dart';
import 'package:provider/provider.dart';

const double IMAGE_MARGIN = 6.0;

class GroupPage extends StatefulWidget {
  const GroupPage({
    Key? key,
  }) : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late final int groupID;
  bool groupIDInit = false;
  _GroupPageState();

  @override
  Widget build(BuildContext context) {
    checkForLoggedInUser(context);
    if (!groupIDInit) {
      groupID = ModalRoute.of(context)!.settings.arguments as int;
      groupIDInit = true;
    }
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            onTap: _onItemTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: "Settings")
            ]),
        body: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.blue])),
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              Flexible(
                //
                //TODO: Pass group details as arguments to keep the state managed in a consistent way.
                //
                child: Consumer<FriendGroupProvider>(
                    builder: (context, friendGroupProvider, child) =>
                        GroupStatusCard(
                            friendGroupProvider.getGroupByID(groupID))),
                flex: 2,
              ),
              Flexible(
                  child: Consumer<FriendGroupProvider>(
                builder: (context, friendGroupProvider, child) => Wrap(
                  direction: Axis.horizontal,
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: [
                    ...friendGroupProvider
                        .getGroupByID(groupID)
                        .groupMembers
                        .map((mem) => MemberStatusChip(member: mem))
                        .toList(),
                    AddMemberCard(_addMember)
                  ],
                ),
              ))
            ])));
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
    if (index == 1) {
      Navigator.pushNamed(context, "/settings")
          .then((value) => checkForLoggedInUser(context));
    }
  }

  void _addMember(Member newMember, FriendGroupProvider friendGroupProvider) {
    if (friendGroupProvider.isInGroup(newMember, groupID)) {
      _showToast(context, "They are already in your group!");
    } else {
      friendGroupProvider.addMember(groupID, newMember);
      _showToast(
          context,
          newMember.memberName +
              " has been added to " +
              friendGroupProvider.getGroupByID(groupID).groupName);
    }
  }

  void _showToast(BuildContext context, String msg) {
    showToast(context, msg);
  }
}

class GroupStatusCard extends StatelessWidget {
  final GroupPageState groupState;

  const GroupStatusCard(this.groupState, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //Container configuration begin
      height: 150,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.purple[100],
      ),
      // Container configuration end
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          //Group Picture
          Flexible(
              flex: 3,
              child: Container(
                margin: EdgeInsets.all(IMAGE_MARGIN),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  image: DecorationImage(
                      image: NetworkImage(groupState.groupImageURL),
                      fit: BoxFit.cover),
                  shape: BoxShape.circle,
                ), //Profile picture
              )),
          // Group name
          Expanded(
            flex: 6,
            child: Container(
                margin: EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                        flex: 4,
                        child: FittedBox(
                            child: Text(
                          groupState.groupName,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: "Noto Sans"),
                        ))),
                    Flexible(
                        flex: 2,
                        child: Text(groupState.groupTagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: "Noto Sans"))),
                  ],
                )),
          ),
          Flexible(
              flex: 1,
              child: Container(
                margin: EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    (groupState.favoriteGroup
                        ? Icon(Icons.star, color: Colors.yellow)
                        : Icon(Icons.star_border, color: Colors.white)),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Expanded(
                          child: Consumer<FriendGroupProvider>(
                              builder: (context, friendGroupProvider, child) =>
                                  Text(
                                      "${friendGroupProvider.friendGroups.where((grp) => grp.groupID == groupState.groupID).toList()[0].groupSize}"))),
                      Icon(
                        Icons.person,
                        color: Colors.green,
                      ),
                    ]),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class MemberStatusChip extends StatelessWidget {
  final Member member;

  const MemberStatusChip({this.member = const Member()});

  @override
  Widget build(BuildContext context) {
    return Chip(
        avatar: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(member.memberProfilePicture)),
            shape: BoxShape.circle,
          ), //Profile picture
        ),
        label: Text(member.memberName));
  }
}

class AddMemberCard extends StatelessWidget {
  final Function addMemberFunction;
  // ignore: use_key_in_widget_constructors
  const AddMemberCard(this.addMemberFunction);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) =>
                Dialog(child: AddMemberDialog(addMemberFunction))),
        child: Chip(avatar: Icon(Icons.add), label: Text("Add a member!")));
  }
}

class AddMemberDialog extends StatelessWidget {
  final Function addMemberFunction;
  final String genericMemberURL =
      "https://im4.ezgif.com/tmp/ezgif-4-cb158ea80934.gif";
  // ignore: use_key_in_widget_constructors
  const AddMemberDialog(this.addMemberFunction);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Text("Add existing friends:"),
          Consumer<FriendGroupProvider>(
            builder: (context, friendGroupProvider, child) => Wrap(
              children: [
                //Replace with access to some database of users
                InkWell(
                    onTap: () => addMemberFunction(
                        Member(
                            memberID: 1,
                            memberName: "Friend Joe",
                            memberProfilePicture: genericMemberURL),
                        friendGroupProvider),
                    child: MemberStatusChip(
                      member: Member(
                          memberID: 1,
                          memberName: "Friend Joe",
                          memberProfilePicture: genericMemberURL),
                    )),
                InkWell(
                    onTap: () => addMemberFunction(
                        Member(
                            memberID: 2,
                            memberName: "Friend Jane",
                            memberProfilePicture: genericMemberURL),
                        friendGroupProvider),
                    child: MemberStatusChip(
                        member: Member(
                            memberID: 2,
                            memberName: "Friend Jane",
                            memberProfilePicture: genericMemberURL))),
                InkWell(
                    onTap: () => addMemberFunction(
                        Member(
                            memberID: 3,
                            memberName: "Friend Malik",
                            memberProfilePicture: genericMemberURL),
                        friendGroupProvider),
                    child: MemberStatusChip(
                        member: Member(
                            memberID: 3,
                            memberName: "Friend Malik",
                            memberProfilePicture: genericMemberURL))),
                InkWell(
                    onTap: () => addMemberFunction(
                        Member(
                            memberID: 4,
                            memberName: "Friend Sruthi",
                            memberProfilePicture: genericMemberURL),
                        friendGroupProvider),
                    child: MemberStatusChip(
                        member: Member(
                            memberID: 4,
                            memberName: "Friend Sruthi",
                            memberProfilePicture: genericMemberURL)))
              ],
            ),
          ),
          Text("Invite new friends"),
        ]));
  }
}

class AddNewGroupPage extends StatefulWidget {
  const AddNewGroupPage({Key? key}) : super(key: key);

  @override
  _AddNewGroupState createState() => _AddNewGroupState();
}

class _AddNewGroupState extends State<AddNewGroupPage> {
  var groupName;

  @override
  Widget build(BuildContext context) {
    checkForLoggedInUser(context);
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            onTap: _onItemTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: "Settings")
            ]),
        body: Container(
          width: 50,
        ));
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
    if (index == 1) {
      Navigator.pushNamed(context, "/settings")
          .then((value) => checkForLoggedInUser(context));
    }
  }
}
