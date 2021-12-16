/*
   Copyright 2021 Patrick Steffanic

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   */

import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:friend_sync/arguments.dart';
import 'package:friend_sync/group.dart';
import 'package:http/http.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:friend_sync/providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/home.dart';
import 'package:friend_sync/utility.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

// Define a custom Form widget.
class LogInForm extends StatefulWidget {
  final FirebaseAuth? auth;
  final DatabaseReference? db;
  final firebase_storage.FirebaseStorage? storage;
  final GoogleAuthProvider? googleProvider;
  const LogInForm(
      {Key? key, this.auth, this.db, this.storage, this.googleProvider})
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
          ]),
          Text("or"),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => signInWithGoogle(),
                child: Image(
                    image: !kIsWeb
                        ? AssetImage(
                            "assets/google_signin_buttons/android/hdpi/btn_google_dark_normal_hdpi.9.png")
                        : AssetImage(
                            'assets/google_signin_buttons/web/1x/btn_google_signin_dark_normal_web.png')),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> registerUser() async {
    if (_logInFormKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await widget.auth!
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
        UserCredential userCredential = await widget.auth!
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

  Future<void> signInWithGoogle() async {
    UserCredential? userCredential;
    if (kIsWeb) {
      await widget.auth!.signInWithPopup(widget.googleProvider!).then((value) {
        user = value.user;
        bool userExists = false;
        final userRef = widget.db!.child('members').child(user!.uid);
        userRef.get().then((val) {
          userExists = val.exists;
          if (!userExists) {
            userRef.update({'email': user!.email});
            userRef.update({'name': user!.displayName});
            userRef.update({'profilePictureURL': user!.photoURL});
            userRef.update({
              'friendList': {user!.uid: user!.uid}
            });
          }
        });

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HomePage(
                  auth: widget.auth,
                  db: widget.db,
                  storage: widget.storage,
                )));
      });
    } else if (Platform.isAndroid) {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication.then((value) async {
        final credential = GoogleAuthProvider.credential(
            accessToken: value.accessToken, idToken: value.idToken);
        FirebaseAuth.instance.signInWithCredential(credential).then((value) {
          user = value.user;
          bool userExists = false;
          final userRef = widget.db!.child('members').child(user!.uid);
          userRef.get().then((value) {
            userExists = value.exists;
            if (!userExists) {
              userRef.update({'email': user!.email});
              userRef.update({'name': user!.displayName});
              userRef.update({'profilePictureURL': user!.photoURL});
              userRef.update({
                'friendList': {user!.uid: user!.uid}
              });
            }
          });

          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => HomePage(
                    auth: widget.auth,
                    db: widget.db,
                    storage: widget.storage,
                  )));
        });
      });
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

class UserSettingsForm extends StatefulWidget {
  final FirebaseAuth? auth;
  final DatabaseReference? db;
  final firebase_storage.FirebaseStorage? storage;
  final BuildContext? context;

  UserSettingsForm({this.auth, this.db, this.storage, this.context});

  @override
  UserSettingsFormState createState() {
    return UserSettingsFormState();
  }
}

class UserSettingsFormState extends State<UserSettingsForm> {
  Uint8List? userPhoto;
  String? userName;
  String? userTagline;
  final pfpController = ImagePicker();
  bool isButtonEnabled = false;
  bool isImageDifferent = false;

  Future getMyImage(ImageSource source) async {
    final pickedImage = await pfpController.pickImage(source: source);
    final pickedImageBytes = await pickedImage!.readAsBytes();
    setState(() {
      userPhoto = pickedImageBytes;
    });
    isButtonEnabled = true;
    isImageDifferent = true;
  }

  void setUserPhoto(String url) {
    readBytes(Uri.parse(url)).then((value) {
      setState(() {
        userPhoto = value.buffer.asUint8List();
      });
    });
  }

  final _userSettingsKey = GlobalKey<FormState>();
  late final nameController;
  late final statusController;

  @override
  void initState() {
    FriendGroupProvider friendGroupProvider =
        Provider.of(widget.context!, listen: false);

    var url = friendGroupProvider
        .getMemberByID(friendGroupProvider.getCurrentMemberID())
        .memberProfilePicture;
    setUserPhoto(url);
    userName = friendGroupProvider
        .getMemberByID(friendGroupProvider.getCurrentMemberID())
        .memberName;
    userTagline = friendGroupProvider
        .getMemberByID(friendGroupProvider.getCurrentMemberID())
        .memberStatus;

    nameController = TextEditingController(text: userName);
    statusController = TextEditingController(text: userTagline);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: InkWell(
                      radius: 5,
                      onTap: () {
                        BuildContext dialogContext;
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              dialogContext = context;
                              return Dialog(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {
                                              getMyImage(ImageSource.camera);
                                              Navigator.pop(dialogContext);
                                            },
                                            child: Row(children: const [
                                              Text("Take a Picture"),
                                              Icon(Icons.camera),
                                            ])),
                                        ElevatedButton(
                                            onPressed: () {
                                              getMyImage(ImageSource.gallery);
                                              Navigator.pop(dialogContext);
                                            },
                                            child: Row(children: const [
                                              Text("Choose from Gallery"),
                                              Icon(Icons.photo),
                                            ])),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            });
                      }),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: (userPhoto != null
                              ? MemoryImage(userPhoto!) as ImageProvider
                              : NetworkImage(GENERIC_MEMBER_URL))),
                      shape: BoxShape.circle,
                      color: Colors.blue,
                      gradient: LinearGradient(
                          colors: [Colors.white, Colors.blue],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                )),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Flexible(
                    flex: 3,
                    child: TextFormField(
                      controller: nameController,
                      onChanged: (val) {
                        isButtonEnabled = true;
                        userName = val;
                      },
                    )),
                Flexible(
                    flex: 3,
                    child: TextFormField(
                      controller: statusController,
                      onChanged: (val) {
                        isButtonEnabled = true;
                        userTagline = val;
                      },
                    )),
                Flexible(
                    child: Consumer<FriendGroupProvider>(
                  builder: (context, friendGroupProvider, child) =>
                      ElevatedButton(
                    onPressed: () => isButtonEnabled
                        ? _applyChanges(friendGroupProvider)
                        : null,
                    child: Text("Apply Changes"),
                    style: ElevatedButton.styleFrom(primary: Colors.blue),
                  ),
                ))
              ]),
            ),
          )
        ],
      ),
    );
  }

  _applyChanges(FriendGroupProvider friendGroupProvider) async {
    String? profilePictureURL;

    if (isImageDifferent) {
      profilePictureURL = await friendGroupProvider.uploadUserPhoto(
          userPhoto!, friendGroupProvider.getCurrentMemberID());
    }

    friendGroupProvider.updateMemberInfoRTDB(
        userName, userTagline, profilePictureURL);
  }
}
