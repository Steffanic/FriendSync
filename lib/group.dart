import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';
import 'package:fluttertoast/fluttertoast.dart';

const double IMAGE_MARGIN = 6.0;

class Member {
  final String memberName;
  final String memberProfilePicture;

  const Member(
      {this.memberName = "Patrick Steffanic",
      this.memberProfilePicture = "https://i.imgur.com/cWgJmWt.jpg"});
}

class GroupPageState {
  List<Member> groupMembers;
  final String groupName;
  final String groupTagline;
  final String groupImageURL;
  final int groupSize;
  final bool favoriteGroup;

  GroupPageState(this.groupMembers, this.groupName, this.groupTagline,
      this.groupImageURL, this.groupSize, this.favoriteGroup);
}

class GroupPage extends StatefulWidget {
  const GroupPage({Key? key}) : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  var groupState;

  _GroupPageState(
      {this.groupState});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as GroupPageArguments;
    groupState = args.groupName;
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
                child: GroupStatusCard(),
                flex: 2,
              ),
              Flexible(
                  child: Wrap(
                direction: Axis.horizontal,
                spacing: 12.0,
                runSpacing: 12.0,
                children: [
                  ...groupMembers
                      .map((mem) => MemberStatusChip(member: mem))
                      .toList(),
                  AddMemberCard(_addMember)
                ],
              ))
            ])));
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
  }

  void _addMember(newMember) {
    if (groupMembers
        .where((mem) => mem.memberName == newMember.memberName)
        .isNotEmpty) {
      _showToast(context, "They are already in your group!");
    } else {
      setState(() {
        groupMembers = [...groupMembers, newMember];
      });
      _showToast(
          context, newMember.memberName + " has been added to " + groupName);
    }
  }

  void _showToast(BuildContext context, String msg) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }
}

class GroupStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as GroupPageArguments;

    return Container(
      //Container configuration begin
      height: 150,
      margin: EdgeInsets.all(12),
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
                      image: NetworkImage(args.groupImageURL),
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
                          args.groupName,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: "Noto Sans"),
                        ))),
                    Flexible(
                        flex: 2,
                        child: Text(args.groupTagline,
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
                    (args.favoriteGroup
                        ? Icon(Icons.star, color: Colors.yellow)
                        : Icon(Icons.star_border, color: Colors.white)),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Expanded(child: Text("${args.groupSize}")),
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

  MemberStatusChip({this.member = const Member()});

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
  Function addMemberFunction;
  String genericMemberURL =
      "https://www.postplanner.com/hs-fs/hub/513577/file-2886416984-png/blog-files/facebook-profile-pic-vs-cover-photo-sq.png?width=250&height=250&name=facebook-profile-pic-vs-cover-photo-sq.png";
  AddMemberDialog(this.addMemberFunction);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Text("Add existing friends:"),
          Wrap(
            children: [
              //Replace with access to some database of users
              InkWell(
                  onTap: () => addMemberFunction(Member(
                      memberName: "Friend Joe",
                      memberProfilePicture: genericMemberURL)),
                  child: MemberStatusChip(
                      member: Member(
                          memberName: "Friend Joe",
                          memberProfilePicture: genericMemberURL))),
              InkWell(
                  onTap: () => addMemberFunction(Member(
                      memberName: "Friend Jane",
                      memberProfilePicture: genericMemberURL)),
                  child: MemberStatusChip(
                      member: Member(
                          memberName: "Friend Jane",
                          memberProfilePicture: genericMemberURL))),
              InkWell(
                  onTap: () => addMemberFunction(Member(
                      memberName: "Friend Malik",
                      memberProfilePicture: genericMemberURL)),
                  child: MemberStatusChip(
                      member: Member(
                          memberName: "Friend Malik",
                          memberProfilePicture: genericMemberURL))),
              InkWell(
                  onTap: () => addMemberFunction(Member(
                      memberName: "Friend Sruthi",
                      memberProfilePicture: genericMemberURL)),
                  child: MemberStatusChip(
                      member: Member(
                          memberName: "Friend Sruthi",
                          memberProfilePicture: genericMemberURL)))
            ],
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
}
