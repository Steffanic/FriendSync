import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';
import 'package:friend_sync/providers.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatefulWidget {
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.blue])),
          child: Consumer<FriendGroupProvider>(
            builder: (context, friendGroupProvider, child) => Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_left),
                      ),
                      Expanded(
                        child: Container(
                          height: 0,
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AddFriendDialog();
                                });
                          },
                          child: Icon(Icons.add))
                    ],
                  ),
                ),
                Flexible(
                    flex: 3,
                    child: Text(
                      "Friends",
                      style: TextStyle(fontSize: 42),
                    )),
                Expanded(
                  flex: 9,
                  child: ListView(
                    children: friendGroupProvider.members
                        .where((mem) => friendGroupProvider
                            .getMemberByID(
                                friendGroupProvider.getCurrentMemberID())
                            .friendList
                            .contains(mem.memberID))
                        .map((mem) => FriendCard(userID: mem.memberID))
                        .toList(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FriendCard extends StatelessWidget {
  String userID;

  FriendCard({required this.userID});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.purple[100],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                      flex: 3,
                      child: Consumer<FriendGroupProvider>(
                        builder: (context, friendGroupProvider, child) =>
                            Container(
                          margin: EdgeInsets.all(IMAGE_MARGIN),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            image: DecorationImage(
                                image: NetworkImage(friendGroupProvider
                                    .getMemberByID(userID)
                                    .memberProfilePicture)),
                            shape: BoxShape.circle,
                          ), //Profile picture
                        ),
                      )),
                  Expanded(
                    flex: 6,
                    child: Container(
                        margin: EdgeInsets.all(6),
                        child: Consumer<FriendGroupProvider>(
                          builder: (context, friendGroupProvder, child) =>
                              Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                  flex: 4,
                                  child: FittedBox(
                                      child: Text(
                                    friendGroupProvder
                                        .getMemberByID(userID)
                                        .memberName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: "Noto Sans"),
                                  ))),
                              Flexible(
                                  flex: 2,
                                  child: Text(
                                      friendGroupProvder
                                          .getMemberByID(userID)
                                          .memberStatus,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontFamily: "Noto Sans"))),
                            ],
                          ),
                        )),
                  ),
                ]),
          )),
    );
  }
}

class AddFriendDialog extends StatefulWidget {
  @override
  State<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  TextEditingController? friendSearch = TextEditingController();
  List<Member>? filteredMembers;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.purple[100],
        ),
        child: Consumer<FriendGroupProvider>(
          builder: (context, friendGroupProvider, child) => Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.search,
                  color: Colors.blue,
                ),
                title: TextField(
                  controller: friendSearch,
                  onChanged: (value) =>
                      _updateQuery(value, friendGroupProvider),
                  decoration: InputDecoration(
                    hintText: "Find Friends...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                height: 350,
                child: ListView.builder(
                    itemCount:
                        filteredMembers != null ? filteredMembers!.length : 0,
                    itemBuilder: (BuildContext context, int index) {
                      if (filteredMembers != null) {
                        return FriendCard(
                            userID: filteredMembers![index].memberID);
                      }
                      return Text("Test");
                    }),
              )
            ],
          ),
        ),
      ),
    ));
  }

  _updateQuery(String value, FriendGroupProvider friendGroupProvider) {
    setState(() {
      filteredMembers = friendGroupProvider.members
          .where((mem) =>
              mem.memberName.toLowerCase().contains(RegExp("[$value]")))
          .toList();
    });
  }
}
