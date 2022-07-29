import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:omusic/components/player.dart';
import 'package:omusic/models/library.dart';

class LibraryGen {
  final int key = 0;
  final AudioPlayerHandler audioHandler;
  final Library lib;
  final playlist = [];
  final count = {
    'ofTracksInPlaylist': 0,
    'ofTracksToComeNext': 0,
  };
  LibraryGen({Key? key, required this.audioHandler, required this.lib});

  getHandler() {
    return audioHandler;
  }

  getLib() {
    return lib;
  }

  currentPlaylist() {
    return playlist;
  }

  List<MediaItem> getQueue() {
    if (audioHandler.queue.hasValue) {
      return audioHandler.queue.value;
    } else {
      return [];
    }
  }

  void addToQueue({List<MediaItem>? songs, MediaItem? song}) {
    final queue = audioHandler.queue;

    if (songs is List<MediaItem>) {
      queue.add(getQueue() + songs);
      playlist.addAll(songs);
    } else if (song is MediaItem) {
      queue.add(getQueue() + [song]);
      playlist.add(song);
    } else {
      print('No input');
      print(songs);
      print(song);
      throw 'addToQueue(MediaItem-No List or Media Input';
    }
    count['ofTracksInPlaylist'] = playlist.length;
    count['ofTracksToComeNext'] = getQueue().length;
  }
}

LibraryGen? library;
LibraryGen getLibrary({AudioPlayerHandler? handler, Library? lib}) {
  if (library is LibraryGen) {
    return library as LibraryGen;
  } else if (handler is AudioPlayerHandler && lib is Library) {
    library = LibraryGen(audioHandler: handler, lib: lib);
    return library as LibraryGen;
  } else {
    throw 'Missing handler or library to generate object';
  }
}
