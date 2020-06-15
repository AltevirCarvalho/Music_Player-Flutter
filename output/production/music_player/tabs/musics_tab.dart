import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:music_player/controllers/controller.dart';
import 'package:music_player/controllers/music_controller.dart';
import 'package:music_player/data/music_data.dart';
import 'package:music_player/tiles/music_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class MusicsTab extends StatelessWidget {
  bool maisTocadas = false;

  MusicsTab(this.maisTocadas);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<Controller>(context);
    final musicController = Provider.of<MusicController>(context);

    Widget listaMusicas(Future<QuerySnapshot> future){
      return FutureBuilder<QuerySnapshot>(
          future: future,
          builder: (context, snapshot) {
            bool aux = false;
            bool aux2 = false;
            List<DocumentSnapshot> documents = List<DocumentSnapshot>();
            List<DocumentSnapshot> documentsSearch = List<DocumentSnapshot>();
            if(snapshot.data != null && !maisTocadas && controller.participacoes && snapshot.data.documents.length > 50){
              aux = true;
            }
            if(snapshot.data != null && !maisTocadas && !controller.participacoes && snapshot.data.documents.length < 50){
              aux2 = true;
            }
            if (snapshot.data != null) {
              documents = snapshot.data.documents;
              if (musicController.search != null &&
                  musicController.search != '') {
                documents.forEach((element) {
                  if ((removeDiacritics(element.data['nome']
                      .toString()
                      .toLowerCase())
                      .contains(removeDiacritics(musicController.search.toLowerCase())) ||
                      removeDiacritics(element.data['autor']
                          .toString()
                          .toLowerCase())
                          .contains(removeDiacritics(musicController.search.toLowerCase()))) && element.data['url'] != null) {
                    documentsSearch.add(element);
                  }
                });
                documents = documentsSearch;
              }
              musicController.listaMusicas = documents;
            }
            if (!snapshot.hasData || aux || aux2)
              return Center(
                child: CircularProgressIndicator(),
              );
            else {
              return ListView.builder(
                padding: EdgeInsets.all(4),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  MusicData data = MusicData.fromDocument(documents[index]);
                  return MusicTile(data, false);
                },
              );
            }
          });
    }

    return Observer(builder: (_) {
      Future<QuerySnapshot> future =
          Firestore.instance.collection('musicas').where('participacao', isEqualTo: false).getDocuments();

      if(controller.participacoes){
        future = Firestore.instance
            .collection('musicas')
            .where('participacao', isEqualTo: true)
            .getDocuments();
      }
      if (maisTocadas) {
        future = Firestore.instance
            .collection('musicas')
            .orderBy('num', descending: true)
            .limit(30)
            .getDocuments();
      }
      if (musicController.search != null && musicController.search != '') {
        return listaMusicas(future);
      } else {
        return listaMusicas(future);
      }
    });
  }
}
