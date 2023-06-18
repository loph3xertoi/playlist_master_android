import 'package:flutter/material.dart';

class MyFooter extends StatefulWidget {
  @override
  State<MyFooter> createState() => _MyFooterState();
}

class _MyFooterState extends State<MyFooter> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70.0,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.transparent.withOpacity(0.2),
            spreadRadius: 0.0,
            blurRadius: 4.0,
            offset: Offset(0.0, 0.0), // changes position of shadow
          ),
        ],
      ),
    );
  }
}
