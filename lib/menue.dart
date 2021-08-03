import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'container.dart';
import 'data.dart';

class Menue extends StatefulWidget {
  final int entfernID;

  Menue ({this.entfernID});

  @override
  _MenueState createState() => _MenueState(Storage("/gruppen.txt"));
}

class _MenueState extends State<Menue> {
  //String _state = "warten";
  BuildContext _context;
  ScrollController _controller = ScrollController();
  List<Gruppe> _gruppen = [];
  String json = "";
  final Storage storage;

  _MenueState(this.storage) {
    // Data aus gespeichertem File
    storage.read().then((String data) {
      setState(() {
        if (data != "" && data != "Fehler") {
          json = data;
          print("DATA: " + data);
          _gruppen = gruppenlisteAusJson(data);
          if (widget.entfernID != null) {
            _gruppen = removeGruppe(_gruppen, widget.entfernID);
            print("DATA: delete: " + widget.entfernID.toString());
            json = jsonAusGruppenliste(_gruppen);
            print("DATA: " + json);
          }
        }
      });
    });

    // Daten aus DB und Update
    serverabfrage("get_gruppen.php").then((newjson) {
      if (json != newjson) {
        storage.write(newjson);
        if (this.mounted) {
          json = newjson;
          _gruppen = gruppenlisteAusJson(newjson);
          setState(() {
            //_state = "start";
          });
        }
      }
    });

  }

  // Navigation
  void _hauptseite(int i) {
    Navigator.popAndPushNamed(_context, "/hauptseite.dart",
        arguments: _gruppen[i].id);
  }

  void _neueGruppe() {
    Navigator.popAndPushNamed(_context, "/gruppenansichtNeu.dart");
  }

  // Appbar
  // mitte
  Widget _buildMenueText() {
    return Center(
      child: Container(
        padding:
            EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
        child: Text(
          "Einkaufsliste",
          style: TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w400,
            fontSize: 35.0,
            fontFamily: 'TimesNewRoman',
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // Body
  // Scroll
  List<Widget> _buildList() {
    List<Widget> list = [];

    for (int i = 0; i < _gruppen.length; i++) {
      list.add(Element(_gruppen[i], _hauptseite, i));
      list.add(Divider(
        thickness: 1.0,
      ));
    }
    if (list.length >= 1) list.removeLast();

    return list;
  }

  // top
  Widget _buildAddButton() {
    return Positioned(
      bottom: 20.0,
      right: 10.0,
      child: GestureDetector(
        onTap: _neueGruppe,
        child: Container(
            height: 80.0,
            width: 80.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(90.0),
              color: Colors.lightGreen,
            ),
            child: Icon(Icons.add, size: 35.0, color: Colors.white)),
      ),
    );
  }

  // allgemein
  Future<bool> _onWillPop() {
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Column(
        children: <Widget>[
          Appbar(null, _buildMenueText(), null),
          BodyScroll(_buildList(), _buildAddButton(), _controller),
        ],
      ),
    );
  }
}

class Element extends StatelessWidget {
  final Gruppe _gruppe;
  final Function _open;
  final int _index;

  Element(this._gruppe, this._open, this._index);

  void _openAufrufen() {
    _open(_index);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openAufrufen,
      child: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Text(
          _gruppe.name,
          style: TextStyle(
            color: Colors.black,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w300,
            fontSize: 30.0,
            fontFamily: 'TimesNewRoman',
          ),
        ),
      ),
    );
  }
}
