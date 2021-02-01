import 'package:flutter/material.dart';
import 'package:look_up/pages/post_screen.dart';
import 'package:look_up/widgets/custom_image.dart';
import 'package:look_up/widgets/post.dart';

class PostTile extends StatelessWidget {
  Post post;
  PostTile(this.post);

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  postId: post.postId,
                  userId: post.ownerId,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
