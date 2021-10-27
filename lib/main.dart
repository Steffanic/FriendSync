import 'package:flutter/material.dart';
import 'home.dart';
import 'group.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var friendGroups = <Widget>[
      FriendGroupCard(
        groupName: "Main Squad 💖",
        groupTagline: "The best people in the world.",
        groupImageURL:
            "https://img.huffingtonpost.com/asset/604fc2f2260000cc17d854ff.jpeg",
        groupSize: 4,
        favoriteGroup: true,
      ),
      FriendGroupCard(
        groupName: "Mi Familia",
        groupTagline: "Live, laugh, love",
        groupSize: 2,
        groupImageURL:
            "https://media.istockphoto.com/photos/latin-senior-man-serving-the-food-to-his-family-at-dinner-table-picture-id1167975422?k=20&m=1167975422&s=612x612&w=0&h=DvF_AfZwvB3WMTPclXEXf7ysuI4ASowMHcssIDSFKrY=",
      ),
      AddNewGroupCard()
    ];

    return MaterialApp(
      title: "Friend Sync",
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(
              friendGroups: friendGroups,
            ),
        '/group': (context) => GroupPage(),
        '/add_new_group': (context) => AddNewGroupPage()
      },
    );
  }
}
