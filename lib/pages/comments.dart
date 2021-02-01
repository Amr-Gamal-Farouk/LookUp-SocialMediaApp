import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:look_up/widgets/header.dart';
import 'package:look_up/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import 'home.dart';

class Comments extends StatefulWidget {
  String postId;
  String postOwnerId;
  String postMediaUrl;
  Comments({this.postId, this.postOwnerId, this.postMediaUrl});
  @override
  CommentsState createState() => CommentsState(
      postId: this.postId,
      postOwnerId: this.postOwnerId,
      postMediaUrl: this.postMediaUrl);
}

class CommentsState extends State<Comments> {
  String postId;
  String postOwnerId;
  String postMediaUrl;
  CommentsState({this.postId, this.postOwnerId, this.postMediaUrl});

  TextEditingController makeCommentCont = TextEditingController();

  buildComments() {
    return StreamBuilder(
      stream: commentRef
          .doc(postId)
          .collection("comments")
          .orderBy("timesTemp", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        List<Comment> commentList = [];
        snapshot.data.docs
            .forEach((doc) => commentList.add(Comment.fromDoc(doc)));
        return ListView(
          children: commentList,
        );
      },
    );
  }

  addCommentAction() async {
    commentRef.doc(postId).collection("comments").add({
      "userId": currentUser.id,
      "userName": currentUser.userName,
      "photoUrl": currentUser.photoUrl,
      "timesTemp": DateTime.now(),
      "comment": makeCommentCont.text,
    });
//    if (currentUser.id != postOwnerId) {
    activityFeedRef.doc(postOwnerId).collection('feedItems').add({
      "type": "comment",
      "commentData": makeCommentCont.text,
      "userName": currentUser.userName,
      "userId": currentUser.id,
      "userPhoto": currentUser.photoUrl,
      "postId": postId,
      "mediaUrl": postMediaUrl,
      "timesTemp": DateTime.now(),
    });
//    }
    makeCommentCont.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          header(context, title: "Comments", elevation: 1.1, fontFamily: ""),
      body: Column(
        children: [
          Expanded(child: buildComments()),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: makeCommentCont,
              decoration: InputDecoration(
                hintText: "Comment",
              ),
            ),
            trailing: OutlineButton(
              onPressed: addCommentAction,
              borderSide: BorderSide.none,
              child: Text("Post"),
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String userId;
  final String userName;
  final String userComment;
  final String userPhotoUrl;
  final Timestamp timesTemp;
  Comment(
      {this.userId,
      this.userName,
      this.userComment,
      this.userPhotoUrl,
      this.timesTemp});

  factory Comment.fromDoc(doc) {
    return Comment(
      userName: doc['userName'],
      userComment: doc['comment'],
      userId: doc['photoUrl'],
      timesTemp: doc['timesTemp'],
      userPhotoUrl: doc['photoUrl'],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(userPhotoUrl),
          ),
          title: Text(userComment),
          subtitle: Text(timeAgo.format(timesTemp.toDate())),
        ),
        Divider(),
      ],
    );
  }
}
