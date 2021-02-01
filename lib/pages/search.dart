import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:look_up/models/user.dart';
import 'package:look_up/pages/home.dart';
import 'package:look_up/pages/profile.dart';
import 'package:look_up/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<QuerySnapshot> searchResultFuture;
  TextEditingController searchCont = TextEditingController();

  AppBar searchBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchCont,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Search for User",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            color: Theme.of(context).primaryColor,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  searchNoContent() {
    var height = MediaQuery.of(context).size.height;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            SvgPicture.asset(
              'assets/images/search.svg',
              height: height / 3,
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                fontSize: 60,
              ),
            )
          ],
        ),
      ),
    );
  }

  handleSearch(String searchInput) {
    Future<QuerySnapshot> users =
        userRef.where("displayName", isGreaterThanOrEqualTo: searchInput).get();
    setState(() {
      searchResultFuture = users;
    });
  }

  searchResult() {
    return FutureBuilder(
      future: searchResultFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context);
        }
        List<UserResult> searchResult = [];
        snapshot.data.docs.forEach((doc) {
          User user = User.fromDocument(doc);
          searchResult.add(UserResult(user));
        });
        if (searchResult.isEmpty) {
          return Center(
              child: Text(
            "No Matching User",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
          ));
        }
        return ListView(
          children: searchResult,
        );
      },
    );
  }

  clearSearch() {
    searchCont.clear();
    setState(() {
      searchResultFuture = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: searchBar(),
      body: searchResultFuture == null ? searchNoContent() : searchResult(),
    );
  }
}

class UserResult extends StatelessWidget {
  User user;
  UserResult(this.user);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                user.userName,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(
            color: Colors.white54,
            height: 2,
          )
        ],
      ),
    );
  }
}

showProfile(context, {String profileId}) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Profile(
                profileId: profileId,
              )));
}
