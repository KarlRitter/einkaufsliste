import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'container.dart';
import 'data.dart';

class QRneu extends StatefulWidget {
  @override
  _QRneuState createState() => _QRneuState();
}

class _QRneuState extends State<QRneu> {
  final GlobalKey qrKey = new GlobalKey(debugLabel: 'QR-Scanner');
  String _state = "start";
  String _name = "";

  // Navigation
  void _gruppenansichtNeu() {
    Navigator.popAndPushNamed(context, "/gruppenansichtNeu.dart");
  }

  void _gruppenansicht(int gruppenid) {
    Navigator.popAndPushNamed(context, "/gruppenansicht.dart",
        arguments: gruppenid);
  }

  // Appbar
  // mitte
  Widget _buildAppbarText() {
    return Container(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
      child: Text(
        "QR-Code scannen",
        style: TextStyle(
          color: Colors.white,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w400,
          fontSize: 35.0,
          fontFamily: 'TimesNewRoman',
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // Body
  void _nameAendern(String name) {
    _name = name;
  }

  void _beitreten() {
    if (_name != "") {
      Future<String> gruppenidFuture = serverabfrage("mitglied_erstellen.php",
          arguments: {"id_gruppe": _state, "name_mitglied": _name});

      gruppenidFuture.then((gruppenid) {
        if (gruppenid == _state) {
          // Mitglieder
          Future<String> futureJsonM = serverabfrage("get_mitglieder.php",
              arguments: {"id_gruppe": gruppenid.toString()});

          Storage mitgliederStorage = Storage("/mitglieder$gruppenid.txt");

          futureJsonM.then((jsonM) {
            mitgliederStorage.write(jsonM);
            _gruppenansicht(int.parse(gruppenid));
          });

          // Elemente
          Future<String> futureJsonE = serverabfrage("get_elemente.php",
              arguments: {"id_gruppe": gruppenid.toString()});

          Storage elementeStorage = Storage("/elemente$gruppenid.txt");

          futureJsonE.then((jsonE) {
            elementeStorage.write(jsonE);
          });

          // Gruppen

          Storage gruppenStorage = Storage("/gruppen.txt");
          serverabfrage("get_gruppen.php").then((jsonG) {
            gruppenStorage.write(jsonG);
          });
        }
      });
    }
  }

  Widget _buildPopup() {
    return SizedBox(
      height: 200.0,
      child: Container(
        margin: EdgeInsets.only(top: 40.0),
        padding: EdgeInsets.all(10.0),
        color: Colors.grey,
        child: Column(
          children: <Widget>[
            Element(_nameAendern, "Name"),
            Expanded(
              child: GestureDetector(
                onTap: _beitreten,
                child: Container(
                  margin: EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 10.0, bottom: 5.0),
                  color: Colors.lightGreen,
                  child: Center(
                    child: Text(
                      "Gruppe beitreten",
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w300,
                        fontSize: 25.0,
                        fontFamily: 'TimesNewRoman',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // QR-Auswertung
  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) {
      print(scanData);
      setState(() {
        _state = scanData;
      });
    });
  }

  // allgemein
  Future<bool> _onWillPop() {
    if (_state == "start")
      _gruppenansichtNeu();
    else
      setState(() {
        _state = "start";
      });
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Column(
        children: <Widget>[
          Appbar(buildBackbutton(_gruppenansichtNeu), _buildAppbarText(), null),
          Expanded(
            child: Stack(
              children: <Widget>[
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
                if (_state != "start") _buildPopup(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Element extends StatelessWidget {
  Function _finish;
  String _label;
  String _name = "";
  TextEditingController _controller;
  FocusNode _focusNode = FocusNode();

  Element(this._finish, this._label) {
    _controller = TextEditingController(text: _name);
  }

  void _finishAufrufen() {
    _finish(_name);
  }

  void _closeKeyboard() {
    _name = _controller.text;
    _focusNode.unfocus();
  }

  void _onChange(String s) {
    _name = _controller.text;
    _finishAufrufen();
  }

  void _submit(String name) {
    _name = name;
    _finishAufrufen();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 5.0),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 10.0, right: 10.0),
            child: Text(
              _label + ":",
              style: TextStyle(
                color: Colors.black,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w300,
                fontSize: 25.0,
                fontFamily: 'TimesNewRoman',
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(right: 10.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
              child: EditableText(
                autofocus: true,
                onChanged: _onChange,
                onSubmitted: _submit,
                onEditingComplete: _closeKeyboard,
                backgroundCursorColor: Colors.white,
                controller: _controller,
                cursorColor: Colors.black,
                focusNode: _focusNode,
                style: TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w300,
                  fontSize: 30.0,
                  fontFamily: 'TimesNewRoman',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
