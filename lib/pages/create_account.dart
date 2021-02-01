import 'dart:async';

import 'package:flutter/material.dart';
import 'package:look_up/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String username;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  submitAction() {
    var formState = formKey.currentState;
    if (formState.validate()) {
      formState.save();
      SnackBar snackBar = SnackBar(content: Text("Welcome $username!"));
      scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: scaffoldKey,
      appBar: header(context,
          fontFamily: "",
          textSize: 16,
          elevation: 0,
          title: "Set up your profile"),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    "Create User Name",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      autovalidate: true,
                      validator: (val) {
                        if (val.trim().length < 3 || val.isEmpty) {
                          return "User Name too short!";
                        } else if (val.trim().length > 20) {
                          return "User Name too Long!";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (val) => username = val,
                      decoration: InputDecoration(
                          hintText: "User Name",
                          labelText: "User Name",
                          labelStyle: TextStyle(fontSize: 15),
                          border: OutlineInputBorder()),
                    ),
                  ),
                ),
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(7)),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: submitAction,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
