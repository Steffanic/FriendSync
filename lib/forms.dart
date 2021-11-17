import 'package:firebase_database/firebase_database.dart';
import 'package:friend_sync/providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/home.dart';
import 'package:friend_sync/utility.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';

// Define a custom Form widget.
class LogInForm extends StatefulWidget {
  final FirebaseAuth? auth;
  final DatabaseReference? db;
  final firebase_storage.FirebaseStorage? storage;
  const LogInForm({Key? key, this.auth, this.db, this.storage})
      : super(key: key);

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
  late final userListener;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    userListener.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    userListener = widget.auth!.userChanges().listen(
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
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HomePage(
                  auth: widget.auth,
                  db: widget.db,
                  storage: widget.storage,
                )));
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

class NewGroupForm extends StatefulWidget {
  const NewGroupForm({Key? key}) : super(key: key);

  @override
  NewGroupFormState createState() {
    return NewGroupFormState();
  }
}

class NewGroupFormState extends State<NewGroupForm> {
  final _newGroupFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final taglineController = TextEditingController();
  final pfpController = ImagePicker();

  late final pfpImage;

  Future getMyImage(ImageSource source) async {
    final pickedImage = await pfpController.pickImage(source: source);
    final pickedImageBytes = await pickedImage!.readAsBytes();
    setState(() {
      if (pickedImage != null) {
        pfpImage = pickedImageBytes;
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    nameController.dispose();
    taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _newGroupFormKey,
        child: Container(
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                      flex: 3,
                      child: Text(
                          "You have some important decisions to make! Have fun 😁")),
                  //Group Picture
                  Flexible(
                      flex: 8,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => Dialog(
                                    child: Column(
                                      children: [
                                        Text("Upload a photo:"),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  getMyImage(
                                                      ImageSource.camera);
                                                },
                                                child: Row(children: const [
                                                  Text("Take a Picture"),
                                                  Icon(Icons.camera),
                                                ])),
                                            ElevatedButton(
                                                onPressed: () {
                                                  getMyImage(
                                                      ImageSource.gallery);
                                                },
                                                child: Row(children: const [
                                                  Text("Choose from Gallery"),
                                                  Icon(Icons.photo),
                                                ])),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ));
                        },
                        child: Container(
                          height: 100,
                          margin: EdgeInsets.all(IMAGE_MARGIN),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.person_add),
                          ), //Profile picture
                        ),
                      )),
                  // Group name
                  Flexible(
                    flex: 6,
                    child: Container(
                        margin: EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              flex: 4,
                              child: TextFormField(
                                controller: nameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a name.";
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Name your squad',
                                ),
                              ),
                            ),
                            Flexible(
                                flex: 2,
                                child: TextFormField(
                                  controller: taglineController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter some banner text.";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'Add some banner text!',
                                  ),
                                )),
                          ],
                        )),
                  ),
                ],
              ),
              Consumer<FriendGroupProvider>(
                builder: (context, friendGroupProvider, child) =>
                    ElevatedButton(
                        onPressed: () {
                          friendGroupProvider.addGroupToRTDB(
                              nameController.text,
                              taglineController.text,
                              1,
                              false,
                              pfpImage);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Make your new group!"),
                        )),
              )
            ],
          ),
        ));
  }
}

class NewGroupFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: NewGroupForm(),
    ));
  }
}
