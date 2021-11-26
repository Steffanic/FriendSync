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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friend_sync/forms.dart';
import 'package:friend_sync/group_creation.dart';
import 'package:friend_sync/providers.dart';
import 'package:friend_sync/utility.dart';
import 'package:provider/provider.dart';

const double IMAGE_MARGIN = 6.0;
const String GENERIC_MEMBER_URL =
      "https://im4.ezgif.com/tmp/ezgif-4-cb158ea80934.gif";

class GroupPage extends StatefulWidget {
  final FirebaseAuth? auth;
  const GroupPage({
    Key? key,
    this.auth,
  }) : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  String? groupID;

  _GroupPageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkForLoggedInUser(context, widget.auth!);

    groupID ??= ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
        body: SafeArea(
      child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.blue])),
          child: Column(mainAxisSize: MainAxisSize.max, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () => _onItemTapped(0),
                    child: Icon(Icons.arrow_left_rounded)),
                InkWell(
                    onTap: () => _onItemTapped(1), child: Icon(Icons.settings))
              ],
            ),
            Flexible(
              child: Consumer<FriendGroupProvider>(
                  builder: (context, friendGroupProvider, child) {
                return GroupStatusCard(
                    friendGroupProvider.getGroupByID(groupID!));
              }),
              flex: 2,
            ),
            Flexible(child: Consumer<FriendGroupProvider>(
                builder: (context, friendGroupProvider, child) {
              var memberChips;
              try {
                memberChips = friendGroupProvider
                    .getMemberList(groupID!)
                    .entries
                    .map((memID) => InkWell(
                          onTap: () => _removeMember(
                              friendGroupProvider.getMemberByID(memID.value),
                              friendGroupProvider),
                          child: MemberStatusChip(
                              member: friendGroupProvider
                                  .getMemberByID(memID.value)),
                        ))
                    .toList();
              } catch (e) {
                print("$e");
                memberChips = [];
              } finally {}
              return Wrap(
                direction: Axis.horizontal,
                spacing: 12.0,
                runSpacing: 12.0,
                children: [...memberChips, AddMemberCard(_addMember, groupID!)],
              );
            }))
          ])),
    ));
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pop(context);
    }
    if (index == 1) {
      Navigator.pushNamed(context, "/settings")
          .then((value) => checkForLoggedInUser(context, widget.auth!));
    }
  }

  void _addMember(Member newMember, FriendGroupProvider friendGroupProvider) {
    if (friendGroupProvider.isInGroup(newMember, groupID!)) {
      _showToast(context, "They are already in your group!");
    } else {
      friendGroupProvider.addMemberToGroupRTDB(newMember, groupID!);
      friendGroupProvider.addGroupToMemberRTDB(groupID!, newMember.memberID);
      _showToast(
          context,
          newMember.memberName +
              " has been added to " +
              friendGroupProvider.getGroupByID(groupID!).groupName);
    }
  }

  void _removeMember(Member member, FriendGroupProvider friendGroupProvider) {
    if (!friendGroupProvider.isInGroup(member, groupID!)) {
      _showToast(context,
          "I don't know how you did it, but you are trying to remove a member who doesn't belong to this group 🤷‍♂️");
    }
    if (widget.auth!.currentUser!.uid == member.memberID) {
      _showToast(context, "You can't remove yourself, silly!");
    } else {
      friendGroupProvider.removeMemberFromGroupRTDB(member, groupID!);
      _showToast(
          context,
          member.memberName +
              " has been removed from " +
              friendGroupProvider.getGroupByID(groupID!).groupName);
    }
  }

  void _showToast(BuildContext context, String msg) {
    showToast(context, msg);
  }
}

class GroupStatusCard extends StatelessWidget {
  final GroupMetaData groupMetaData;

  const GroupStatusCard(this.groupMetaData, {Key? key}) : super(key: key);

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
                      image: NetworkImage(groupMetaData.groupImageURL),
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
                          groupMetaData.groupName,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: "Noto Sans"),
                        ))),
                    Flexible(
                        flex: 2,
                        child: Text(groupMetaData.groupTagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: "Noto Sans"))),
                  ],
                )),
          ),
          Flexible(
              flex: 1,
              child: Container(
                margin: EdgeInsets.all(6),
                child: Consumer<FriendGroupProvider>(
                  builder: (context, friendGroupProvider, child) => Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                          onTap: () {
                            friendGroupProvider
                                .toggleFavoriteGroup(groupMetaData.groupID);
                          },
                          child: (groupMetaData.isFavoriteGroup
                              ? Icon(Icons.star, color: Colors.yellow)
                              : Icon(Icons.star_border, color: Colors.white))),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Expanded(
                            child: Consumer<FriendGroupProvider>(
                                builder: (context, friendGroupProvider,
                                        child) =>
                                    Text(
                                        "${friendGroupProvider.friendGroups!.where((grp) => grp.groupID == groupMetaData.groupID).toList()[0].groupSize}"))),
                        Icon(
                          Icons.person,
                          color: Colors.green,
                        ),
                      ]),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class MemberStatusChip extends StatelessWidget {
  final Member member;

  const MemberStatusChip({
    this.member = const Member(),
  });

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
  final String groupID;
  // ignore: use_key_in_widget_constructors
  const AddMemberCard(this.addMemberFunction, this.groupID);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) =>
                Dialog(child: AddMemberDialog(addMemberFunction, groupID))),
        child: Chip(avatar: Icon(Icons.add), label: Text("Add a member!")));
  }
}

class AddMemberDialog extends StatelessWidget {
  final Function addMemberFunction; 
  final String groupID;
  // ignore: use_key_in_widget_constructors
  const AddMemberDialog(this.addMemberFunction, this.groupID);

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendGroupProvider>(
        builder: (context, friendGroupProvider, child) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Add existing friends:"),
                  Wrap(
                    children: [
                      ...friendGroupProvider
                          .getMemberByID(
                              friendGroupProvider.getCurrentMemberID())
                          .friendList
                          .map((frndID) =>
                              friendGroupProvider.getMemberByID(frndID))
                          .toList()
                          .map((mem) {
                        return InkWell(
                          onTap: () =>
                              addMemberFunction(mem, friendGroupProvider),
                          child: MemberStatusChip(member: mem),
                        );
                      }).toList()
                    ],
                  ),
                  const Text("Invite new friends"),
                ]));
  }
}

class AddNewGroupPage extends StatefulWidget {
  final FirebaseAuth? auth;
  const AddNewGroupPage({Key? key, this.auth}) : super(key: key);

  @override
  _AddNewGroupState createState() => _AddNewGroupState();
}

class _AddNewGroupState extends State<AddNewGroupPage> {

  _AddNewGroupState();

  @override
  Widget build(BuildContext context) {
    checkForLoggedInUser(context, widget.auth!);
    return Scaffold(
        body: SafeArea(child: GroupCreationPage(auth: widget.auth!)));
  }

}
