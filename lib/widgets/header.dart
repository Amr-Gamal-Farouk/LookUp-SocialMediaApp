import 'package:flutter/material.dart';

AppBar header(context,
    {double elevation, String title, String fontFamily, double textSize}) {
  return AppBar(
    elevation: elevation,
    title: Text(
      title,
      style: TextStyle(
        fontSize: textSize,
        fontFamily: fontFamily,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
    automaticallyImplyLeading: false,
  );
}
