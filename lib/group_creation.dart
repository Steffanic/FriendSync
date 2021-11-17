import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friend_sync/home.dart';
import 'package:friend_sync/providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class GroupCreationPage extends StatefulWidget {
  FirebaseAuth auth;
  GroupCreationPage({required this.auth});
  @override
  State<GroupCreationPage> createState() => _GroupCreationPageState();
}

class _GroupCreationPageState extends State<GroupCreationPage> {
  String? groupName;
  String? groupTagline;
  Uint8List? pfpImage;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "New Group",
      initialRoute: '/name',
      routes: {
        '/name': (context) => GroupNamePage(
              setGroupName: _setGroupName,
            ),
        '/tagline': (context) => GroupTaglinePage(
              setGroupTagline: _setGroupTagline,
            ),
        '/photo': (context) => GroupPhotoPage(
            setGroupPhoto: _setGroupPhoto,
            submitToRTDB: _submitToRTDB,
            auth: widget.auth)
      },
    );
  }

  _setGroupName(String name) {
    setState(() {
      groupName = name;
    });
  }

  _setGroupPhoto(Uint8List image) {
    setState(() {
      pfpImage = image;
    });
  }

  _setGroupTagline(String tagline) {
    setState(() {
      groupTagline = tagline;
    });
  }

  _submitToRTDB(FriendGroupProvider friendGroupProvider) {
    friendGroupProvider.addGroupToRTDB(
        groupName!, groupTagline!, 1, false, pfpImage!);
  }
}

class GroupNamePage extends StatelessWidget {
  Function setGroupName;

  GroupNamePage({
    required this.setGroupName,
  });

  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text("Give your new group a name!"),
          const Text("🤔💭🤔"),
          TextFormField(
            controller: nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Can't think of anything?";
              }
              return null;
            },
            decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Champions of the Sun'),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  width: 50,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                    onPressed: () {
                      setGroupName(nameController.text);
                      Navigator.pushNamed(context, '/tagline');
                    },
                    child: Text("Next")),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class GroupTaglinePage extends StatelessWidget {
  Function setGroupTagline;

  GroupTaglinePage({
    required this.setGroupTagline,
  });

  final TextEditingController taglineController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text("Say something about your group!"),
          const Text("🤔💭🤔"),
          TextFormField(
            controller: taglineController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Can't think of anything?";
              }
              return null;
            },
            decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Defenders of Justics'),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  width: 50,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: ElevatedButton(
                    onPressed: () {
                      setGroupTagline(taglineController.text);
                      Navigator.pushNamed(context, '/photo');
                    },
                    child: Text("Next")),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class GroupPhotoPage extends StatelessWidget {
  Function setGroupPhoto;
  Function submitToRTDB;
  FirebaseAuth auth;

  GroupPhotoPage(
      {required this.setGroupPhoto,
      required this.submitToRTDB,
      required this.auth});

  final pfpController = ImagePicker();

  Future getMyImage(ImageSource source) async {
    final pickedImage = await pfpController.pickImage(source: source);
    final pickedImageBytes = await pickedImage!.readAsBytes();
    setGroupPhoto(pickedImageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) => Dialog(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                getMyImage(ImageSource.camera);
                              },
                              child: Row(children: const [
                                Text("Take a Picture"),
                                Icon(Icons.camera),
                              ])),
                          ElevatedButton(
                              onPressed: () {
                                getMyImage(ImageSource.gallery);
                              },
                              child: Row(children: const [
                                Text("Choose from Gallery"),
                                Icon(Icons.photo),
                              ])),
                        ],
                      ),
                    ],
                  ),
                )),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:
                      LinearGradient(colors: [Colors.white, Colors.blue])),
            ),
            Text("Upload a Group photo!"),
            Row(
              children: [
                Expanded(
                  child: Container(
                    width: 50,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Consumer<FriendGroupProvider>(
                    builder: (context, friendGroupProvider, child) =>
                        ElevatedButton(
                            onPressed: () {
                              submitToRTDB(friendGroupProvider);
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (context) => HomePage(
                                            auth: auth,
                                          )));
                            },
                            child: Text("Submit")),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
