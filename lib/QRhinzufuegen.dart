import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'container.dart';

class QRhinzufuegen extends StatelessWidget {
  BuildContext _context;
  final int _gruppenid;

  QRhinzufuegen(this._gruppenid);

  // Navigation
  void _goBack() {
    Navigator.pushNamed(_context, "/gruppenansicht.dart", arguments: this._gruppenid);
  }

  // Appbar
  // start
  Widget _buildBackbutton() {
    return IconButtonAppbar(_goBack, Icons.arrow_back_ios);
  }

  // mitte
  Widget _buildQRCodeText() {
    return Container(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
      child: Text(
        "QR-Code",
        style: TextStyle(
          color: Colors.white,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w400,
          fontSize: 35.0,
          fontFamily: 'TimesNewRoman',
          letterSpacing: 1.5,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Body
  Widget _buildimage() {
    return Center(
      child: Container(
        child: QrImage(
          data: _gruppenid.toString(),
          backgroundColor: Colors.grey,
          size: 300,
        ),
      ),
    );
  }

  // allgemein
  Future<bool> _onWillPop() {
    _goBack();
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    _context = context;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        child: Column(
          children: <Widget>[
            Appbar(_buildBackbutton(), _buildQRCodeText(), null),
            Body(_buildimage()),
          ],
        ),
      ),
    );
  }
}
