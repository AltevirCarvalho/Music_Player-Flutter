import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:music_player/data/music_data.dart';
import 'package:music_player/service/player_service.dart';
part 'music_controller.g.dart';

class MusicController = _MusicControllerBase with _$MusicController;

abstract class _MusicControllerBase with Store{

  List<dynamic> listaMusicas;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  listaMusicasToMap(){
    if(listaMusicas[0].runtimeType == DocumentSnapshot) {
      return listaMusicas.map((e) {
        if (e.data['url'] != null) {
          return toMap(e);
        }
        return null;
      }).toList().whereType<Map>().toList();
    }else{
      return listaMusicas.map((e) {
        return musicDataToMap(e);
      }).toList().whereType<Map>().toList();
    }
  }

  changeListaReproducao(){
    bool aux = false;
    listaReproducao = AudioService.queue.map((e) {
      if(AudioService.currentMediaItem.id == e.id){
        aux = true;
      }
      if(aux){
        MusicData music = new MusicData();
        music.url = e.id;
        music.imagem = e.artUri;
        music.nome = e.title;
        music.duration = e.duration;
        music.autor = e.artist;
        music.id = e.genre;
        return music;
      }else{
        return null;
      }
    }).toList().whereType<MusicData>().toList();
  }

  Map<String, dynamic> toMap(DocumentSnapshot snapshot){
    return{
      'genre' :snapshot.documentID,
      'id' : snapshot.data['url'],
      'title' : snapshot.data['nome'],
      'artist' : snapshot.data['autor'],
      'duration' : snapshot.data['duration'],
      'artUri' : snapshot.data['imagem'],
    };
  }

  Map<String, dynamic> musicDataToMap(MusicData music){
    return{
      'genre' :music.id,
      'id' : music.url,
      'title' : music.nome,
      'artist' : music.autor,
      'duration' : music.duration,
      'artUri' : music.imagem,
    };
  }

  @observable
  List<MusicData> listaReproducao;

  @observable
  List<MusicData> listFavoritos = List();

  @observable
  MusicData music;

  @action
  changeMusic(MusicData newMusic) => music = newMusic;

  @computed
  get getMusic => music;

  @observable
  String search;

  @action
  changeSearch(String value) => search = value;

  @observable
  bool shuffleAux = false;

  @action
  changeShuffleAux(bool value) => shuffleAux = value;

  @observable
  String repeatAux = 'repeatOff';

  @action
  changeRepeatAux(String value) => repeatAux = value;

  attLista() async {
    if(await AudioService.running) {
      await AudioService.customAction('addLista', listaMusicasToMap());
    }
  }

  initializeService() async {
    await AudioService
        .start( // When user clicks button to start playback
      backgroundTaskEntrypoint: myBackgroundTaskEntrypoint,
      androidNotificationChannelName: 'Músicas',
      androidNotificationIcon: "mipmap/ic_launcher",
      enableQueue: true,
      notificationColor: 0xFF2196f3,
      androidStopForegroundOnPause: true,
      androidStopOnRemoveTask: true,
    );
    await AudioService.customAction('addLista', listaMusicasToMap());
    if(shuffleAux){
      AudioService.customAction('shuffle', null);
    }
    switch(repeatAux){
      case 'repeatOne':
        AudioService.customAction('repeatOne', '');
        break;
      case 'repeat':
        AudioService.customAction('repeat', '');
        break;
    }
  }

  startNotificationService() async {
    if(!await AudioService.running) {
      await initializeService();
      AudioService.customAction('play', {
        'genre' : music.id,
        'id' : music.url,
        'title' : music.nome,
        'artist' : music.autor,
        'duration' : music.duration,
        'artUri' : music.imagem,
      });
    }else{
      AudioService.customAction('play', {
        'genre' : music.id,
        'id' : music.url,
        'title' : music.nome,
        'artist' : music.autor,
        'duration' : music.duration,
        'artUri' : music.imagem,
      });
    }
  }

  playPause() async {
    if(await AudioService.running) {
      if(AudioService.playbackState.basicState == BasicPlaybackState.playing){
        AudioService.pause();
      }else{
        AudioService.click();
      }
    }else{
      startNotificationService();
    }
  }

  skip(int i) async {
    repeatAux = 'repeatOff';
    if(await AudioService.running) {
      if(i > 0){
        AudioService.customAction('skipToNext', {
          'genre' : music.id,
          'id' : music.url,
          'title' : music.nome,
          'artist' : music.autor,
          'duration' : music.duration,
          'artUri' : music.imagem,
        });
      }else{
        AudioService.skipToPrevious();
      }
    }else if(i > 0){
      await initializeService();
      AudioService.customAction('skipToNext', {
        'genre' : music.id,
        'id' : music.url,
        'title' : music.nome,
        'artist' : music.autor,
        'duration' : music.duration,
        'artUri' : music.imagem,
      });
    } else{
      await initializeService();
      AudioService.customAction('skipToPrevious', {
        'genre' : music.id,
        'id' : music.url,
        'title' : music.nome,
        'artist' : music.autor,
        'duration' : music.duration,
        'artUri' : music.imagem,
      });
    }
  }

  shuffle() async {
    if(!await AudioService.running) {
      await initializeService();
      await AudioService.customAction('shuffle', null);
    }else{
      AudioService.customAction('shuffle', null);
    }
  }

  shuffleInPlayerScreen(){
    AudioService.customAction('shuffleMusic', {
      'genre' : music.id,
      'id' : music.url,
      'title' : music.nome,
      'artist' : music.autor,
      'duration' : music.duration,
      'artUri' : music.imagem,
    });
  }

  shuffleOff(){
    AudioService.customAction('shuffleOff', {
      'genre' : music.id,
      'id' : music.url,
      'title' : music.nome,
      'artist' : music.autor,
      'duration' : music.duration,
      'artUri' : music.imagem,
    });
  }

  repeat(){
    AudioService.customAction('repeat', '');
  }
  repeatOne(){
    AudioService.customAction('repeatOne', '');
  }
  repeatOff(){
    AudioService.customAction('repeatOff', '');
  }

  addFila(MusicData music) async {
    if(!await AudioService.running) {
      //Não existe fila
    }else{
      AudioService.customAction('addFila', {
        'genre' : music.id,
        'id' : music.url,
        'title' : music.nome,
        'artist' : music.autor,
        'duration' : music.duration,
        'artUri' : music.imagem,
      });
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Adicionado à sua fila!"),
      ));
    }
  }

  removerDaFila(MusicData music) async {
    await AudioService.customAction('removerDaFila', {
      'genre' : music.id,
      'id' : music.url,
      'title' : music.nome,
      'artist' : music.autor,
      'duration' : music.duration,
      'artUri' : music.imagem,
    });
    listaReproducao.remove(music);
    listaReproducao = listaReproducao;
  }
}