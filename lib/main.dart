import 'package:flutter/material.dart';
import 'package:friend_sync/arguments.dart';
import 'package:friend_sync/providers.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'group.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var friendGroups = <GroupPageState>[
      GroupPageState(
        [const Member()],
        "Main Squad 💖",
        "The best people in the world.",
        "https://img.huffingtonpost.com/asset/604fc2f2260000cc17d854ff.jpeg",
        1,
        100,
        true,
      ),
      GroupPageState(
        [Member()],
        "Mi Familia",
        "Live, laugh, love",
        "https://media.istockphoto.com/photos/latin-senior-man-serving-the-food-to-his-family-at-dinner-table-picture-id1167975422?k=20&m=1167975422&s=612x612&w=0&h=DvF_AfZwvB3WMTPclXEXf7ysuI4ASowMHcssIDSFKrY=",
        1,
        101,
        false,
      )
    ];

    return ChangeNotifierProvider<FriendGroupProvider>(
      create: (context) => FriendGroupProvider(friendGroups: friendGroups),
      child: Consumer<FriendGroupProvider>(
        builder: (context, friendGroupProvider, child) => MaterialApp(
          title: "Friend Sync",
          initialRoute: '/',
          routes: {
            '/': (context) => MainPage(),
            '/group': (context) => GroupPage(),
            '/add_new_group': (context) => AddNewGroupPage()
          },
        ),
      ),
    );
  }
}
