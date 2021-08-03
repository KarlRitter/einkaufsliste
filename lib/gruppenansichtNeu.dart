import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'container.dart';
import 'data.dart';
import 'laden.dart';

class GruppenansichtNeu extends StatelessWidget {
  BuildContext _context;
  String _gruppenname = "";
  String _name = "";

  // Navigation
  void _menue() {
    Navigator.popAndPushNamed(_context, "/menue.dart");
  }

  void _QRneu() {
    Navigator.popAndPushNamed(_context, "/QRneu.dart");
  }

  void _gruppenansicht(int gruppenid) {
    LadenState.pop("/gruppenansicht.dart", gruppenid);
  }

  void _laden() {
    Navigator.popAndPushNamed(_context, "/laden.dart");
  }

  // Appbar
  // mitte
  Widget _buildAppbarText() {
    return Container(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
      child: Text(
        "neue Gruppe",
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
  void _finish(String name, String label) {
    if (label == "Gruppenname")
      _gruppenname = name;
    else
      _name = name;
  }

  Future<String> _do() async {
    String gruppenid = await serverabfrage("gruppe_erstellen.php",
        arguments: {"name_gruppe": _gruppenname, "name_mitglied": _name});

    // Mitglieder
    String jsonM = await serverabfrage("get_mitglieder.php",
        arguments: {"id_gruppe": gruppenid.toString()});

    Storage mitgliederStorage = Storage("/mitglieder$gruppenid.txt");

    mitgliederStorage.write(jsonM);

    // Elemente
    String jsonE = await serverabfrage("get_elemente.php",
        arguments: {"id_gruppe": gruppenid.toString()});

    Storage elementeStorage = Storage("/elemente$gruppenid.txt");

    elementeStorage.write(jsonE);

    // Gruppen

    Storage gruppenStorage = Storage("/gruppen.txt");
    String jsonG = await serverabfrage("get_gruppen.php");
    gruppenStorage.write(jsonG);

    return gruppenid;
  }

  void _erstellen() {
    if (_name != "" && _gruppenname != "") {
      _laden();
      _do().then((id) {
        _gruppenansicht(int.parse(id));
      });
    }
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        Element(_finish, "Gruppenname"),
        Element(_finish, "dein Name"),
        Container(
            padding: EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: _QRneu,
                    child: Container(
                      margin: EdgeInsets.only(left: 10.0, right: 10.0),
                      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      color: Colors.lightGreen,
                      child: Center(
                        child: Text(
                          "Gruppe beitreten",
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w300,
                            fontSize: 20.0,
                            fontFamily: 'TimesNewRoman',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _erstellen,
                    child: Container(
                      margin: EdgeInsets.only(left: 10.0, right: 10.0),
                      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      color: Colors.lightGreen,
                      child: Center(
                        child: Text(
                          "Gruppe erstellen",
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w300,
                            fontSize: 20.0,
                            fontFamily: 'TimesNewRoman',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }

  // allgemein
  Future<bool> _onWillPop() {
    _menue();
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Column(
        children: <Widget>[
          Appbar(buildBackbutton(_menue), _buildAppbarText(), null),
          Body(_buildBody()),
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
    _finish(_name, _label);
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
                autofocus: false,
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
