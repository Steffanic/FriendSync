import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';
import 'package:friend_sync/providers.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatelessWidget {
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
                      Expanded(
                        child: Container(
                          height: 0,
                        ),
                      ),
                      Icon(Icons.add)
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
      padding: const EdgeInsets.all(32.0),
      child: Container(
          height: 150,
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
