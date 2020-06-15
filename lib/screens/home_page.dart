import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:music_player/controllers/controller.dart';
import 'package:music_player/controllers/music_controller.dart';
import 'package:music_player/data/music_data.dart';
import 'package:music_player/db/favoritos_db.dart';
import 'package:music_player/screens/player_screen.dart';
import 'package:music_player/tabs/favoritos_tab.dart';
import 'package:music_player/tabs/musics_tab.dart';
import 'package:music_player/widgets/app_bar_home.dart';
import 'package:music_player/widgets/drawer_home.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatelessWidget {
  final Color secondColorRed = Color(0xFFFF4444);
  final Color secondColorGrey = Color(0xFFC8C8C8);
  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);
  bool auxPlayPauseButton = true;
  FavoritosDB favoritosDB = FavoritosDB();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<Controller>(context);
    final musicController = Provider.of<MusicController>(context);
    AudioService.connect();
    favoritosDB.getAllMusics().then((list){
      musicController.listFavoritos = list;
    });

    Widget bottonNavigation() {
      return Observer(builder: (_) {
        return BottomNavigationBar(
            backgroundColor: Color(0xFF222327),
            selectedItemColor: Color(0xFFFF4444),
            unselectedItemColor: Color(0xFFb2b2b2),
            onTap: (int index) {
              controller.changeIndex(index);
              controller.pageController.jumpToPage(index);
            },
            currentIndex: controller.currentIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.whatshot),
                title: Text('Mais Tocadas'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                title: Text('Músicas'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                title: Text('Favoritas'),
              )
            ]);
      });
    }

    Widget musicBar() {
      return GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => PlayerScreen()));
        },
        child: Column(
          children: <Widget>[
            StreamBuilder<PlaybackState>(
              stream: AudioService.playbackStateStream,
              builder: (context, snapshot) {
                double seekPos;
                double currentPosition = 0.0;
                double durationAux = 0.0;
                return StreamBuilder(
                  stream: Rx.combineLatest2<double, double, double>(
                      _dragPositionSubject.stream,
                      Stream.periodic(Duration(milliseconds: 200)),
                      (dragPosition, _) => dragPosition),
                  builder: (context2, snapshot2) {
                    double position;
                    double duration;
                    if (snapshot.data != null && snapshot.data.currentPosition != null && AudioService.currentMediaItem != null) {
                      position = snapshot2.data ??
                          snapshot.data.currentPosition.toDouble();
                      duration =
                          AudioService.currentMediaItem?.duration?.toDouble();
                      currentPosition = position;
                      durationAux = duration;
                    }
                    Duration durationMin = new Duration(minutes: durationAux ~/ 60000, seconds: (((durationAux / 60000) % 1) * 100).toInt());
                    return SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 0),
                          thumbColor: Color(0xFFFF4444),
                          activeTrackColor: Color(0xFFFF4444),
                          trackHeight: 3,
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: seekPos ?? max(0.0, min(currentPosition, durationMin.inMilliseconds.toDouble())),
                          min: 0,
                          max: durationMin.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            _dragPositionSubject.add(value);
                          },
                          onChangeEnd: (value) {
                            AudioService.seekTo(value.toInt());
                            seekPos = value;
                            _dragPositionSubject.add(null);
                          },
                        ));
                  },
                );
              },
            ),
            Container(
              height: 55,
              color: Color(0xFF222327),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                      icon: Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                      ),
                      iconSize: 40,
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) => PlayerScreen()));
                      }),
                  Observer(builder: (_) {
                    return Text(
                      musicController.music == null
                          ? ""
                          : musicController.music.nome,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    );
                  }),
                  StreamBuilder<PlaybackState>(
                    stream: AudioService.playbackStateStream,
                    builder: (context, snapshot) {
                      return InkWell(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: FlareActor('assets/play_pause.flr', animation: snapshot.data != null ? (snapshot.data.basicState == BasicPlaybackState.playing ? (auxPlayPauseButton ? 'pause' : 'to_play') : (auxPlayPauseButton ? 'play' : 'to_pause')) : 'play', isPaused: auxPlayPauseButton,),
                          height: 40,
                          width: 40,
                        ),
                        onTap: (){
                          auxPlayPauseButton = false;
                          musicController.playPause();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: 0.5,
              color: Color(0xFFFF4444),
              width: double.infinity,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: musicController.scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBarHome(),
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: <Widget>[
          Expanded(
              child: PageView(
            controller: controller.pageController,
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (index) {},
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 50,
                    child: Center(
                        child: Text('AS MAIS TOCADAS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, color: secondColorRed))),
                  ),
                  Container(
                    height: 0.5,
                    color: secondColorRed,
                    width: double.infinity,
                  ),
                  Expanded(child: MusicsTab(true)),
                ],
              ),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                          child: GestureDetector(
                        onTap: () {
                          controller.changeParticipacoes(false);
                        },
                        child: Observer(builder: (_) {
                          return Text('Álbuns',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: !controller.participacoes
                                      ? secondColorRed
                                      : secondColorGrey));
                        }),
                      )),
                      Container(
                        width: 0.5,
                        height: 50,
                        color: secondColorRed,
                      ),
                      Expanded(
                          child: GestureDetector(
                        onTap: () {
                          controller.changeParticipacoes(true);
                        },
                        child: Observer(builder: (_) {
                          return Text(
                            'Participações',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                color: controller.participacoes
                                    ? secondColorRed
                                    : secondColorGrey),
                          );
                        }),
                      ))
                    ],
                  ),
                  Container(
                    height: 0.5,
                    color: secondColorRed,
                    width: double.infinity,
                  ),
                  Expanded(child: MusicsTab(false))
                ],
              ),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 50,
                    child: Center(
                        child: Text('FAVORITAS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, color: secondColorRed))),
                  ),
                  Container(
                    height: 0.5,
                    color: secondColorRed,
                    width: double.infinity,
                  ),
                  Expanded(child: FavoritosTab()),
                ],
              ),
            ],
          )),
          StreamBuilder<MediaItem>(
            stream: AudioService.currentMediaItemStream,
            builder: (context, snapshot) {
              if(snapshot.data != null){
                MusicData newMusic = MusicData();
                newMusic.nome = snapshot.data.title;
                newMusic.imagem = snapshot.data.artUri;
                newMusic.autor = snapshot.data.artist;
                newMusic.duration = snapshot.data.duration;
                newMusic.url = snapshot.data.id;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if(newMusic.url != musicController.music.url) {
                    musicController.changeRepeatAux('repeatOff');
                  }
                });
                WidgetsBinding.instance.addPostFrameCallback((_){
                  musicController.changeMusic(newMusic);
                  musicController.changeListaReproducao();
                });
              }
              return Observer(
                  builder: (_){
                      return musicController.music != null ? musicBar() : Container();
                  }
              );
            },
          )
        ],
      ),
      drawer: DrawerHome(),
      bottomNavigationBar: bottonNavigation(),
      floatingActionButton: Observer(
        builder: (_){
          return Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(left: 30, bottom: musicController.music != null ? 50 : 0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              color: secondColorRed,
              child: Container(
                width: 150,
                height: 50,
                child: Center(
                  child: Text('Aleatório', style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              onPressed: (){
                musicController.attLista();
                musicController.shuffle();
                musicController.changeShuffleAux(true);
              },
            ),
          );
        },
      ),
    );
  }
}
