import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/home.dart';
import 'package:friend_sync/utility.dart';

class SettingsPage extends StatefulWidget {
  final FirebaseAuth? auth;
  SettingsPage({this.auth});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in before building.
    checkForLoggedInUser(context, widget.auth!);

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings")
          ]),
      body: Container(
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut().then((_) {
              return Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return HomePage();
              }));
            });
          },
          child: Text("Log Out."),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
    if (index == 1) {}
  }
}
