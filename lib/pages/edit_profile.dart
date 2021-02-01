import "package:flutter/material.dart";
import 'package:look_up/models/user.dart';
import 'package:look_up/pages/home.dart';
import 'package:look_up/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  String currentId;
  EditProfile(this.currentId);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;
  User currentUser;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController bioCont = TextEditingController();
  TextEditingController displayNameCont = TextEditingController();
  bool validName = true;
  bool validBio = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    final doc = await userRef.doc(widget.currentId).get();
    currentUser = User.fromDocument(doc);
    bioCont.text = currentUser.bio;
    displayNameCont.text = currentUser.displayName;
    setState(() {
      isLoading = false;
    });
  }

  buildTextField(TextEditingController cont, String hint, bool check,
      String errorMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            hint,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextFormField(
          controller: cont,
          decoration: InputDecoration(
              hintText: hint, errorText: check ? null : errorMessage),
        ),
      ],
    );
  }

  confirmUpdate() {
    setState(() {
      displayNameCont.text.trim().length < 3 || displayNameCont.text.isEmpty
          ? validName = false
          : validName = true;
      bioCont.text.trim().length > 100 ? validBio = false : validBio = true;
    });
    if (validName && validBio) {
      userRef
          .doc(currentUser.id)
          .update({"displayName": displayNameCont.text, "bio": bioCont.text});
      scaffoldKey.currentState.showSnackBar(
        new SnackBar(
          content: Text("Profile Update"),
        ),
      );
    }
  }

  logOut() async {
    await googleSignIn.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.done,
              color: Colors.green,
              size: 26,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress(context)
          : ListView(
              children: [
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(currentUser.photoUrl),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            buildTextField(displayNameCont, "Display Name",
                                validName, "Name Too short!"),
                            buildTextField(
                                bioCont, "Bio", validBio, "Bio Too long"),
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: confirmUpdate,
                        child: Text(
                          "Update Profile",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlatButton.icon(
                          onPressed: logOut,
                          icon: Icon(
                            Icons.clear,
                            color: Colors.red,
                          ),
                          label: Text(
                            "Logout",
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
