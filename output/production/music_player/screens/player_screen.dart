import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:music_player/controllers/music_controller.dart';
import 'package:music_player/db/favoritos_db.dart';
import 'package:music_player/tiles/music_tile.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class PlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final musicController = Provider.of<MusicController>(context);
    final BehaviorSubject<double> _dragPositionSubject = BehaviorSubject.seeded(null);
    final Color secondColorRed = Color(0xFFFF4444);
    double currentPosition = 0.0;
    double durationAux = 0.0;
    bool auxShuffleButton = true;
    bool auxRepeatButton = true;
    bool auxLikeButton = true;
    final FlareControls controllerSkipPrevious = FlareControls();
    final FlareControls controllerSkipNext = FlareControls();
    final FlareControls controllerLike = FlareControls();
    FavoritosDB favoritosDB = FavoritosDB();
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    String getAnimationRepeat(){
      switch(musicController.repeatAux){
        case'repeatOff':
          if(auxRepeatButton){
            return 'repeatOne';
          }
          return 'repeatOff';
          break;
        case'repeatOne':
          if(auxRepeatButton){
            return 'repeat';
          }
          return 'repeatOne';
          break;
        case'repeat':
          if(auxRepeatButton){
            return 'repeatOff';
          }
          return 'repeat';
          break;
      }
      return '';
    }

    favoritarMusica(bool favoritada){
      if(favoritada){
        favoritosDB.deleteMusic(musicController.music.url);
        favoritada = false;
        _scaffoldKey
            .currentState.showSnackBar(
            SnackBar(
              content: Text(
                  "Removida das Favoritas"),
            ));
      }else {
        favoritosDB.saveMusic(musicController.music);
        favoritada = true;
        _scaffoldKey
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

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Image.asset("assets/projotalogo.png", fit: BoxFit.fitHeight, height: 35,),
        elevation: 0,
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(Icons.keyboard_arrow_down, color: Colors.white),
          iconSize: 40,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.playlist_play, color: Colors.white,),
              onPressed: (){
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      color: Theme.of(context).primaryColor,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 8),
                                child: IconButton(
                                    icon: Icon(Icons.close, size: 28, color: Colors.white,),
                                    onPressed: (){
                                      Navigator.pop(context);
                                    }),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 10, top: 18),
                                alignment: Alignment.center,
                                child: Text('Fila de reprodução', style: TextStyle(fontSize: 20, color: Colors.white)),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, size: 28, color: Colors.transparent,),
                              ),
                            ],
                          ),
                          Divider(
                            color: secondColorRed,
                          ),
                          Expanded(child: Observer(
                              builder: (_){
                                if(musicController.listaReproducao==null){
                                  return Container(
                                    alignment: Alignment.center,
                                    child: Text('Nenhuma música tocando', style: TextStyle(color: Colors.white, fontSize: 22),),
                                  );
                                }else {
                                  return ListView.builder(
                                    padding: EdgeInsets.all(4),
                                    itemCount: musicController.listaReproducao
                                        .length,
                                    itemBuilder: (context, index) {
                                      return MusicTile(musicController
                                          .listaReproducao[index], true);
                                    },
                                  );
                                }
                              }
                          ))
                        ],
                      ),
                    );
                  },
                );
              },
              iconSize: 30,
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          children: <Widget>[
            Expanded(
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: StreamBuilder<MediaItem>(
                    stream: AudioService.currentMediaItemStream,
                    builder: (context, snapshot) {
                      return Observer(
                          builder: (_){
                            return AspectRatio(
                              aspectRatio: 1,
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/logoprojotabanner.png',
                                image: AudioService.currentMediaItem != null ? AudioService.currentMediaItem.artUri : musicController.music.imagem,
                                fit: BoxFit.cover,
                              ),
                            );
                          }
                      );
                    },
                  ),
                )
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  StreamBuilder<MediaItem>(
                    stream: AudioService.currentMediaItemStream,
                    builder: (context, snapshot) {
                      return Observer(
                          builder: (_){
                            return Flexible(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Text(AudioService.currentMediaItem != null ? AudioService.currentMediaItem.title : musicController.music.nome, style: TextStyle(fontSize: 18, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis,)
                                ),
                                Container(
                                    child: Text(AudioService.currentMediaItem != null ? AudioService.currentMediaItem.artist : musicController.music.autor, style: TextStyle(fontSize: 15, color: Color(0xFFC8C8C8)), maxLines: 1, overflow: TextOverflow.ellipsis,)
                                )
                              ],
                            ));
                          }
                      );
                    },
                  ),
                  Observer(
                      builder: (_){
                        bool favoritada = false;
                        musicController.listFavoritos.forEach((element) {
                          if(element.nome == musicController.music.nome){
                            favoritada = true;
                          }
                        });
                          return InkWell(
                            child: Container(
                              child: FlareActor('assets/like.flr', animation: favoritada ? (auxLikeButton ? 'dislike' : 'like') : (auxLikeButton ? 'like' :'dislike'), isPaused: auxLikeButton, controller: controllerLike,),
                              height: 40,
                              width: 40,
                            ),
                            onTap: (){
                              auxLikeButton = false;
                              if(favoritada){
                                controllerLike.play('dislike');
                              }else{
                                controllerLike.play('like');
                              }
                              favoritarMusica(favoritada);
                            },
                          );
                      }
                  ),
                ],
              ),
            ),
            StreamBuilder<PlaybackState>(
              stream: AudioService.playbackStateStream,
              builder: (context, snapshot){
                double seekPos;
                return StreamBuilder(
                  stream: Rx.combineLatest2<double, double, double>(
                      _dragPositionSubject.stream,
                      Stream.periodic(Duration(milliseconds: 200)),
                          (dragPosition, _) => dragPosition),
                  builder: (context2, snapshot2) {
                    double position = currentPosition;
                    double duration = durationAux;
                    if(snapshot.data != null && snapshot.data.currentPosition != null && AudioService.currentMediaItem != null){
                      position = snapshot2.data ?? snapshot.data.currentPosition.toDouble();
                      duration = AudioService.currentMediaItem?.duration?.toDouble();
                      currentPosition = position;
                      durationAux = duration;
                    }
                    Duration currentMin = new Duration(milliseconds: position.toInt());
                    Duration durationMin = new Duration(minutes: durationAux ~/ 60000, seconds: (((durationAux / 60000) % 1) * 100).toInt());
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SliderTheme(data: SliderTheme.of(context).copyWith(
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
                            thumbColor: Color(0xFFFF4444),
                            activeTrackColor: Color(0xFFFF4444)),
                            child: Slider(
                                value: seekPos ?? max(0.0, min(position, durationMin.inMilliseconds.toDouble())),
                                min: 0,
                                max: durationMin.inMilliseconds.toDouble(),
                                onChanged: (value) {
                                  _dragPositionSubject.add(value);
                                },
                                onChangeEnd: (value) {
                                  AudioService.seekTo(value.toInt());
                                  // Due to a delay in platform channel communication, there is
                                  // a brief moment after releasing the Slider thumb before the
                                  // new position is broadcast from the platform side. This
                                  // hack is to hold onto seekPos until the next state update
                                  // comes through.
                                  // TODO: Improve this code.
                                  seekPos = value;
                                  _dragPositionSubject.add(null);
                                },
                            )
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  child: Text(currentMin.toString().split('.')[0].substring(2), style: TextStyle(fontSize: 15, color: Color(0xFFC8C8C8)))
                              ),
                              Container(
                                  child: Text(durationMin.toString().split('.')[0].substring(2), style: TextStyle(fontSize: 15, color: Color(0xFFC8C8C8)))
                              )
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Observer(
                      builder: (_){
                        return InkWell(
                          child: Container(
                            child: FlareActor('assets/shuffle.flr', animation: musicController.shuffleAux ? (auxShuffleButton ? 'negative' : 'positive') : (auxShuffleButton ? 'positive' :'negative'), isPaused: auxShuffleButton,),
                            height: 60,
                            width: 60,
                          ),
                          onTap: (){
                            auxShuffleButton = false;
                            if(musicController.shuffleAux){
                              musicController.shuffleOff();
                            }else {
                              musicController.shuffleInPlayerScreen();
                            }
                            musicController.changeShuffleAux(!musicController.shuffleAux);
                          },
                        );
                      }
                  ),
                  InkWell(
                    child: Container(
                      child: FlareActor('assets/skip.flr', controller: controllerSkipPrevious, animation: 'skipPreviousStatic',),
                      height: 30,
                      width: 30,
                    ),
                    onTap: (){
                      controllerSkipPrevious.play('skipPrevious');
                      musicController.skip(-1);
                    },
                  ),
                  StreamBuilder<PlaybackState>(
                    stream: AudioService.playbackStateStream,
                    builder: (context, snapshot){
                      return IconButton(
                        icon: snapshot.data !=null ? (snapshot.data.basicState == BasicPlaybackState.playing ? Icon(Icons.pause_circle_filled, color: Colors.white,) : Icon(Icons.play_circle_filled, color: Colors.white)) : Icon(Icons.play_circle_filled, color: Colors.white),
                        onPressed: (){
                          musicController.playPause();
                        },
                        iconSize: 70,
                      );
                    },
                  ),
                  InkWell(
                    child: Container(
                      child: FlareActor('assets/skip.flr', controller: controllerSkipNext, animation: 'skipNextStatic',),
                      height: 30,
                      width: 30,
                    ),
                    onTap: (){
                      controllerSkipNext.play('skipNext');
                      musicController.skip(1);
                    },
                  ),
                  Observer(
                      builder: (_){
                        return InkWell(
                          child: Container(
                            padding: EdgeInsets.all(13),
                            child: FlareActor('assets/repeat.flr', animation: getAnimationRepeat(), isPaused: auxRepeatButton,),
                            height: 60,
                            width: 60,
                          ),
                          onTap: (){
                            auxRepeatButton = false;
                            switch(musicController.repeatAux){
                              case'repeatOff':
                                musicController.changeRepeatAux('repeatOne');
                                musicController.repeatOne();
                                break;
                              case'repeatOne':
                                musicController.changeRepeatAux('repeat');
                                musicController.repeat();
                                break;
                              case'repeat':
                                musicController.changeRepeatAux('repeatOff');
                                musicController.repeatOff();
                                break;
                            }
                          },
                        );
                      }
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
