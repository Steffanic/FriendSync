import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/login.dart';

bool checkForLoggedInUser(BuildContext context, FirebaseAuth auth) {
  if (auth.currentUser == null) {
    return false;
  }
  return true;
}

void showToast(BuildContext context, String msg) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(msg),
    ),
  );
}
