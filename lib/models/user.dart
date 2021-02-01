import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String userName;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;

  User(
      {this.id,
      this.userName,
      this.email,
      this.photoUrl,
      this.displayName,
      this.bio});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.id,
      userName: doc['userName'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
    );
  }
}
