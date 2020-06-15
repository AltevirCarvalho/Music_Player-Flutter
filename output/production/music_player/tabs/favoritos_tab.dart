import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:music_player/controllers/music_controller.dart';
import 'package:music_player/data/music_data.dart';
import 'package:music_player/tiles/music_tile.dart';
import 'package:provider/provider.dart';

class FavoritosTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final musicController = Provider.of<MusicController>(context);
    musicController.listaMusicas = musicController.listFavoritos;

    Widget lista(){
      return ListView.builder(
        padding: EdgeInsets.all(4),
        itemCount: musicController.listFavoritos.length,
        itemBuilder: (context, index) {
          return MusicTile(musicController.listFavoritos[index], false);
        },
      );
    }

    return Observer(
        builder: (_){
          musicController.listaMusicas = musicController.listFavoritos;
          return musicController.listaMusicas.length == 0 ? Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.playlist_add, color: Colors.white, size: 70,),
                Text('Favorite alguma música!', style: TextStyle(color: Colors.white, fontSize: 20),),
              ],
            ),
          ) : lista();
        }
    );
  }
}
