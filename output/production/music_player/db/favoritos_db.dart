import 'dart:async';

import 'package:music_player/data/music_data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String favoritosTable = "favoritosTable";

class FavoritosDB {

  static final FavoritosDB _instance = FavoritosDB.internal();

  factory FavoritosDB() => _instance;

  FavoritosDB.internal();

  Database _db;

  Future<Database> get db async {
    if(_db != null){
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "favoritos.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $favoritosTable(idColumn INTEGER PRIMARY KEY, idDocumentColumn TEXT, autorColumn TEXT, nomeColumn TEXT, urlColumn TEXT,"
              "imagemColumn TEXT, durationColumn INTEGER)"
      );
    });
  }

  Future<MusicData> saveMusic(MusicData music) async {
    Database dbFavoritos = await db;
    dbFavoritos.insert(favoritosTable, music.toMapDB());
    return music;
  }

  Future<int> deleteMusic(String url) async {
    Database dbFavoritos = await db;
    return await dbFavoritos.delete(favoritosTable, where: "urlColumn = ?", whereArgs: [url]);
  }

  Future<List<MusicData>> getAllMusics() async {
    Database dbFavoritos = await db;
    List listMap = await dbFavoritos.rawQuery("SELECT * FROM $favoritosTable");
    print(listMap.toString());
    List<MusicData> listMusicas = List();
    for(Map m in listMap){
      listMusicas.add(MusicData.fromMap(m));
    }
    return listMusicas.reversed.toList();
  }

  Future close() async {
    Database dbFavoritos = await db;
    dbFavoritos.close();
  }

}