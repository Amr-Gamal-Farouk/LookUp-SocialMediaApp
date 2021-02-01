import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:look_up/models/user.dart';
import 'package:look_up/pages/comments.dart';
import 'package:look_up/pages/home.dart';
import 'package:look_up/pages/profile.dart';
import 'package:look_up/widgets/custom_image.dart';
import 'package:look_up/widgets/progress.dart';

class Post extends StatefulWidget {
  String ownerId;
  String postId;
  String userName;
  String location;
  String description;
  String mediaUrl;
  dynamic likes;

  Post({
    this.ownerId,
    this.postId,
    this.userName,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
  });

  factory Post.postFromDoc(DocumentSnapshot doc) {
    return Post(
      location: doc['location'],
      ownerId: doc['ownerId'],
      postId: doc['postId'],
      userName: doc['userName'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int likeCount(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((element) {
      if (element == true) {
        count++;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
      userName: this.userName,
      postId: this.postId,
      ownerId: this.ownerId,
      description: this.description,
      likes: this.likes,
      location: this.location,
      mediaUrl: this.mediaUrl,
      likesCount: this.likeCount(this.likes));
}

class _PostState extends State<Post> {
  String currentUserId = currentUser?.id;
  bool isLiked;
  bool showHeart = false;
  String ownerId;
  String postId;
  String userName;
  String location;
  String description;
  String mediaUrl;
  Map likes;
  int likesCount;

  _PostState({
    this.ownerId,
    this.postId,
    this.userName,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likesCount,
  });

  showProfile(context, {String profileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Profile(
                  profileId: profileId,
                )));
  }

  buildPostHeader() {
    return FutureBuilder(
      future: userRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 22,
            backgroundImage: NetworkImage(user.photoUrl),
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Text(
              user.userName,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => handleDeletePost(context),
          ),
        );
      },
    );
  }

  handleDeletePost(context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('Remove This Post'),
            children: [
              SimpleDialogOption(
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  deletePostOption();
                },
              ),
              SimpleDialogOption(
                child: Text(
                  'Cancel',
                  style: TextStyle(),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  deletePostOption() async {
    if (currentUserId == ownerId) {
      await postRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .get()
          .then((value) => {
                if (value.exists) {value.reference.delete()}
              });
//  delete images
      storageRef.child("post_$postId.jpg").delete();
//  delete activity
      QuerySnapshot activityFeedSnapshot = await activityFeedRef
          .doc(ownerId)
          .collection('feedItems')
          .where('postId', isEqualTo: postId)
          .get();

      activityFeedSnapshot.docs.forEach((element) {
        if (element.exists) {
          element.reference.delete();
        }
      });
//    delete comments

      QuerySnapshot commentsSnapshot =
          await commentRef.doc(postId).collection('comments').get();

      commentsSnapshot.docs.forEach((element) {
        if (element.exists) {
          element.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      child: Stack(
        alignment: Alignment.center,
        children: [
          cachedNetworkImage(mediaUrl),
          showHeart
              ? Animator(
                  duration: Duration(milliseconds: 300),
                  tween: Tween(begin: 0.8, end: 1.4),
                  curve: Curves.elasticOut,
                  cycles: 0,
                  builder: (context, animatorState, child) => Transform.scale(
                        scale: animatorState.value,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 80,
                        ),
                      ))
              : Container()
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 20),
              child: GestureDetector(
                onTap: likePostAction,
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.pink,
                  size: 28,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 20),
              child: GestureDetector(
                onTap: () => showCommentsAction(
                  context,
                  postId: postId,
                  ownerId: ownerId,
                  mediaUrl: mediaUrl,
                ),
                child: Icon(
                  Icons.chat,
                  color: Colors.blue[900],
                  size: 28,
                ),
              ),
            )
          ],
        ),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likesCount likes",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$userName ",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(description),
            )
          ],
        ),
      ],
    );
  }

  showCommentsAction(context,
      {String postId, String ownerId, String mediaUrl}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Comments(
              postId: postId, postOwnerId: ownerId, postMediaUrl: mediaUrl),
        ));
  }

  likePostAction() {
    bool liked = likes[currentUserId] == true;
    if (liked) {
      postRef
          .doc(ownerId)
          .collection("userPosts")
          .doc(postId)
          .update({"likes.$currentUserId": false});

      removeLikeFromActivityFeed();
      setState(() {
        likesCount--;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!liked) {
      postRef
          .doc(ownerId)
          .collection("userPosts")
          .doc(postId)
          .update({"likes.$currentUserId": true});

      addLikeToActivityFeed();
      setState(() {
        likesCount++;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
//    if (currentUserId != ownerId) {
    activityFeedRef.doc(ownerId).collection('feedItems').doc(postId).set({
      "type": "like",
      "userName": currentUser.userName,
      "userId": currentUserId,
      "userPhoto": currentUser.photoUrl,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timesTemp": DateTime.now(),
      'commentData': ''
    });
//    }
  }

  removeLikeFromActivityFeed() {
//    if (currentUserId != ownerId) {
    activityFeedRef
        .doc(ownerId)
        .collection('feedItems')
        .doc(postId)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
//    }
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}
