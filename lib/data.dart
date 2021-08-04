import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:path_provider/path_provider.dart';

class Gruppe {
  final int id;
  final String name;
  List<Mitglied> mitglieder;
  List<ElementData> elements;

  Gruppe(this.id, this.name, this.mitglieder, this.elements);

  Map<String, dynamic> toJson() {
    List<Map> jsonM = [];
    for (Mitglied mitglied in mitglieder) {
      jsonM.add(mitglied.toJson());
    }

    List<Map> jsonE = [];
    for (ElementData element in elements) {
      jsonE.add(element.toJson());
    }

    return {
      'name': name,
      'id': id,
      'mitglieder' : jsonM,
      'elements' : jsonE
    };
  }

}

class Mitglied {
  final String name;
  bool admin;
  final bool ich;

  Mitglied(this.name, this.admin, this.ich);

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'admin': admin,
        'ich' : ich
      };
}

class ElementData {
  String name;
  bool gekauft;
  bool gehakt;

  ElementData(this.name, this.gekauft, this.gehakt);

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'gekauft': gekauft
      };
}

class Storage {
  final String filename;

  Storage(this.filename);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File(path + filename);
  }

  Future<String> read() async {
    try {
      final file = await _localFile;
      print("read: " + file.toString());
      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error
      return "Fehler";
    }
  }

  Future<File> write(String json) async {
    final file = await _localFile;
    print("write: " + file.toString() + ": "+ json);
    // Write the file
    return file.writeAsString(json);
  }

  Future<void> delete() async {
    final File file = await _localFile;
    print("delete: " + file.toString());
    try {
      file.delete();
    } catch (e) {
      print("Fehler beim Löschen");
    }
  }
}

Future<String> serverabfrage(String seite, {Map<String, dynamic> arguments}) async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  AndroidDeviceInfo build = await deviceInfoPlugin.androidInfo;
  String buildID = build.id;
  String androidID = build.androidId;

  Map<String, dynamic> map = {'android_id': buildID+androidID};
  if (arguments != null) map.addAll(arguments);
  print("Anfrage wir geschickt: " + seite + "; " + map.toString());
  var url = 'http://192.168.0.100/einkaufsliste/' + seite;
  var response = await http.post(url, body: map);


  print('Response status: ${response.statusCode}');
  print("SERVER: "+response.body);
  return response.body;
}

List<Gruppe> kompletteListeAusJson(String json) {
  // Gruppen
  List<Gruppe> gruppenliste = [];
  List<dynamic> gruppenlistelisteJSON = jsonDecode(json);

  // jede Gruppe
  for (Map<String, dynamic> map in gruppenlistelisteJSON) {
    // Gruppenname + id
    String gruppenname = map["name"];
    int id = map["id"];

    // Mitglieder
    List<dynamic> mitgliederlisteJSON = map["mitglieder"];
    List<Mitglied> mitgliederliste = [];

    // jedes Mitglied
    for (Map<String, dynamic> mitglied in mitgliederlisteJSON) {
      String name = mitglied["name"];
      bool admin = mitglied["admin"];
      bool ich = mitglied["ich"];

      mitgliederliste.add(Mitglied(name, admin, ich));
    }

    // Elemente
    List<dynamic> elementlisteJSON = map["elements"];
    List<ElementData> elementliste = [];

    // jedes Element
    for (Map<String, dynamic> element in elementlisteJSON) {
      String name = element["name"];
      bool gekauft = element["gekauft"];
      bool gehakt = false;

      elementliste.add(ElementData(name, gekauft, gehakt));
    }

    gruppenliste.add(Gruppe(id, gruppenname, mitgliederliste, elementliste));
  }

  return gruppenliste;
}

List<Gruppe> gruppenlisteAusJson(String json) {
  // Gruppen
  List<Gruppe> gruppenliste = [];
  List<dynamic> gruppenlistelisteJSON = jsonDecode(json);

  // jede Gruppe
  for (Map<String, dynamic> map in gruppenlistelisteJSON) {
    // Gruppenname + id
    String gruppenname = map["name"];
    int id = map["id"];

    gruppenliste.add(Gruppe(id, gruppenname, [], []));
  }

  return gruppenliste;
}

List<Gruppe> removeGruppe(List<Gruppe> gruppen, int id) {
  for (int i = gruppen.length-1; i >= 0; i--) {
    if (gruppen[i].id == id) gruppen.removeAt(i);
  }
  return gruppen;
}

String jsonAusGruppenliste(List<Gruppe> gruppen) {
  List<Map> jsonG = [];
  for (Gruppe gruppe in gruppen) {
    Map<String, dynamic> gruppeJson = gruppe.toJson();
    jsonG.add({"name" : gruppeJson["name"], "id" : gruppeJson["id"]});
  }
  return jsonEncode(jsonG);
}

Gruppe elementeAusJson(String json) {
  // Gruppe
  Map<String, dynamic> gruppeJSON = jsonDecode(json);
  // Gruppenname + id
  String gruppenname = gruppeJSON["name"];
  int id = gruppeJSON["id"];

  // Elemente
  List<dynamic> elementlisteJSON = gruppeJSON["elements"];
  List<ElementData> elementliste = [];

  // jedes Element
  for (Map<String, dynamic> element in elementlisteJSON) {
    String name = element["name"];
    bool gekauft = element["gekauft"];
    bool gehakt = false;

    elementliste.add(ElementData(name, gekauft, gehakt));
  }

  return Gruppe(id, gruppenname, [], elementliste);
}

String jsonAusElementen(Gruppe gruppe, List<ElementData> elemente) {
  gruppe.elements = elemente;

  Map<String, dynamic> map= gruppe.toJson();
  map.remove("mitglieder");

  return jsonEncode(map);
}

Gruppe mitgliederAusJson(String json) {
  // Gruppe
  Map<String, dynamic> gruppeJSON = jsonDecode(json);
  // Gruppenname + id
  String gruppenname = gruppeJSON["name"];
  int id = gruppeJSON["id"];

  // Mitglieder
  List<dynamic> mitgliederlisteJSON = gruppeJSON["mitglieder"];
  List<Mitglied> mitgliederliste = [];

  // jedes Mitglied
  for (Map<String, dynamic> mitglied in mitgliederlisteJSON) {
    String name = mitglied["name"];
    bool admin = mitglied["admin"];
    bool ich = mitglied["ich"];

    mitgliederliste.add(Mitglied(name, admin, ich));
  }

  return Gruppe(id, gruppenname, mitgliederliste, []);
}

String jsonAusMitgliedern(Gruppe gruppe, List<Mitglied> mitglieder) {
  gruppe.mitglieder = mitglieder;

  Map<String, dynamic> map= gruppe.toJson();
  map.remove("elements");

  return jsonEncode(map);
}