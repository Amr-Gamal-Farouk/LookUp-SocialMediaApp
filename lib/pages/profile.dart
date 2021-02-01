import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:look_up/models/user.dart';
import 'package:look_up/pages/edit_profile.dart';
import 'package:look_up/pages/home.dart';
import 'package:look_up/widgets/header.dart';
import 'package:look_up/widgets/post.dart';
import 'package:look_up/widgets/post_tile.dart';
import 'package:look_up/widgets/progress.dart';

class Profile extends StatefulWidget {
  String profileId;

  Profile({this.profileId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final currentUserId = currentUser?.id;
  bool isLoading = false;
  int postsCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  List posts = [];
  bool gridOrientation = true;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    getPosts();
    getFollowing();
    getFollowers();
    checkIsFollowing();
  }

  checkIsFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followersCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();

    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  profileActionButton() {
    if (currentUserId == widget.profileId) {
      return customButton("Edit Profile", editProfileAction);
    } else if (isFollowing) {
      return customButton("UnFollow", unFollowAction);
    } else {
      return customButton("Follow", followAction);
    }
  }

  unFollowAction() {
    setState(() {
      isFollowing = false;
    });
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });

    timeLineRef.doc(widget.profileId).get().then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  followAction() {
    setState(() {
      isFollowing = true;
    });
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});

    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});

    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      "type": "follow",
      "commentData": '',
      "userName": currentUser.userName,
      "userId": currentUserId,
      "userPhoto": currentUser.photoUrl,
      "postId": widget.profileId,
      "mediaUrl": '',
      "timesTemp": DateTime.now(),
    });
  }

  editProfileAction() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => EditProfile(currentUserId)));
  }

  customButton(String buttonTitle, buttonAction) {
    return Container(
      padding: EdgeInsets.only(top: 2),
      child: FlatButton(
        onPressed: buttonAction,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: 27,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: isFollowing ? Colors.grey : Colors.blue),
          ),
          child: Text(
            buttonTitle,
            style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  profileHeader() {
    return FutureBuilder(
      future: userRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(user.photoUrl),
                    radius: 40,
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            countColumn("posts", postsCount),
                            countColumn("followers", followersCount),
                            countColumn("following", followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            profileActionButton(),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 12),
                child: Text(
                  user.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 4),
                child: Text(
                  user.displayName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(top: 2),
                child: Text(
                  user.bio,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Column countColumn(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            title,
            style: TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 15),
          ),
        ),
      ],
    );
  }

  getPosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postRef
        .doc(widget.profileId)
        .collection("userPosts")
        .orderBy("timesTemp", descending: true)
        .get();
    setState(() {
      isLoading = false;
      postsCount = snapshot.docs.length;
      posts = snapshot.docs.map((e) => Post.postFromDoc(e)).toList();
    });
  }

  buildProfilePosts() {
    var height = MediaQuery.of(context).size.height;
    if (isLoading) {
      return circularProgress(context);
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/images/no_content.svg",
              height: height / 3,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "No Posts",
                style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      );
    } else if (gridOrientation) {
      List<GridTile> postsGrid = [];

      posts.forEach((element) {
        postsGrid.add(GridTile(child: PostTile(element)));
      });

      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: postsGrid,
      );
    } else if (!gridOrientation) {
      return Column(
        children: posts,
      );
    }
  }

  togglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.grid_on),
          onPressed: () {
            setState(() {
              gridOrientation = true;
            });
          },
          color: gridOrientation ? Theme.of(context).primaryColor : Colors.grey,
        ),
        IconButton(
          icon: Icon(Icons.list),
          onPressed: () {
            setState(() {
              gridOrientation = false;
            });
          },
          color: gridOrientation ? Colors.grey : Theme.of(context).primaryColor,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        title: "Profile",
        elevation: 0.0,
        fontFamily: "",
        textSize: 22.0,
      ),
      body: ListView(
        children: [
          profileHeader(),
          Divider(
            height: 0.0,
          ),
          togglePostOrientation(),
          Divider(
            height: 0,
          ),
          buildProfilePosts()
        ],
      ),
    );
  }
}
