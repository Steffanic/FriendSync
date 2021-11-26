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
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "New Group",
      initialRoute: '/name',
      routes: {
        '/name': (context) => GroupNamePage(
              groupName: groupName,
              setGroupName: _setGroupName,
              onItemTapped: _onItemTapped,
            ),
        '/tagline': (context) => GroupTaglinePage(
              groupTagline: groupTagline,
              setGroupTagline: _setGroupTagline,
              onItemTapped: _onItemTapped,
            ),
        '/photo': (context) => GroupPhotoPage(
            groupPhoto: pfpImage,
            setGroupPhoto: _setGroupPhoto,
            submitToRTDB: _submitToRTDB,
            onItemTapped: _onItemTapped,
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

  _onItemTapped(int index, BuildContext subcontext) {
    if (index == 0) {
      if (ModalRoute.of(subcontext)!.isFirst) {
        Navigator.of(subcontext, rootNavigator: true).pop();
      } else {
        Navigator.of(subcontext).pop();
      }
    }
  }
}

class GroupNamePage extends StatelessWidget {
  String? groupName;
  Function setGroupName;
  Function onItemTapped;

  GroupNamePage(
      {this.groupName, required this.setGroupName, required this.onItemTapped});

  TextEditingController? nameController;

  @override
  Widget build(BuildContext context) {
    nameController =
        TextEditingController(text: groupName != null ? groupName : "");
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: () => onItemTapped(0, context),
                      child: Icon(Icons.arrow_left_rounded)),
                ],
              ),
            ),
            Flexible(flex: 3, child: Text("Give your new group a name!")),
            Flexible(flex: 3, child: Text("🤔💭🤔")),
            Flexible(
              flex: 2,
              child: TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Can't think of anything?";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Group Name',
                    hintText: 'Champions of the Sun'),
              ),
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
                        setGroupName(nameController!.text);
                        Navigator.pushNamed(context, '/tagline');
                      },
                      child: Text("Next")),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class GroupTaglinePage extends StatelessWidget {
  String? groupTagline;
  Function setGroupTagline;
  Function onItemTapped;

  GroupTaglinePage(
      {this.groupTagline,
      required this.setGroupTagline,
      required this.onItemTapped});

  TextEditingController? taglineController;

  @override
  Widget build(BuildContext context) {
    taglineController =
        TextEditingController(text: groupTagline != null ? groupTagline : "");
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () => onItemTapped(0, context),
                      child: Icon(Icons.arrow_left_rounded)),
                ],
              ),
            ),
            Flexible(flex: 3, child: Text("Say something about your group!")),
            Flexible(flex: 3, child: Text("🤔💭🤔")),
            Flexible(
              flex: 2,
              child: TextFormField(
                controller: taglineController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Can't think of anything?";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Group Description',
                    hintText: 'Masters of Karate'),
              ),
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
                        setGroupTagline(taglineController!.text);
                        Navigator.pushNamed(context, '/photo');
                      },
                      child: Text("Next")),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class GroupPhotoPage extends StatelessWidget {
  Uint8List? groupPhoto;
  Function setGroupPhoto;
  Function submitToRTDB;
  Function onItemTapped;
  FirebaseAuth auth;

  GroupPhotoPage(
      {this.groupPhoto,
      required this.setGroupPhoto,
      required this.submitToRTDB,
      required this.onItemTapped,
      required this.auth});

  final pfpController = ImagePicker();

  Future getMyImage(ImageSource source) async {
    final pickedImage = await pfpController.pickImage(source: source);
    final pickedImageBytes = await pickedImage!.readAsBytes();
    setGroupPhoto(pickedImageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () => onItemTapped(0, context),
                      child: Icon(Icons.arrow_left_rounded)),
                ],
              ),
            ),
            Flexible(
              flex: 3,
              child: InkWell(
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
                  },
                  child: Container(
                    child:
                        groupPhoto != null ? Image.memory(groupPhoto!) : null,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                        gradient: LinearGradient(
                            colors: [Colors.white, Colors.blue],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)),
                  )),
            ),
            Flexible(flex: 2, child: Text("Upload a Group photo!")),
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
