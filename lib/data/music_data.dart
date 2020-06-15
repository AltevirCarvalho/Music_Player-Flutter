import 'package:cloud_firestore/cloud_firestore.dart';

class MusicData {
  String id, autor, nome, imagem, data, url;
  int num, duration, idDB;

  MusicData();

  MusicData.fromDocument(DocumentSnapshot snapshot){
    id = snapshot.documentID;
    autor = snapshot.data['autor'];
    nome = snapshot.data['nome'];
    data = snapshot.data['data'];
    url = snapshot.data['url'];
    imagem = snapshot.data['imagem'];
    num = snapshot.data['num'];
    duration = snapshot.data['duration'];
  }

  MusicData.fromMap(Map map){
    idDB = map['idColumn'];
    autor = map['autorColumn'];
    id = map['idDocumentColumn'];
    nome = map['nomeColumn'];
    url = map['urlColumn'];
    imagem = map['imagemColumn'];
    duration = map['durationColumn'];
  }

  Map toMapDB() {
    Map<String, dynamic> map = {
      'autorColumn': autor,
      'idDocumentColumn': id,
      'nomeColumn': nome,
      'urlColumn': url,
      'imagemColumn': imagem,
      'durationColumn': duration,
    };
    if(idDB != null){
      map['idColumn'] = idDB;
    }
    return map;
  }
}