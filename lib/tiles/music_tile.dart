import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:music_player/controllers/controller.dart';
import 'package:music_player/controllers/music_controller.dart';
import 'package:music_player/data/music_data.dart';
import 'package:music_player/db/favoritos_db.dart';
import 'package:music_player/screens/player_screen.dart';
import 'package:music_player/service/player_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MusicTile extends StatelessWidget {
  final MusicData music;
  final bool filaReproducao;

  MusicTile(this.music, this.filaReproducao);

  final Color secondColorGrey = Color(0xFFC8C8C8);
  FavoritosDB favoritosDB = FavoritosDB();

  @override
  Widget build(BuildContext context) {
    final musicController = Provider.of<MusicController>(context);
    bool favoritada = false;

    musicController.listFavoritos.forEach((element) {
      if(element.nome == music.nome){
        favoritada = true;
      }
    });

    favoritarMusica(){
      if(favoritada){
        favoritosDB.deleteMusic(music.url);
        favoritada = false;
        musicController.scaffoldKey
            .currentState.showSnackBar(
            SnackBar(
              content: Text(
                  "Removida das Favoritas"),
            ));
      }else {
        favoritosDB.saveMusic(music);
        favoritada = true;
        musicController.scaffoldKey
            .currentState.showSnackBar(
            SnackBar(
              content: Text(
                  "Adicionada a Favoritas"),
            ));
      }
      favoritosDB.getAllMusics().then((
          list) {
        musicController.listFavoritos =
            list;
      });
    }

    Widget iconMore(){
      return IconButton(
          icon: Icon(Icons.more_vert, color: Colors.white,),
          onPressed: (){
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Color(0x99121212), Theme.of(context).primaryColor]
                                  )
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    height: MediaQuery.of(context).size.height/6,
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/logoprojotabanner.png',
                                      image: music.imagem,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.all(10),
                                      child: Text(music.nome, style: TextStyle(color: Colors.white, fontSize: 19)
                                      )
                                  ),
                                  Container(
                                      child: Text(music.autor, style: TextStyle(color: secondColorGrey, fontSize: 15),
                                        textAlign: TextAlign.center,
                                      )
                                  ),
                                ],
                              ),
                            )
                          ),
                          Container(
                            color: Theme.of(context).primaryColor,
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);
                                    favoritarMusica();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: Text(favoritada ? 'Desfavoritar' : "Favoritar", style: TextStyle(color: Colors.white, fontSize: 15)),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);
                                    musicController.addFila(music);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: Text('Adicionar a fila', style: TextStyle(color: Colors.white, fontSize: 15)),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    var whatsappUrl ="https://wa.me/5521965403233?text=Olha%20esse%20novo%20App%20de%20m%C3%BAsicas%20do%20Projota!%20https://bit.ly/AppProjota";
                                    await canLaunch(whatsappUrl)? launch(whatsappUrl):print("Você não possui o Whatsapp instalado. Entre em contato pelo Whatsapp neste número 55 (21) 965403233.");
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    alignment: Alignment.center,
                                    child: Text('Compartilhar', style: TextStyle(color: Colors.white, fontSize: 15),),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
                  ],
                );
              },);
          });
    }

    Widget iconRemoveDaFila(){
      return IconButton(
          icon: Icon(Icons.close, color: Colors.white,),
          onPressed: (){
            musicController.removerDaFila(music);
          }
      );
    }

    if (music.data != null) {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        elevation: 0,
        color: Theme.of(context).primaryColor,
        child: Row(
          children: <Widget>[
            Container(
              width: 110,
              padding: EdgeInsets.fromLTRB(0, 5, 20, 5),
              margin: EdgeInsets.only(left: 10),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/logoprojotabanner.png',
                image: music.imagem,
                fit: BoxFit.cover,
              ),
            ),
            Flexible(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    music.nome,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    music.autor,
                    style: TextStyle(fontSize: 16, color: secondColorGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  music.data,
                  style: TextStyle(fontSize: 16, color: secondColorGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ))
          ],
        ),
      );
    } else {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        elevation: 0,
        color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: InkWell(
              onTap: () async {
                musicController.changeMusic(music);
                musicController.attLista();
                musicController.startNotificationService();
              },
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: StreamBuilder<MediaItem>(
                        stream: AudioService.currentMediaItemStream,
                        builder: (context, snapshot) {
                          return Observer(
                              builder: (_){
                                return Text(
                                  music.nome,
                                  style: TextStyle(fontSize: 16, color: AudioService.currentMediaItem != null ? AudioService.currentMediaItem.title == music.nome ? Color(0xFFFF4444) : Colors.white : musicController.music !=null ? (musicController.music.nome == music.nome ? Color(0xFFFF4444) : Colors.white) : Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                          );
                        },
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(Icons.adjust, color: Colors.white, size: 20,),
                        ),
                        Flexible(
                            child: Text(
                              music.autor,
                              style: TextStyle(fontSize: 13, color: secondColorGrey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )),
            filaReproducao ? iconRemoveDaFila() : iconMore(),
          ],
        ),
      );
    }
  }
}
