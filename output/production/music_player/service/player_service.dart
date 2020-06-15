import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/controllers/music_controller.dart';
import 'package:provider/provider.dart';

void myBackgroundTaskEntrypoint() {
  AudioServiceBackground.run(() => PlayerService());
}

MediaControl playControl = MediaControl(
  androidIcon: 'mipmap/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'mipmap/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'mipmap/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'mipmap/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'mipmap/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

class PlayerService extends BackgroundAudioTask {

  var _queue = <MediaItem>[];
  var _queueAux = <MediaItem>[];
  int positionMusic = 0;
  int auxPositionFila = 1;
  bool wasPlayingAux = false;
  int repeatAux = 0;

  int _queueIndex = -1;
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();
  BasicPlaybackState _skipState;
  bool _playing;
  bool get hasNext => _queueIndex + 1 < _queue.length;
  bool get hasPrevious => _queueIndex > 0;
  MediaItem get mediaItem => _queue[_queueIndex];

  BasicPlaybackState _stateToBasicState(AudioPlaybackState state) {
    switch (state) {
      case AudioPlaybackState.none:
        return BasicPlaybackState.none;
      case AudioPlaybackState.stopped:
        return BasicPlaybackState.stopped;
      case AudioPlaybackState.paused:
        return BasicPlaybackState.paused;
      case AudioPlaybackState.playing:
        return BasicPlaybackState.playing;
      case AudioPlaybackState.connecting:
        return _skipState ?? BasicPlaybackState.connecting;
      case AudioPlaybackState.completed:
        return BasicPlaybackState.stopped;
      default:
        throw Exception("Illegal state");
    }
  }

  @override
  Future<void> onStart() async {
    var playerStateSubscription = _audioPlayer.playbackStateStream
        .where((state) => state == AudioPlaybackState.completed)
        .listen((state) {
      _handlePlaybackCompleted();
    });
    var eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final state = _stateToBasicState(event.state);
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
      }
    });

    AudioServiceBackground.setQueue(_queue);
//    await onSkipToNext();
    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
  }

  void _handlePlaybackCompleted() {
    if (hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
  }

  void playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      onPause();
    else
      onPlay();
  }

  @override
  Future<void> onSkipToNext() async {
    if(positionMusic + 1 < _queue.length || repeatAux > 0) {
      if (repeatAux == 0) {
        positionMusic++;
        if (auxPositionFila > 1)
          auxPositionFila--;
      } else if (repeatAux == 1) {
        repeatAux = 0;
      }
      await initializeMusic();
      onPlay();
    }else{
      await initializeMusic();
      onPlay();
    }
  }

  //Esta sendo usado como onSkipToNext para o NEXT da notificacao, o NEXT foi alterado no Plugin para chamar o fastForward
  @override
  void onFastForward() {
    repeatAux = 0;
    onSkipToNext();
  }

  @override
  Future<void> onSkipToPrevious() async {
    if(AudioServiceBackground.state.position < 5000 && positionMusic != 0)
      positionMusic--;
    await initializeMusic();
    onPlay();
  }

  Future<void> _skip(int offset) async {

    final newPos = _queueIndex + offset;

    if (!(newPos >= 0 && newPos < _queue.length)) return;

    if (_playing == null) {
      // First time, we want to start playing
      _playing = true;
    } else if (_playing) {
      // Stop current item
      await _audioPlayer.stop();
    }
    // Load next item
    _queueIndex = newPos;
    AudioServiceBackground.setMediaItem(_queue[0]);
    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;
    await _audioPlayer.setUrl(_queue[0].id);
    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
      _setState(state: BasicPlaybackState.paused);
    }
  }

  @override
  void onStop() {
    _audioPlayer.stop();
    _setState(state: BasicPlaybackState.stopped);
    _completer.complete();
  }
  @override
  Future<void> onPlay() async {
    if (_skipState == null) {
      _playing = true;
      _audioPlayer.play();
    }
  }
  @override
  void onPause() {
    if (_skipState == null) {
      _playing = false;
      _audioPlayer.pause();
    }
  }
  @override
  void onClick(MediaButton button) {
    playPause();
  }
  @override
  void onSeekTo(int position) {
    _audioPlayer.seek(Duration(milliseconds: position));
  }

  @override
  Future<void> onCustomAction(String name, arguments) async {
    super.onCustomAction(name, arguments);
    switch(name){
      case 'addLista':
        _queue.clear();
        _queueAux.clear();
        _queue = toMediaItem(arguments);
        _queueAux = toMediaItem(arguments);
        AudioServiceBackground.setQueue(_queue);
        break;
      case 'play':
        positionMusic = _queue.indexOf(MediaItem(
          id: arguments['id'],
          album: "",
          title: arguments['title'],
          artist: arguments['artist'],
          duration: arguments['duration'],
          artUri: arguments['artUri'],
        ));
        await initializeMusic();
        await onPlay();
        break;
      case 'skipToNext':
        if(positionMusic + 1  < _queue.length) {
          positionMusic = _queue.indexOf(MediaItem(
            id: arguments['id'],
            album: "",
            title: arguments['title'],
            artist: arguments['artist'],
            duration: arguments['duration'],
            artUri: arguments['artUri'],
          )) + 1;
          if (auxPositionFila > 1)
            auxPositionFila--;
          repeatAux = 0;
          await initializeMusic();
          await onPlay();
        }else{
          await initializeMusic();
          onPlay();
        }
        break;
      case 'skipToPrevious':
        positionMusic = _queue.indexOf(MediaItem(
            id: arguments['id'],
            album: "",
            title: arguments['title'],
            artist: arguments['artist'],
            duration: arguments['duration'],
            artUri: arguments['artUri'],
          ));
        if(AudioServiceBackground.state.position < 5000 && positionMusic != 0)
          positionMusic--;
        await initializeMusic();
        await onPlay();
        break;
      case 'shuffle':
        positionMusic = 0;
        _queue.shuffle();
        AudioServiceBackground.setQueue(_queue);
        await initializeMusic();
        await onPlay();
        break;
      case 'shuffleMusic':
        positionMusic = 0;
        _queue.shuffle();
        _queue.remove(MediaItem(
          id: arguments['id'],
          album: "",
          title: arguments['title'],
          artist: arguments['artist'],
          duration: arguments['duration'],
          artUri: arguments['artUri'],
        ));
        _queue.insert(0, MediaItem(
          id: arguments['id'],
          album: "",
          title: arguments['title'],
          artist: arguments['artist'],
          duration: arguments['duration'],
          artUri: arguments['artUri'],
        ));
        AudioServiceBackground.setQueue(_queue);
        break;
      case 'shuffleOff':
        _queue.clear();
        _queue.addAll(_queueAux);
        AudioServiceBackground.setQueue(_queue);
        positionMusic = _queue.indexOf(MediaItem(
          id: arguments['id'],
          album: "",
          title: arguments['title'],
          artist: arguments['artist'],
          duration: arguments['duration'],
          artUri: arguments['artUri'],
        ));
        break;
      case 'repeatOff':
        repeatAux = 0;
        break;
      case 'repeatOne':
        repeatAux = 1;
        break;
      case 'repeat':
        repeatAux = 999;
        break;
      case 'addFila':
        _queue.remove(MediaItem(
          id: arguments['id'],
          album: "",
          title: arguments['title'],
          artist: arguments['artist'],
          duration: arguments['duration'],
          artUri: arguments['artUri'],
        ));
        _queue.insert(positionMusic + auxPositionFila, MediaItem(
          id: arguments['id'],
          album: "",
          title: arguments['title'],
          artist: arguments['artist'],
          duration: arguments['duration'],
          artUri: arguments['artUri'],
        ));
        auxPositionFila++;
        AudioServiceBackground.setQueue(_queue);
        break;
      case 'removerDaFila':
        _queue.remove(MediaItem(
          id: arguments['id'],
          album: "",
          title: arguments['title'],
          artist: arguments['artist'],
          duration: arguments['duration'],
          artUri: arguments['artUri'],
        ));
        AudioServiceBackground.setQueue(_queue);
        break;
    }
  }

  initializeMusic() async {
    if(positionMusic < _queue.length) {
      if (_playing == null) {
        // First time, we want to start playing
        _playing = true;
      } else if (_playing) {
        // Stop current item
        await _audioPlayer.stop();
      }
      AudioServiceBackground.setMediaItem(_queue[positionMusic]);
      await _audioPlayer.setUrl(_queue[positionMusic].id);
      //Genre is using like DocumentID
      Firestore.instance.collection('musicas').document(
          _queue[positionMusic].genre).get().then((value) {
        value.reference.updateData({'num': value.data['num'] + 1});
      });
    }
  }

  toMediaItem(List<dynamic> list){
    return list.map((e) {
      return MediaItem(
        id: e['id'],
        album: "",
        title: e['title'],
        artist: e['artist'],
        duration: e['duration'],
        artUri: e['artUri'],
        genre: e['genre'],
      );
    }).toList();
  }

  void _setState({@required BasicPlaybackState state, int position}) {
    if (position == null) {
      position = _audioPlayer.playbackEvent.position.inMilliseconds;
    }
    AudioServiceBackground.setState(
      controls: getControls(state),
      systemActions: [MediaAction.seekTo],
      basicState: state,
      position: position,
    );
  }

  List<MediaControl> getControls(BasicPlaybackState state) {
    if (_playing) {
      return [
        skipToPreviousControl,
        pauseControl,
        skipToNextControl
      ];
    } else {
      return [
        skipToPreviousControl,
        playControl,
        skipToNextControl
      ];
    }
  }

  @override
  void onAudioFocusGained() {
    if(wasPlayingAux) {
      onPlay();
      wasPlayingAux = false;
      super.onAudioFocusGained();
    }
  }

  @override
  void onAudioFocusLost() {
    if(AudioServiceBackground.state.basicState == BasicPlaybackState.playing) {
      onPause();
      wasPlayingAux = true;
      super.onAudioFocusLost();
    }
  }

  @override
  void onAudioFocusLostTransient() {
    if(AudioServiceBackground.state.basicState == BasicPlaybackState.playing) {
      onPause();
      wasPlayingAux = true;
      super.onAudioFocusLostTransient();
    }
  }

  // O audio está abaixando o volume, porem teve que comentar a funcao no Plugin = //.setWillPauseWhenDucked(true)
//  @override
//  void onAudioFocusLostTransientCanDuck() {
//    if(AudioServiceBackground.state.basicState == BasicPlaybackState.playing) {
//      onPause();
//      wasPlayingAux = true;
//      super.onAudioFocusLostTransientCanDuck();
//    }
//  }

  @override
  void onAudioBecomingNoisy() {
    onPause();
    super.onAudioBecomingNoisy();
  }
}