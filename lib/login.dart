import 'package:flutter/material.dart';
import 'package:friend_sync/forms.dart';

class LogInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Expanded(
              flex: 2,
              child: Text(
                "Log in:",
                style: TextStyle(fontSize: 36),
              ),
            ),
            Flexible(
              flex: 4,
              child: Image(
                  image: NetworkImage(
                      "https://img.freepik.com/free-vector/mobile-login-concept-illustration_114360-135.jpg?size=338&ext=jpg")),
            ),
            Flexible(flex: 3, child: LogInForm()),
          ],
        ),
      ),
    );
  }
}
