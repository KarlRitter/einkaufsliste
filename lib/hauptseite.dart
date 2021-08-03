import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'container.dart';
import 'data.dart';

class Hauptseite extends StatefulWidget {
  final int gruppenid;

  Hauptseite(this.gruppenid);

  @override
  _HauptseiteState createState() => _HauptseiteState(gruppenid, Storage("/elemente$gruppenid.txt"));
}

class _HauptseiteState extends State<Hauptseite> {
  String _state = "warten";
  Gruppe _gruppe;
  List<ElementData> _elements;
  bool _alleGehakt = false;
  ScrollController _scrollController = ScrollController();
  String json = "";
  final Storage storage;

  _HauptseiteState(int gruppenid, this.storage) {
    // Data aus gespeichertem File
    storage.read().then((String data) {
      if (_gruppe != null) data = updateJson(data);
      setState(() {
        if (data != "" && data != "Fehler") {
          json = data;
          print("DATA: " + data);
          _gruppe = elementeAusJson(data);
          _elements = _gruppe.elements;
          _state = "start";
        }
      });
    });

    // Daten aus DB und Update
    Future<String> futureJson = serverabfrage("get_elemente.php",
        arguments: {"id_gruppe": gruppenid.toString()});

    futureJson.then((newjson) {
      if (_gruppe != null) newjson = updateJson(newjson);
      if (newjson != json) {
        storage.write(newjson);
        if (this.mounted) {
          setState(() {
            _gruppe = elementeAusJson(newjson);
            json = newjson;
            _elements = _gruppe.elements;
            _state = "start";
          });
        }
      }
    });
  }

  String updateJson(String newjson) {
    Gruppe newgruppe = elementeAusJson(newjson);
    for (ElementData element in _gruppe.elements) {
    for (ElementData newelement in newgruppe.elements) {
    if (element.name == newelement.name) {
    newelement.gekauft = element.gekauft;
    break;
    }
    }
    }
    return jsonAusElementen(newgruppe, newgruppe.elements);
  }

  // Navigation
  void _menuansicht() {
    Navigator.popAndPushNamed(context, "/menue.dart");
  }

  void _gruppenansicht() {
    Navigator.popAndPushNamed(context, "/gruppenansicht.dart",
        arguments: _gruppe.id);
  }

  // Appbar
  // start
  Widget _buildMenubutton() {
    return IconButtonAppbar(_menuansicht, Icons.menu);
  }

  void _goBack() {
    setState(() {
      _state = "start";
      _alleGehakt = false;
      for (ElementData element in _elements) {
        element.gehakt = false;
      }
    });
  }

  //mitte
  Widget _buildGruppentext() {
    return GestureDetector(
      onTap: _gruppenansicht,
      child: Container(
        padding:
            EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
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
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildLoeschtext(String startState) {
    void alleHaken() {
      setState(() {
        _alleGehakt = !_alleGehakt;
        for (ElementData element in _elements) {
          element.gehakt = _alleGehakt;
        }
      });
    }

    return Loeschtext(alleHaken, _alleGehakt);
  }

  //ende
  Widget _buildForwardbutton() {
    return IconButtonAppbar(_gruppenansicht, Icons.arrow_forward_ios);
  }

  void loeschen() {
    List <String> deleted = [];

    setState(() {
      for (int i = _elements.length - 1; i >= 0; i--) {
        if (_elements[i].gehakt) {
          deleted.add(_elements.removeAt(i).name);
        }
      }
      _alleGehakt = false;
      _state = "start";

      storage.write(jsonAusElementen(_gruppe, _gruppe.elements));
      serverabfrage("elemente_entfernen.php", arguments: {
        "id_gruppe": _gruppe.id.toString(),
        "name_elemente": deleted.toString()
      });
    });
  }

  Widget _buildLoeschbutton() {
    return IconButtonAppbar(loeschen, Icons.delete_outline);
  }

  // Body
  // Scroll
  List<Widget> addBottomSpace(List<Widget> list, double thickness) {
    list.add(
      Container(
        height: thickness,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
      ),
    );
    return list;
  }

  void _kaufen(int i) {
    setState(() {
      _elements[i].gekauft = !_elements[i].gekauft;
      storage.write(jsonAusElementen(_gruppe, _gruppe.elements));
    });
  }

  void _openBearbeiten(ElementData data, int i) {
    print("bearbeiten");
    setState(() {
      _state = "bearbeiten" + i.toString();
      _scrollController.jumpTo(51.0 * (i - 5) - 3.0);
    });
  }

  void _openLoeschen(int i) {
    print("löschen");
    setState(() {
      _elements[i].gehakt = true;
      _state = "löschen";
    });
  }

  void _haken(int i) {
    setState(() {
      _elements[i].gehakt = !_elements[i].gehakt;
      _alleGehakt = true;
      for (ElementData element in _elements) {
        if (element.gehakt != true) _alleGehakt = false;
      }
    });
  }

  List<Widget> _buildListIJ(int i, int j, String element) {
    List<Widget> elements = [];
    for (i = i; i < j; i++) {
      if (element == "start") {
        elements.add(ElementStart(
            _elements[i], _openBearbeiten, _kaufen, _openLoeschen, i));
      } else if (element == "löschen") {
        elements.add(ElementLoeschen(_elements[i], _haken, i));
      }
      elements.add(Divider(
        thickness: 1.0,
      ));
    }
    if (elements.length >= 1) elements.removeLast();

    return elements;
  }

  List<Widget> _buildNormalList(String element) {
    List<Widget> list = _buildListIJ(0, _elements.length, element);
    list = addBottomSpace(list, 105.0);
    return list;
  }

  void _bearbeiten(String startName, int i) {
    bool vorhanden = false;
    for (ElementData element in _elements) {
      if(element.name == _elements[i].name && element != _elements[i]) {
        vorhanden = true;
        break;
      }
    }
    if (vorhanden) {
      if (startName == "") _elements.removeAt(i);
      else _elements[i].name = startName;
    } else {
      serverabfrage("element_bearbeiten.php", arguments: {
        "id_gruppe": _gruppe.id.toString(),
        "name_element_davor": startName,
        "name_element_neu": _elements[i].name
      });

      if (_elements[i].name == "") _elements.removeAt(i);

      storage.write(jsonAusElementen(_gruppe, _elements));
    }

    setState(() {
      _state = "start";
    });
  }

  List<Widget> _buildListBearbeiten(int i) {
    List<Widget> list = _buildListIJ(0, i + 1, "start");
    if (list.length >= 1) list.removeLast();

    list.add(ElementNeu(_bearbeiten, _elements[i], i));

    if (i < _elements.length - 1) {
      list.add(Divider(
        thickness: 1.0,
      ));
      list.addAll(_buildListIJ(i + 1, _elements.length, "start"));
    }

    list = addBottomSpace(
        list,
        51.0 * (i - _elements.length + 6) + 32.0 > 0
            ? 51.0 * (i - _elements.length + 6) + 32.0
            : 15.0);
    return list;
  }

  // top
  void _openAdd() {
    print("add");

    setState(() {
      _elements.add(ElementData("", false, false));
      _state = "bearbeiten" + (_elements.length-1).toString();
      _scrollController.jumpTo(51.0 * (_elements.length - 5) - 3.0);
    });
  }

  Widget _buildAddbutton() {
    return Positioned(
      bottom: 20.0,
      right: 10.0,
      child: GestureDetector(
        onTap: _openAdd,
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
    if (_state != "start")
      _goBack();
    else
      _menuansicht();
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
          Appbar(
            _state == "löschen" ? buildBackbutton(_goBack) : _buildMenubutton(),
            _state == "löschen"
                ? _buildLoeschtext(_state)
                : _buildGruppentext(),
            _state == "löschen" ? _buildLoeschbutton() : _buildForwardbutton(),
          ),
          if (_state == "start")
            BodyScroll(
                _buildNormalList(_state), _buildAddbutton(), _scrollController),
          if (_state == "löschen")
            BodyScroll(_buildNormalList(_state), null, _scrollController),
          if (_state.startsWith("bearbeiten"))
            BodyScroll(_buildListBearbeiten(int.parse(_state.split("n")[1])),
                null, _scrollController),
        ],
      ),
    );
  }
}

class Loeschtext extends StatelessWidget {
  final Function _alleHaken;
  final bool _gehakt;

  Loeschtext(this._alleHaken, this._gehakt);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _alleHaken,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _gehakt
              ? Icon(Icons.check, size: 25.0, color: Colors.white)
              : Icon(Icons.check_box_outline_blank,
                  size: 25.0, color: Colors.white),
          Container(
            padding:
                EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
            child: Text(
              "alle",
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
        ],
      ),
    );
  }
}

class ElementStart extends StatelessWidget {
  final ElementData _elementData;
  final Function _bearbeiten;
  final Function _kaufen;
  final Function _loeschen;
  final int _index;

  ElementStart(this._elementData, this._bearbeiten, this._kaufen,
      this._loeschen, this._index);

  void _bearbeitenAufrufen() {
    _bearbeiten(_elementData, _index);
  }

  void _kaufenAufrufen() {
    _kaufen(_index);
  }

  void _loeschenAufrufen() {
    _loeschen(_index);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: _kaufenAufrufen,
            onLongPress: _loeschenAufrufen,
            child: Container(
              padding: EdgeInsets.only(right: 10.0),
              child: Text(
                _elementData.name,
                style: TextStyle(
                  color: _elementData.gekauft
                      ? Color.fromRGBO(80, 200, 80, 1)
                      : Colors.black,
                  decoration: TextDecoration.none,
                  fontWeight:
                      _elementData.gekauft ? FontWeight.w400 : FontWeight.w300,
                  fontSize: 30.0,
                  fontFamily: 'TimesNewRoman',
                ),
              ),
            ),
          ),
        ),
        IconButtonBody(_bearbeitenAufrufen, Icons.create, Colors.lightBlue)
      ],
    );
  }
}

class ElementLoeschen extends StatelessWidget {
  final ElementData _elementData;
  final Function _haken;
  final int _index;

  ElementLoeschen(this._elementData, this._haken, this._index);

  void _hakenAufruf() {
    _haken(_index);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _hakenAufruf,
      child: Row(
        children: <Widget>[
          _elementData.gehakt
              ? Icon(Icons.check, size: 25.0, color: Colors.black)
              : Icon(Icons.check_box_outline_blank,
                  size: 25.0, color: Colors.black),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                _elementData.name,
                style: TextStyle(
                  color: _elementData.gekauft
                      ? Color.fromRGBO(80, 200, 80, 1)
                      : Colors.black,
                  decoration: TextDecoration.none,
                  fontWeight:
                      _elementData.gekauft ? FontWeight.w400 : FontWeight.w300,
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

class ElementNeu extends StatelessWidget {
  final Function _finish;
  ElementData _elementData;
  String _nameStart;
  final int _index;
  TextEditingController _controller;
  FocusNode _focusNode = FocusNode();

  ElementNeu(this._finish, this._elementData, this._index) {
    _nameStart = _elementData.name;
    _controller = TextEditingController(text: _elementData.name);
  }

  void _finishAufrufen() {
    _elementData.name = _controller.text;
    if (_elementData.name == "") _elementData.name = _nameStart;
    _finish(_nameStart, _index);
  }

  void _closeKeyboard() {
    _elementData.name = _controller.text;
    _focusNode.unfocus();
  }

  void onChange(String s) {
    _elementData.name = _controller.text;
  }

  void _submit(String name) {
    _elementData.name = name;
    _finishAufrufen();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
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
        IconButtonBody(_finishAufrufen, Icons.send, Colors.lightBlue),
      ],
    );
  }
}
