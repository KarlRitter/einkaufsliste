import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'container.dart';
import 'data.dart';

class Gruppenansicht extends StatefulWidget {
  final int gruppenid;
  Gruppenansicht(this.gruppenid);

  @override
  _GruppenansichtState createState() => _GruppenansichtState(gruppenid, Storage("/mitglieder$gruppenid.txt"));
}

class _GruppenansichtState extends State<Gruppenansicht> {
  String _state = "warten";
  bool _benachichtigungAn = false;
  Gruppe _gruppe;
  List<Mitglied> _mitglieder;
  Mitglied _ich;
  ScrollController _controller = ScrollController();
  String json = "";
  final Storage storage;

  _GruppenansichtState(gruppenid, this.storage) {
    // Data aus gespeichertem File
    storage.read().then((String data) {
      setState(() {
        if (data != "" && data != "Fehler") {
          json = data;
          print("DATA: " + data);
          _gruppe = mitgliederAusJson(data);
          _mitglieder = _gruppe.mitglieder;
          for (Mitglied mitglied in _mitglieder) {
            if (mitglied.ich) _ich = mitglied;
          }
        }
        _state = "start";
      });
    });

    // Daten aus DB und Updaten
    Future<String> futureJson = serverabfrage("get_mitglieder.php",
        arguments: {"id_gruppe": gruppenid.toString()});

    futureJson.then((newjson) {
      if (newjson != json) {
        storage.write(newjson);
        if (this.mounted) {
          setState(() {
            json = newjson;
            _gruppe = mitgliederAusJson(newjson);
            _mitglieder = _gruppe.mitglieder;
            for (Mitglied mitglied in _mitglieder) {
              if (mitglied.ich) _ich = mitglied;
            }
            _state = "start";
          });
        }
      }
    });
  }

  // Navigation
  void _hauptseite() {
    Navigator.popAndPushNamed(context, "/hauptseite.dart",
        arguments: _gruppe.id);
  }

  void _neuesMitglied() {
    Navigator.popAndPushNamed(context, "/QRhinzufuegen.dart",
        arguments: _gruppe.id);
  }

  void _menue({int id}) {
    Navigator.popAndPushNamed(context, "/menue.dart", arguments: id);
  }

  // Appbar
  // mitte
  Widget _buildGruppentext() {
    return Container(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
      child: Text(
        _gruppe.name,
        style: TextStyle(
          color: Colors.white,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w400,
          fontSize: 35.0,
          fontFamily: 'TimesNewRoman',
          letterSpacing: 1.5,
        ),
        softWrap: true,
      ),
    );
  }

  // Body
  // Scroll
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _neuesMitglied,
      child: Container(
        padding:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 4.0, bottom: 2.0),
        child: Row(
          children: <Widget>[
            Center(
              child: Icon(Icons.add, color: Colors.black, size: 25.0),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  "Hinzufügen",
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
          ],
        ),
      ),
    );
  }

  void _bearbeiten(int i) {
    setState(() {
      _state = "löschen" + i.toString();
    });
  }

  void _makeAdmin(int i) {
    serverabfrage("admin_wechseln.php", arguments: {"id_gruppe" : _gruppe.id.toString(), "name_mitglied" : _mitglieder[i].name});

    _mitglieder[i].admin = !_mitglieder[i].admin;

    setState(() {
      _mitglieder[i].admin = !_mitglieder[i].admin;
      json = jsonAusMitgliedern(_gruppe, _mitglieder);
      storage.write(json);
      print("DATA: update: " + json);
    });
  }

  void _verlassen() {
    String name = _ich.name;
    Future<String> kontrolleFuture = serverabfrage("mitglied_entfernen.php",
        arguments: {"id_gruppe": _gruppe.id.toString(), "name_mitglied": name});

    kontrolleFuture.then((kontrolle) {
      if (kontrolle == name) {
        _menue(id : _gruppe.id);
        storage.delete();
        Storage("/elemente" + _gruppe.id.toString() + ".txt").delete();
      }
    });
  }

  Widget _buildExitButton() {
    return Container(
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 2.0, bottom: 20.0),
      padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 4.0, bottom: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black45,
            offset: Offset(1.5, 3.5),
            blurRadius: 1.0,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: _verlassen,
        child: Text(
          "Gruppe verlassen",
          style: TextStyle(
            color: Colors.black,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w300,
            fontSize: 25.0,
            fontFamily: 'TimesNewRoman',
          ),
        ),
      ),
    );
  }

  List<Widget> _buildList() {
    List<Widget> list = [];

    list.add(BenachichtigungButton(() {
      _benachichtigungAn = !_benachichtigungAn;
    }, _benachichtigungAn));
    list.add(Divider(
      thickness: 5.0,
    ));

    if (_ich.admin) {
      list.add(_buildAddButton());
      list.add(Divider(
        thickness: 1.0,
      ));
    }

    list.add(Element(
        _ich, _mitglieder.indexOf(_ich), _bearbeiten, _ich.admin, _makeAdmin));
    list.add(Divider(
      thickness: 1.0,
    ));

    for (int i = 0; i < _mitglieder.length; i++) {
      if (!_mitglieder[i].ich) {
        list.add(
            Element(_mitglieder[i], i, _bearbeiten, _ich.admin, _makeAdmin));
        list.add(Divider(
          thickness: 1.0,
        ));
      }
    }

    list.add(_buildExitButton());

    return list;
  }

  // top
  void _startState() {
    if (_state != "start") {
      setState(() {
        _state = "start";
      });
    }
  }

  void _entfernen() {
    int index = int.parse(_state.split("löschen")[1]);
    String name = _mitglieder[index].name;
    Future<String> kontrolleFuture = serverabfrage("mitglied_entfernen.php",
        arguments: {"id_gruppe": _gruppe.id.toString(), "name_mitglied": name});

    _mitglieder.removeAt(index);
    _startState();

    kontrolleFuture.then((kontrolle) {
      if (kontrolle == name) {
        json = jsonAusMitgliedern(_gruppe, _mitglieder);
        storage.write(json);
        print("DATA: update: " + json);
      }
    });
  }

  Widget _buildPopup() {
    if (_state.startsWith("löschen")) {
      return Center(
        child: SizedBox(
          height: 150.0,
          width: 350.0,
          child: Container(
              padding: EdgeInsets.all(10.0),
              color: Color.fromRGBO(200, 200, 200, 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Willst du " +
                        _mitglieder[int.parse(_state.split("löschen")[1])]
                            .name +
                        " wirklich aus der Gruppe entfernen?",
                    style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w300,
                        fontSize: 25.0,
                        fontFamily: 'TimesNewRoman'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: _startState,
                        child: Container(
                          color: Colors.red,
                          child: SizedBox(
                            width: 100.0,
                            height: 40.0,
                            child: Icon(Icons.clear,
                                color: Colors.black, size: 25.0),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _entfernen,
                        child: Container(
                          color: Colors.green,
                          child: SizedBox(
                            width: 100.0,
                            height: 40.0,
                            child: Icon(Icons.check,
                                color: Colors.black, size: 25.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ),
      );
    } else
      return null;
  }

  // allgemein
  Future<bool> _onWillPop() {
    if (_state == "start")
      _hauptseite();
    else
      _startState();
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    if (_state == "warten") {
      return Column(
        children: <Widget>[
          Appbar(null, null, null),
          Body(Container()),
        ],
      );
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Column(
        children: <Widget>[
          Appbar(buildBackbutton(_hauptseite), _buildGruppentext(), null),
          BodyScroll(_buildList(), _buildPopup(), _controller),
        ],
      ),
    );
  }
}

class BenachichtigungButton extends StatefulWidget {
  final Function aendern;
  final bool startState;

  BenachichtigungButton(this.aendern, this.startState);

  @override
  _BenachichtigungButtonState createState() =>
      _BenachichtigungButtonState(startState);
}

class _BenachichtigungButtonState extends State<BenachichtigungButton> {
  bool _an;

  _BenachichtigungButtonState(this._an);

  void _aendernAufrufen() {
    widget.aendern();
    setState(() {
      _an = !_an;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _aendernAufrufen,
      child: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.only(right: 10.0, top: 5.0, bottom: 5.0),
                child: Text(
                  _an
                      ? "Benachichtigung ausschalten"
                      : "Benachichtigung einschalten",
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
            Center(
              child: Icon(
                _an ? Icons.check : Icons.check_box_outline_blank,
                color: Colors.black,
                size: 25.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Element extends StatelessWidget {
  final Mitglied _mitglied;
  final int _index;
  final Function _bearbeiten;
  final bool _vonAdmin;
  final Function _makeAdmin;
  double _offset = 0.0;

  Element(this._mitglied, this._index, this._bearbeiten, this._vonAdmin,
      this._makeAdmin);

  void _dragUpdate(DragUpdateDetails details) {
    _offset += details.delta.dx;
  }

  void _dragEnde(DragEndDetails details) {
    if (-70 >= _offset || _offset >= 70)
      _bearbeitenAufrufen();
    else
      _offset = 0.0;
  }

  void _dragCancel() {
    if (-70 >= _offset || _offset >= 70)
      _bearbeitenAufrufen();
    else
      _offset = 0.0;
  }

  void _bearbeitenAufrufen() {
    _bearbeiten(_index);
  }

  void _makeAdminAufrufen() {
    _makeAdmin(_index);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _dragUpdate,
      onHorizontalDragEnd: (_vonAdmin && !_mitglied.ich) ? _dragEnde : null,
      onHorizontalDragCancel:
          (_vonAdmin && !_mitglied.ich) ? _dragCancel : null,
      child: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                _mitglied.ich ? "Ich" : _mitglied.name,
                style: TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w300,
                  fontSize: 30.0,
                  fontFamily: 'TimesNewRoman',
                ),
              ),
            ),
            if (_vonAdmin && !_mitglied.ich)
              IconButtonBody(
                  _makeAdminAufrufen,
                  _mitglied.admin ? Icons.star : Icons.star_border,
                  Colors.lightGreen),
          ],
        ),
      ),
    );
  }
}
