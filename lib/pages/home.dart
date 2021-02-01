import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:look_up/models/user.dart';
import 'package:look_up/pages/activity_feed.dart';
import 'package:look_up/pages/create_account.dart';
import 'package:look_up/pages/profile.dart';
import 'package:look_up/pages/search.dart';
import 'package:look_up/pages/timeline.dart';
import 'package:look_up/pages/upload.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

final GoogleSignIn googleSignIn = GoogleSignIn();
final Reference storageRef = FirebaseStorage.instance.ref();
final userRef = FirebaseFirestore.instance.collection("users");
final postRef = FirebaseFirestore.instance.collection("posts");
final commentRef = FirebaseFirestore.instance.collection("comments");
final activityFeedRef = FirebaseFirestore.instance.collection("feeds");
final followingRef = FirebaseFirestore.instance.collection("following");
final followersRef = FirebaseFirestore.instance.collection("followers");
final timeLineRef = FirebaseFirestore.instance.collection("timeLine");

final timesTemp = DateTime.now();
User currentUser;

class _HomeState extends State<Home> {
  PageController pagesController;
  int pageIndex = 0;
  bool isAuth = false;
  @override
  void initState() {
    super.initState();
    pagesController = PageController();

    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (error) {
      print("signin Error : $error");
    });

    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((error) {
      print("signin Error in silentltly : $error");
    });
  }

  @override
  void dispose() {
    super.dispose();
    pagesController.dispose();
  }

  handleSignIn(account) async {
    if (account != null) {
      print("account info : $account");
      final userInfo = googleSignIn.currentUser;
      DocumentSnapshot user = await userRef.doc(userInfo.id).get();
      if (!user.exists) {
        final userName = await Navigator.push(
            context, MaterialPageRoute(builder: (context) => CreateAccount()));
        userRef.doc(userInfo.id).set({
          "id": userInfo.id,
          "email": userInfo.email,
          "userName": userName,
          "photoUrl": userInfo.photoUrl,
          "displayName": userInfo.displayName,
          "bio": "",
          "timesTemp": timesTemp,
        });
        user = await userRef.doc(userInfo.id).get();
      }
      currentUser = User.fromDocument(user);
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  signIn() {
    googleSignIn.signIn();
  }

  signOut() {
    googleSignIn.signOut();
  }

  changePage(pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  tapChangePage(pageIndex) {
    pagesController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: [
          Timeline(currentUser),
//          RaisedButton(
//            onPressed: signOut,
//            child: Text("Logout"),
//          ),

          ActivityFeed(),
          Upload(currentUser),
          Search(),
          Profile(profileId: currentUser.id),
        ],
        controller: pagesController,
        onPageChanged: changePage,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: tapChangePage,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Look Up",
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage("assets/images/google_signin_button.png"),
                  fit: BoxFit.cover,
                )),
              ),
              onTap: signIn,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
