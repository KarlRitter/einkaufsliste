import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'menue.dart';
import 'hauptseite.dart';
import 'gruppenansicht.dart';
import 'gruppenansichtNeu.dart';
import 'QRhinzufuegen.dart';
import 'QRneu.dart';
import 'laden.dart';
import 'test.dart';
import 'data.dart';

void main() => runApp(Einkaufsliste());

class Einkaufsliste extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/menue.dart",
      routes: {
        "/menue.dart" : (context) => Menue(entfernID: ModalRoute.of(context).settings.arguments),
        "/hauptseite.dart" : (context) => Hauptseite(ModalRoute.of(context).settings.arguments),
        "/gruppenansicht.dart" : (context) => Gruppenansicht(ModalRoute.of(context).settings.arguments),
        "/gruppenansichtNeu.dart" : (context) => GruppenansichtNeu(),
        "/QRhinzufuegen.dart" : (context) => QRhinzufuegen(ModalRoute.of(context).settings.arguments),
        "/QRneu.dart" : (context) => QRneu(),
        "/laden.dart" : (context) => Laden(),
        "/test.dart" : (context) => Test(),
      },
      title: "Einkaufsliste"
    );
  }
}
