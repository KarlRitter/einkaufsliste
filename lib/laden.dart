import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'container.dart';

class Laden extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LadenState();
}

class LadenState extends State<Laden> with SingleTickerProviderStateMixin{
  static AnimationController _animationController;
  static BuildContext _context;

  static void pop(ziel, arg) {
    _animationController.dispose();
    Navigator.popAndPushNamed(_context, ziel, arguments: arg);
  }

   @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(seconds: 2), vsync: this)..repeat();
  }

  @override
  Widget build(BuildContext context) {
     _context = context;
    return Column(
      children: <Widget>[
        Body(
          Center(
            child: RotationTransition(
              child: Image(image: AssetImage('images/loader.png')),
              alignment: Alignment.center,
              turns: _animationController,
            ),
          ),
        ),
      ],
    );
  }
}
