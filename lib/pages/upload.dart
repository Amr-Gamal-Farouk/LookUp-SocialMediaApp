import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as Im;
import 'package:image_picker/image_picker.dart';
import 'package:look_up/models/user.dart';
import 'package:look_up/pages/home.dart';
import 'package:look_up/widgets/progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  User currentUser;
  Upload(this.currentUser);

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();
  String downloadUrl;

  TextEditingController captionCont = TextEditingController();
  TextEditingController locationCont = TextEditingController();

  Container splashScreen() {
    var height = MediaQuery.of(context).size.height;
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/upload.svg",
            height: height / 3,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Uploud Image",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              color: Colors.deepOrange,
              onPressed: () => selectImage(context),
            ),
          )
        ],
      ),
    );
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: [
              SimpleDialogOption(
                child: Text("Photo with camera"),
                onPressed: cameraImageAction,
              ),
              SimpleDialogOption(
                child: Text("Image From Gallery"),
                onPressed: galleryImageAction,
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  cameraImageAction() async {
    Navigator.of(context).pop();

    PickedFile file = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxHeight: 675,
        maxWidth: 960,
        imageQuality: 85);
    print(file.path);
    setState(() {
      this.file = File(file.path);
    });
  }

  galleryImageAction() async {
    Navigator.of(context).pop();

    PickedFile file = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxHeight: 675, maxWidth: 960);
    print(file.path);
    setState(() {
      this.file = File(file.path);
    });
  }

  Scaffold uploadScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Center(
          child: Text(
            "Caption Post",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        actions: [
          FlatButton(
              onPressed: isUploading ? null : () => postAction(),
              child: Text(
                "Post",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ))
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress(context) : Container(),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
//                      fit: BoxFit.cover,
                      image: FileImage(
                        file,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.currentUser.photoUrl),
            ),
            title: TextField(
              controller: captionCont,
              decoration: InputDecoration(
                  hintText: "Write a Caption", border: InputBorder.none),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35,
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationCont,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken? ",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: getUserLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              label: Text(
                "Use Current Location",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File("$path/img_$postId.jpg")
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));

    setState(() {
      this.file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    TaskSnapshot uploadTask =
        await storageRef.child("post_$postId.jpg").putFile(imageFile);
    return uploadTask.ref.getDownloadURL();
  }

  createPost(String mediaUrl, String description, String location) async {
    postRef.doc(widget.currentUser.id).collection("userPosts").doc(postId).set({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "userName": widget.currentUser.userName,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timesTemp": timesTemp,
      "likes": {},
    });
  }

  postAction() async {
    setState(() {
      isUploading = true;
    });
//    compress Image
    await compressImage();
//    upload image
    String downloadUrl = await uploadImage(file);
//    create post on firestore
    await createPost(downloadUrl, captionCont.text, locationCont.text);
//    clear
    captionCont.clear();
    locationCont.clear();
    setState(() {
      isUploading = false;
      file = null;
      postId = Uuid().v4();
    });
  }

  getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark placemark = placemarks[0];
    String formatAddress = "${placemark.locality}, ${placemark.country}";
    locationCont.text = formatAddress;
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? splashScreen() : uploadScreen();
  }
}
