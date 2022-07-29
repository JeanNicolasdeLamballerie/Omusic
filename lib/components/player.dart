import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:omusic/frog.dart';
import 'package:omusic/components/drive_api.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:audio_service/audio_service.dart';
// import 'dart:typed_data';

class AudioPlayerHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  AudioPlayer get() => _player;
  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
  Future<void> setLink(String link) => _player.setUrl(link);
  AudioPlayerHandler() {
    _player.setAudioSource(AudioSource.uri(Uri.parse('')));
  }
}

class Player extends StatefulWidget {
  final DriveAPI api;
  final AudioPlayerHandler handler;
  const Player({Key? key, required this.api, required this.handler})
      : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = widget.handler._player;

    // Set a sequence of audio sources that will be played by the audio player.
    // _audioPlayer
    //     .setAudioSource(ConcatenatingAudioSource(children: [
    //   AudioSource.uri(Uri.parse(
    //       "https://archive.org/download/IGM-V7/IGM%20-%20Vol.%207/25%20Diablo%20-%20Tristram%20%28Blizzard%29.mp3")),
    //   AudioSource.uri(Uri.parse(
    //       "https://archive.org/download/igm-v8_202101/IGM%20-%20Vol.%208/15%20Pokemon%20Red%20-%20Cerulean%20City%20%28Game%20Freak%29.mp3")),
    //   AudioSource.uri(Uri.parse(
    //       "https://scummbar.com/mi2/MI1-CD/01%20-%20Opening%20Themes%20-%20Introduction.mp3")),
    // ]))
    //     .catchError((error) {
    //   // catch load errors: 404, invalid url ...
    //   print("An error occured $error");
    // });
  }

  Widget _playerButton(PlayerState? playerState, {double size = 30}) {
    play() {
      InheritedSongWrapperState wrapper = InheritedSongWrapper.of(context);
      print("?????????????????");
      print(widget.handler.queue.value.toString());
      print(wrapper.mediaLink);
      print(wrapper.id.toString());
      print(wrapper.name);

      if (wrapper.mediaLink != "") {
        print('wrapper.mediaLink');
        return _audioPlayer.play();
      }
    }

    // 1
    final processingState = playerState?.processingState;

    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      // 2
      return Container(
        margin: const EdgeInsets.all(8.0),
        width: size,
        height: size,
        child: const CircularProgressIndicator(),
      );
    } else if (_audioPlayer.playing != true) {
      // 3
      return IconButton(
        icon: const Icon(Icons.play_arrow),
        iconSize: size,
        onPressed: play,
      );
    } else if (processingState != ProcessingState.completed) {
      // 4
      return IconButton(
        icon: const Icon(Icons.pause),
        iconSize: size,
        onPressed: _audioPlayer.pause,
      );
    } else {
      // 5

      return IconButton(
        icon: const Icon(Icons.replay),
        iconSize: size,
        onPressed: () => _audioPlayer.seek(Duration.zero,
            index: _audioPlayer.effectiveIndices!.first),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    InheritedSongWrapperState wrapper = InheritedSongWrapper.of(context);
    // if (wrapper.id != '') {
    //   var api = widget.api.getAPI();

    //   startStream() async {
    //     var response = await api.files
    //         .get(wrapper.id, $fields: 'webContentLink') as ga.File;

    //     print(response.webContentLink);

    //   }

    //   startStream();
    // }
    return Scaffold(
      body: Center(
        child: StreamBuilder<PlayerState>(
          stream: _audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 300,
                      height: 100,
                      child: ListTile(
                          leading: _playerButton(playerState),
                          title: Text(wrapper.name),
                          subtitle: Text(wrapper.parentName),
                          trailing: const Icon(Icons.album))),
                ]);
          },
        ),
      ),
    );
  }

  @override
  void dispose() async {
    await _audioPlayer.dispose();
    super.dispose();
  }
}

// class BufferAudioSource extends StreamAudioSource {
//   final List<int> _buffer;

//   BufferAudioSource(this._buffer, id) : super(tag: id);

//   @override
//   Future<StreamAudioResponse> request([int? start, int? end]) async {
//     // Returning the stream audio response with the parameters
//     return StreamAudioResponse(
//       sourceLength: _buffer.length,
//       contentLength: (start ?? 0) - (end ?? _buffer.length),
//       offset: start ?? 0,
//       stream: Stream.fromIterable([_buffer.sublist(start ?? 0, end)]),
//       contentType: 'audio/wav',
//     );
//   }
// }
