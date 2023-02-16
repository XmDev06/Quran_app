import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets.dart';

import 'package:just_audio/just_audio.dart';

class SuralarDetail extends StatefulWidget {
  late int suraId;
  SuralarDetail({Key? key, required this.suraId}) : super(key: key);

  @override
  _SuralarDetailState createState() => _SuralarDetailState();
}

class SuralarDetailModel {
  String text;
  String audio;

  SuralarDetailModel({required this.text, required this.audio});

  factory SuralarDetailModel.fromJson(Map<String, dynamic> json) {
    return SuralarDetailModel(
      text: json['text'],
      audio: json['audioSecondary'][0],
    );
  }
}

class SuralarDetailModelUz {
  String text;

  SuralarDetailModelUz({required this.text});

  factory SuralarDetailModelUz.fromJson(Map<String, dynamic> json) {
    return SuralarDetailModelUz(text: json['text']);
  }
}

class _SuralarDetailState extends State<SuralarDetail> {
  late Future<List<SuralarDetailModelUz>> futureSuralarDetailUz;
  late Future<List<SuralarDetailModel>> futureSuralarDetail;
  late AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource playlist;
  late int suraId;

  late String title;

  late String apiUrl;
  late String apiUz;

  Future<List<SuralarDetailModel>> fetchSuralarDetail() async {
    var response = await http.get(Uri.parse(apiUrl));
    title = json.decode(response.body)['data']['englishName'];
    setState(() {
      title = title;
    });
    return (json.decode(response.body)['data']['ayahs'] as List)
        .map((e) => SuralarDetailModel.fromJson(e))
        .toList();
  }

  Future<List<SuralarDetailModelUz>> fetchSuralarDetailUz() async {
    var response = await http.get(Uri.parse(apiUz));
    return (json.decode(response.body)['data']['ayahs'] as List)
        .map((e) => SuralarDetailModelUz.fromJson(e))
        .toList();
  }

  Future<void> shuffle() async {
    await _audioPlayer.setShuffleModeEnabled(false);
  }

  void initState() {
    super.initState();
    setState(() {
      title = "Suralar";
      suraId = (widget.suraId.toInt() + 1) as int;
      apiUrl =
          "http://api.alquran.cloud/v1/surah/${suraId.toString()}/ar.alafasy";
      apiUz = "http://api.alquran.cloud/v1/surah/${suraId.toString()}/uz.sodik";
    });

    futureSuralarDetailUz = fetchSuralarDetailUz();
    futureSuralarDetail = fetchSuralarDetail();

    // Set a sequence of audio sources that will be played by the audio player.
    playlist = ConcatenatingAudioSource(children: []);
    _audioPlayer = AudioPlayer();
    _audioPlayer.setAudioSource(playlist).catchError((error) {
      print("An error occured $error");
    });
    shuffle();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _playerButton(PlayerState playerState) {
    // 1
    final processingState = playerState.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      // 2
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (_audioPlayer.playing != true) {
      // 3
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 40.0,
        onPressed: _audioPlayer.play,
      );
    } else if (processingState != ProcessingState.completed) {
      // 4
      return IconButton(
        icon: Icon(Icons.pause),
        iconSize: 40.0,
        onPressed: _audioPlayer.pause,
      );
    } else {
      // 5
      return IconButton(
        icon: Icon(Icons.replay),
        iconSize: 40.0,
        onPressed: () => _audioPlayer.seek(Duration.zero,
            index: _audioPlayer.effectiveIndices?.first),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.795;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          title: Row(
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 11,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: FutureBuilder<List<SuralarDetailModel>>(
                  future: futureSuralarDetail,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<SuralarDetailModel> ayahs =
                          snapshot.data as List<SuralarDetailModel>;
                      Future<void> addM(index) async {
                        await playlist.add(
                            AudioSource.uri(Uri.parse(ayahs[index].audio)));
                      }

                      for (var i = 0; i < ayahs.length; i++) {
                        addM(i);
                      }
                      return ListView.builder(
                        itemCount: ayahs.length,
                        itemBuilder: (context, index) {
                          late Color cardColor;
                          if (_audioPlayer.currentIndex == index) {
                            cardColor = Color(0xFFBFDFF9);
                          } else {
                            cardColor = Colors.white;
                          }
                          return Card(
                            color: cardColor,
                            child: InkWell(
                                onTap: () async {
                                  if (_audioPlayer.playing != true &&
                                      _audioPlayer.currentIndex == index) {
                                    _audioPlayer.play();
                                  } else if (_audioPlayer.playing != true) {
                                    await _audioPlayer.seek(Duration.zero,
                                        index: index);
                                    _audioPlayer.play();
                                  } else if (_audioPlayer.currentIndex ==
                                      index) {
                                    await _audioPlayer.pause();
                                  } else {
                                    await _audioPlayer.seek(Duration.zero,
                                        index: index);
                                    _audioPlayer.play();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 30.0,
                                      bottom: 30.0,
                                      left: 15.0,
                                      right: 15.0),
                                  child: Row(
                                    children: [
                                      Container(
                                          width: c_width,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  Text(
                                                    ayahs[index]
                                                        .text
                                                        .toString(),
                                                    style:
                                                        TextStyle(fontSize: 18),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                  SizedBox(height: 15),
                                                  FutureBuilder<
                                                      List<
                                                          SuralarDetailModelUz>>(
                                                    future:
                                                        futureSuralarDetailUz,
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        List<SuralarDetailModelUz>
                                                            ayahsUz =
                                                            snapshot.data as List<
                                                                SuralarDetailModelUz>;
                                                        return Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            Text(
                                                              (index + 1)
                                                                      .toString() +
                                                                  ". " +
                                                                  ayahsUz[index]
                                                                      .text
                                                                      .toString(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            )
                                                          ],
                                                        );
                                                      }
                                                      if (snapshot.hasError) {
                                                        print(snapshot.error
                                                            .toString());
                                                        return Text(
                                                            'UzTranslateError');
                                                      }
                                                      return Text("");
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),
                                    ],
                                  ),
                                )),
                          );
                        },
                      );
                    }
                    if (snapshot.hasError) {
                      print(snapshot.error.toString());
                      return Text('error');
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width * 100,
                color: Colors.blue,
                child: StreamBuilder<PlayerState>(
                  stream: _audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final playerState = snapshot.data;
                      return _playerButton(playerState!);
                    } else {
                      return Text("");
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
