import 'dart:async';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'PlayingControls.dart';
import 'PositionSeekWidget.dart';
import 'SongsSelector.dart';
import 'lyrics/lyric_controller.dart';
import 'lyrics/lyric_util.dart';
import 'lyrics/lyric_widget.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen>
    with TickerProviderStateMixin {
  //final AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer();
  AssetsAudioPlayer? _assetsAudioPlayer;
  LyricController? lyricsController;
  int lyricsIndex = 0;
  bool showSelect = false;
  final List<StreamSubscription> _subscriptions = [];
  final audios = <Audio>[
    Audio(
      'assets/audios/Believer.mp3',
      metas: Metas(
        id: 'Believer',
        title: 'Believer',
        artist: 'ABC XYZ',
        album: 'BelieverAlbum',
        image: const MetasImage.network(
            'https://static.radio.fr/images/broadcasts/cb/ef/2075/c300.png'),
      ),
    ),
    Audio(
      'assets/audios/music.mp3',
      metas: Metas(
        id: 'Music',
        title: 'Music',
        artist: 'XYZ ABC',
        album: 'MusicAlbum',
        image: const MetasImage.asset('assets/images/country.jpg'),
      ),
    ),
    Audio(
      'assets/audios/Sheeran.mp3',
      metas: Metas(
        id: 'Sheeran',
        title: 'Sheeran',
        artist: 'Ed Sheeran',
        album: 'SheeranAlbum',
        image: const MetasImage.network(
            'https://99designs-blog.imgix.net/blog/wp-content/uploads/2017/12/attachment_68585523.jpg'),
      ),
    ),
  ];

  List<String> lyrics = [];

  @override
  void initState() {
    super.initState();
    lyricsAdd();
    Future.delayed(const Duration(milliseconds: 500), (() {}));
  }

  lyricsAdd() async {
    var audio1 = await rootBundle.loadString("assets/audios/Believer.lrc");
    var audio2 = await rootBundle.loadString("assets/audios/music.lrc");
    var audio3 = await rootBundle.loadString("assets/audios/Sheeran.lrc");
    lyrics.addAll([audio1, audio2, audio3]);
    sliderLyrics();
    _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
    _subscriptions.add(_assetsAudioPlayer!.playlistAudioFinished.listen((data) {
      if (kDebugMode) {
        print('playlistAudioFinished : $data');
      }
    }));
    _subscriptions.add(_assetsAudioPlayer!.audioSessionId.listen((sessionId) {
      if (kDebugMode) {
        print('audioSessionId : $sessionId');
      }
    }));
    _assetsAudioPlayer!.realtimePlayingInfos.listen((event) async {
      lyricsController!.progress = event.currentPosition;
    });
    setState(() {});
    openPlayer();
  }

  void openPlayer() async {
    await _assetsAudioPlayer!.open(
      Playlist(audios: audios, startIndex: 0),
      showNotification: true,
      autoStart: true,
      notificationSettings:
      const NotificationSettings(
        stopEnabled: false,
      ),
    );
  }

  @override
  void dispose() {
    _assetsAudioPlayer!.dispose();
    if (kDebugMode) {
      print('dispose');
    }
    super.dispose();
  }

  Audio find(List<Audio> source, String fromPath) {
    return source.firstWhere((element) => element.path == fromPath);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: _assetsAudioPlayer == null
            ? const Center(
                child: Text("Loading..."),
              )
            : SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: PageView(
                              children: [
                                StreamBuilder<Playing?>(
                                    stream: _assetsAudioPlayer!.current,
                                    builder: (context, playing) {
                                      if (playing.data != null) {
                                        final myAudio = find(
                                            audios,
                                            playing.data!.audio
                                                .assetAudioPath);
                                        if (kDebugMode) {
                                          print(playing
                                              .data!.audio.assetAudioPath);
                                        }
                                        return Padding(
                                          padding:
                                              const EdgeInsets.all(50.0),
                                          child: Neumorphic(
                                            style: const NeumorphicStyle(
                                              depth: 8,
                                              surfaceIntensity: 1,
                                              shape:
                                                  NeumorphicShape.concave,
                                              boxShape: NeumorphicBoxShape
                                                  .circle(),
                                            ),
                                            child: myAudio.metas.image
                                                        ?.path ==
                                                    null
                                                ? const SizedBox()
                                                : myAudio.metas.image
                                                            ?.type ==
                                                        ImageType.network
                                                    ? Image.network(
                                                        myAudio.metas.image!
                                                            .path,
                                                        height: 150,
                                                        width: 150,
                                                        fit: BoxFit.contain,
                                                      )
                                                    : Image.asset(
                                                        myAudio.metas.image!
                                                            .path,
                                                        height: 150,
                                                        width: 150,
                                                        fit: BoxFit.contain,
                                                      ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    }),
                                LyricWidget(
                                  size: Size(
                                      double.infinity,
                                      MediaQuery.of(context).size.height *
                                          0.25),
                                  currLyricStyle: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  lyricStyle: const TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  draggingLyricStyle: const TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  lyrics: LyricUtil.formatLyric(
                                      lyrics[lyricsIndex], false),
                                  enableDrag: true,
                                  lyricGap: 20,
                                  controller: lyricsController,
                                  lyricMaxWidth: double.infinity,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          _assetsAudioPlayer!.builderCurrent(
                              builder: (context, Playing? playing) {
                            return Column(
                              children: <Widget>[
                                _assetsAudioPlayer!.builderLoopMode(
                                  builder: (context, loopMode) {
                                    return PlayerBuilder.isPlaying(
                                        player: _assetsAudioPlayer!,
                                        builder: (context, isPlaying) {
                                          return PlayingControls(
                                            loopMode: loopMode,
                                            isPlaying: isPlaying,
                                            isPlaylist: true,
                                            toggleLoop: () {
                                              _assetsAudioPlayer!.toggleLoop();
                                            },
                                            onPlay: () {
                                              _assetsAudioPlayer!.playOrPause();
                                            },
                                            onNext: () {
                                              _assetsAudioPlayer!.next(
                                                keepLoopMode: true,
                                                stopIfLast: false,
                                              );
                                              if (lyricsIndex >= 2) {
                                                lyricsIndex = 0;
                                                setState(() {});
                                              } else {
                                                lyricsIndex++;
                                                setState(() {});
                                              }
                                              sliderLyrics();
                                            },
                                            onPrevious: () {
                                              _assetsAudioPlayer!.previous();
                                              if (lyricsIndex <= 0) {
                                                lyricsIndex = 2;
                                                setState(() {});
                                              } else {
                                                lyricsIndex--;
                                                setState(() {});
                                              }
                                              sliderLyrics();
                                            },
                                          );
                                        });
                                  },
                                ),
                                _assetsAudioPlayer!.builderRealtimePlayingInfos(
                                    builder:
                                        (context, RealtimePlayingInfos? infos) {
                                  if (infos == null) {
                                    return const SizedBox();
                                  }
                                  //print('infos: $infos');
                                  return Column(
                                    children: [
                                      PositionSeekWidget(
                                        currentPosition: infos.currentPosition,
                                        duration: infos.duration,
                                        seekTo: (to) {
                                          _assetsAudioPlayer!.seek(to);
                                        },
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          NeumorphicButton(
                                            onPressed: () {
                                              _assetsAudioPlayer!.seekBy(
                                                  const Duration(seconds: -10));
                                            },
                                            child: const Text('-10'),
                                          ),
                                          const SizedBox(
                                            width: 12,
                                          ),
                                          NeumorphicButton(
                                            onPressed: () {
                                              _assetsAudioPlayer!.seekBy(
                                                  const Duration(seconds: 10));
                                            },
                                            child: const Text('+10'),
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                                }),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: _assetsAudioPlayer!.builderCurrent(
                          builder: (BuildContext context, Playing? playing) {
                        return SongsSelector(
                          audios: audios,
                          onPlaylistSelected: (myAudios) {
                            _assetsAudioPlayer!.open(
                              Playlist(audios: myAudios),
                              showNotification: true,
                              headPhoneStrategy:
                                  HeadPhoneStrategy.pauseOnUnplugPlayOnPlug,
                              audioFocusStrategy:
                                  const AudioFocusStrategy.request(
                                      resumeAfterInterruption: true),
                              notificationSettings:
                              const NotificationSettings(
                                stopEnabled: false,
                              ),
                            );
                          },
                          onSelected: (myAudio) async {
                            try {
                              await _assetsAudioPlayer!.open(
                                myAudio,
                                autoStart: true,
                                showNotification: true,
                                playInBackground: PlayInBackground.enabled,
                                audioFocusStrategy:
                                    const AudioFocusStrategy.request(
                                        resumeAfterInterruption: true,
                                        resumeOthersPlayersAfterDone: true),
                                headPhoneStrategy:
                                    HeadPhoneStrategy.pauseOnUnplug,
                                notificationSettings:
                                    const NotificationSettings(
                                  stopEnabled: false,
                                ),
                              );
                            } catch (e) {
                              if (kDebugMode) {
                                print(e);
                              }
                            }
                          },
                          playing: playing,
                        );
                      }),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future sliderLyrics() async {
    try {
      if (lyricsController != null) {
        lyricsController!.dispose();
      }
      lyricsController = LyricController(
          vsync: this, draggingTimerDuration: const Duration(milliseconds: 1));
      lyricsController!.addListener(() {
        if (showSelect != lyricsController!.isDragging) {
          showSelect = lyricsController!.isDragging;
          _assetsAudioPlayer!.seek(lyricsController!.draggingProgress!);
          setState(() {});
        }
      });
    } catch (e) {
      debugPrint("Error $e");
    }
  }
}
