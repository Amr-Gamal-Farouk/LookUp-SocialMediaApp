import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:look_up/pages/home.dart';
import 'package:look_up/pages/post_screen.dart';
import 'package:look_up/pages/profile.dart';
import 'package:look_up/widgets/header.dart';
import 'package:look_up/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot value = await activityFeedRef
        .doc(currentUser.id)
        .collection("feedItems")
        .orderBy('timesTemp', descending: true)
        .limit(50)
        .get();
    List<ActivityFeedItem> items = [];
    value.docs.forEach((element) {
      print('##### ${element['userName']}');
      items.add(ActivityFeedItem.fromDoc(element));
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: header(context, title: "Activity Feeds"),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
            }
            if (!snapshot.hasData) {
              return circularProgress(context);
            }

            return ListView(
              children: snapshot.data,
            );
          },
        ),
      ),
    );
  }
}

class ActivityFeedItem extends StatelessWidget {
  final String userName;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String userImage;
  final String commentData;
  final Timestamp timesTemp;

  ActivityFeedItem(
      {Key key,
      this.userName,
      this.userId,
      this.type,
      this.mediaUrl,
      this.postId,
      this.userImage,
      this.commentData,
      this.timesTemp})
      : super(key: key);

  Widget mediaPreview;
  String activityItemText;

  factory ActivityFeedItem.fromDoc(DocumentSnapshot doc) {
    return ActivityFeedItem(
      userName: doc['userName'],
      userId: doc['userId'],
      type: doc['type'],
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
      userImage: doc['userPhoto'],
      commentData: doc['commentData'],
      timesTemp: doc['timesTemp'],
    );
  }

  configureMediaPreview(context) {
    if (type == "like" || type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(mediaUrl),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }

    if (type == 'like') {
      activityItemText = ' liked your Post';
    } else if (type == 'comment') {
      activityItemText = ' replied $commentData';
    } else if (type == 'follow') {
      activityItemText = ' is following you';
    } else {
      activityItemText = ' error unknown type: $type';
    }
  }

  showPost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostScreen(
                  postId: postId,
                  userId: userId,
                )));
  }

  showProfile(context, {String profileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Profile(
                  profileId: profileId,
                )));
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  children: [
                    TextSpan(
                      text: userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '$activityItemText',
                    ),
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(userImage),
          ),
          subtitle: Text(
            timeAgo.format(timesTemp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}
