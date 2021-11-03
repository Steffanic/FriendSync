import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';
import 'package:friend_sync/forms.dart';
import 'package:friend_sync/group.dart';
import 'package:friend_sync/login.dart';
import 'package:friend_sync/providers.dart';
import 'package:friend_sync/settings.dart';
import 'package:friend_sync/utility.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';

const double IMAGE_MARGIN = 6.0;
final FirebaseAuth _auth = FirebaseAuth.instance;

class HomePage extends StatefulWidget {
  List<GroupPageState> friendGroups;

  final User? user;

  HomePage({Key? key, this.friendGroups = const [], this.user})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isUserLoggedIn = false;
  final database = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    isUserLoggedIn = checkForLoggedInUser(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isUserLoggedIn) {
      return LogInPage();
    }
    // get friend groups from db
    final friendGroupsRef = database
        .child('friendGroups/0/groupName')
        .get()
        .then((value) => print(value.value));

    return ChangeNotifierProvider<FriendGroupProvider>(
        create: (context) =>
            FriendGroupProvider(friendGroups: widget.friendGroups),
        child: Consumer<FriendGroupProvider>(
            builder: (context, friendGroupProvider, child) => MaterialApp(
                  title: "Friend Sync",
                  initialRoute: '/',
                  routes: {
                    '/': (context) => MainPage(),
                    '/group': (context) => GroupPage(),
                    '/settings': (context) => SettingsPage(),
                    '/add_new_group': (context) => AddNewGroupPage()
                  },
                )));
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isUserLoggedIn = false;

  // ignore: unused_element
  _MainPageState();

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                child: CurrentUserStatusCard(),
                flex: 2,
              ),
              Flexible(
                child: Consumer<FriendGroupProvider>(
                  builder: (context, friendGroupProvider, child) => Container(
                    padding: EdgeInsets.all(24),
                    margin: EdgeInsets.only(left: 32, right: 32),
                    child: GridView.count(
                      crossAxisSpacing: 25,
                      crossAxisCount: 2,
                      children: [
                        ...friendGroupProvider.friendGroups
                            .map((groupState) =>
                                FriendGroupCard(groupState: groupState))
                            .toList(),
                        AddNewGroupCard()
                      ],
                    ),
                  ),
                ),
                flex: 4,
              )
            ],
          ),
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

class CurrentUserStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
      // Begin row
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
              flex: 3,
              child: Container(
                margin: EdgeInsets.all(IMAGE_MARGIN),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  image: const DecorationImage(
                      image: NetworkImage("https://i.imgur.com/cWgJmWt.jpg")),
                  shape: BoxShape.circle,
                ), //Profile picture
              )),
          Expanded(
            flex: 6,
            child: Container(
                margin: EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    Flexible(
                        flex: 4,
                        child: FittedBox(
                            child: Text(
                          "Patrick Steffanic",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: "Noto Sans"),
                        ))),
                    Flexible(
                        flex: 2,
                        child: Text("Status: Down to clown!",
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
                  children: const [
                    Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    Icon(
                      Icons.person,
                      color: Colors.green,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class FriendGroupCard extends StatelessWidget {
  final GroupPageState groupState;

  FriendGroupCard({required this.groupState});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        // Design decision to go with square tiles
        aspectRatio: 1,
        child: InkWell(
          // Tapping on a group page tile will bring you to a new group page
          // it passes the details about the group that was selected as arguments.
          onTap: () {
            Navigator.pushNamed(context, '/group',
                    arguments: groupState.groupID)
                .then((value) => checkForLoggedInUser(context));
          },
          child: Container(
            height: 150,
            margin: EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.purple[100],
            ),
            // Begin row
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                    flex: 5,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                              // This is the group's profile picture
                              flex: 5,
                              child: Container(
                                margin: EdgeInsets.all(IMAGE_MARGIN),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          groupState.groupImageURL)),
                                  shape: BoxShape.circle,
                                ), //Profile picture
                              )),
                          Flexible(
                              // These are the favorite icon
                              // and number of member icon
                              flex: 2,
                              child: Container(
                                  margin:
                                      const EdgeInsets.only(right: 6, top: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      (groupState.favoriteGroup
                                          ? Icon(Icons.star,
                                              color: Colors.yellow)
                                          : Icon(Icons.star_border,
                                              color: Colors.white)),
                                      SizedBox(
                                        width: 35,
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                      "${groupState.groupSize}")),
                                              Icon(
                                                Icons.person,
                                                color: Colors.green,
                                              ),
                                            ]),
                                      ),
                                    ],
                                  )))
                        ])),
                Expanded(
                  flex: 2,
                  child: Container(
                      margin: EdgeInsets.all(8),
                      child: FittedBox(
                          child: Text(
                        groupState.groupName,
                        style: TextStyle(fontFamily: "Noto Sans"),
                      ))),
                ),
              ],
            ),
          ),
        ));
  }
}

class AddNewGroupCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1,
        child: InkWell(
            // Tapping on a group page tile will bring you to a new group page
            // it passes the details about the group that was selected as arguments.
            onTap: () {
              Navigator.pushNamed(
                context,
                '/add_new_group',
              ).then((value) => checkForLoggedInUser(context));
            },
            child: Container(
                margin: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.purple[100],
                ),
                // Begin row
                child: const FittedBox(
                    fit: BoxFit.fill,
                    child: Icon(
                      Icons.add_circle,
                    )))));
  }
}

class BlankCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.purple[100],
          ),
          // Begin row
        ));
  }
}
