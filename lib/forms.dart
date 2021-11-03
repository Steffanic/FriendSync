import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/home.dart';
import 'package:friend_sync/utility.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

// Define a custom Form widget.
class LogInForm extends StatefulWidget {
  const LogInForm({Key? key}) : super(key: key);

  @override
  LogInFormState createState() {
    return LogInFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class LogInFormState extends State<LogInForm> {
  User? user;
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _logInFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _auth.userChanges().listen(
          (event) => setState(() => user = event),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _logInFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter your email',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              obscureText: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter your password',
              ),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(
              onPressed: () {
                authenticateUser();
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Sign In",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                registerUser();
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Register",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> registerUser() async {
    if (_logInFormKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);
        showToast(context,
            "User registered with email: ${userCredential.user!.providerData[0].email}\nPlease sign in!");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
        showToast(context, "${e.message}");
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> authenticateUser() async {
    if (_logInFormKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);
        showToast(context,
            "User signed in with email: ${userCredential.user!.providerData[0].email}");

        user = userCredential.user;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage(user: user)));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
          showToast(context, "No user found for that email.");
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
        showToast(context, "${e.message}");
      }
    }
  }
}
