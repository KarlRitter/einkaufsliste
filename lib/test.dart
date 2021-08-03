import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:einkaufsliste_new/container.dart';

class Test extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LadenState();
}

class LadenState extends State<Test> with SingleTickerProviderStateMixin {
  static AnimationController _animationController;
  static BuildContext _context;

  static void pop(ziel, arg) {
    _animationController.dispose();
    Navigator.popAndPushNamed(_context, ziel, arguments: arg);
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(seconds: 4), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Column(
      children: <Widget>[
        Body(
          Center(
            child: Loader(),
          ),
        ),
      ],
    );
  }
}

class Loader extends StatelessWidget {
  List<Tile> tiles;
  int updateCount = 0;

  Loader () {
    for (int i = 0; i < 4; i++) {
      tiles.add(Tile(i, _update));
    }
  }

  void _update() {
    if (updateCount == 1) {
      updateCount = 0;
    }
    updateCount++;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      width: 280,
      height: 60,
      child: Stack(
        children: tiles
      ),
    );
  }

}

class Tile extends StatefulWidget {
  int i;
  Function update;

  Tile(this.i, this.update);

  @override
  _TileState createState() => _TileState();
}

class _TileState extends State<Tile> {
  int _state;

  _TileState() {
    this._state = widget.i;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      onEnd: widget.update,
      left: 30 + 60.0 * _state,
      bottom: 10.0,
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(color: Colors.lightGreen, borderRadius: BorderRadius.circular(90)),
      ),
    );
  }
}
