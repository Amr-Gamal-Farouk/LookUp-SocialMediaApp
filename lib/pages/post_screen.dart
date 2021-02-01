import 'package:flutter/material.dart';
import 'package:look_up/pages/home.dart';
import 'package:look_up/widgets/header.dart';
import 'package:look_up/widgets/post.dart';
import 'package:look_up/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  const PostScreen({Key key, this.userId, this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postRef.doc(userId).collection('userPosts').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        Post post = Post.postFromDoc(snapshot.data);
        return Scaffold(
          appBar: header(context, title: post.description),
          body: ListView(
            children: [
              Container(
                child: post,
              )
            ],
          ),
        );
      },
    );
  }
}
