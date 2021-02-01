import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:look_up/models/user.dart';
import 'package:look_up/widgets/header.dart';

import 'home.dart';

final userRef = FirebaseFirestore.instance.collection("users");

class Timeline extends StatefulWidget {
  User currentUser;
  Timeline(this.currentUser);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
    getTimeLine();
  }

  getTimeLine() async {
    //     get following
    QuerySnapshot followersQuery = await followingRef
        .doc(widget.currentUser.id)
        .collection('userFollowing')
        .get();
//     getPosts
    followersQuery.docs.forEach((element) async {
      QuerySnapshot followersPostsQuery =
          await postRef.doc(element.id).collection("userPosts").get();
      followersPostsQuery.docs.forEach((element) async {
        if (element.exists) {
          await timeLineRef
              .doc(widget.currentUser.id)
              .collection('timeLinePosts')
              .doc(element.id)
              .set(element.data());
        }
      });
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context,
          title: "Look Up", elevation: 0, fontFamily: "Signatra", textSize: 50),
      body: Container(),
    );
  }
}
