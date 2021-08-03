import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildBackbutton(Function back) {
  return IconButtonAppbar(back, Icons.arrow_back_ios);
}

class IconButtonAppbar extends IconButton {
  IconButtonAppbar(Function tapFunction, IconData symbol)
      : super(tapFunction, Icon(symbol, size: 25.0, color: Colors.white));
}

class IconButtonBody extends IconButton {
  IconButtonBody(Function tapFuntion, IconData symbol, Color color)
      : super(tapFuntion, Icon(symbol, size: 25.0, color: color));
}

class IconButton extends StatelessWidget {
  final Function tapFunction;
  final Icon icon;

  const IconButton(this.tapFunction, this.icon);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapFunction,
      child: Center(
        child: icon,
      ),
    );
  }
}

class Appbar extends StatelessWidget {
  final Widget start;
  final Widget mitte;
  final Widget ende;

  const Appbar(this.start, this.mitte, this.ende);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.5),
      padding: EdgeInsets.only(top: 24.0, left: 10.0, right: 10.0),
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        boxShadow: <BoxShadow>[
          BoxShadow(
            offset: Offset(0.0, 3.5),
            color: Colors.green,
          )
        ],
      ),
      child: Row(
        children: <Widget>[
          if (start != null) start,
          if (mitte != null)
            Expanded(
              child: mitte,
            ),
          if (ende != null) ende,
        ],
      ),
    );
  }
}

class BodyScroll extends Body {
  BodyScroll(
      List<Widget> elementListe, Widget top, ScrollController scrollController)
      : super(
          Stack(
            children: <Widget>[
              ListView(
                controller: scrollController,
                children: elementListe,
              ),
              if (top != null) top,
            ],
          ),
        );
}

class Body extends StatelessWidget {
  final Widget _inhalt;

  Body(this._inhalt);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: _inhalt,
      ),
    );
  }
}