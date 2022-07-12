// import 'package:audioplayers/audio_cache.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jaagran/utils/size_config.dart';

class CustomAudioPlayer extends StatefulWidget {
  final String filePath;
  final bool isLocal;

  const CustomAudioPlayer({this.filePath, this.isLocal = false});

  @override
  _CustomAudioPlayer createState() => _CustomAudioPlayer();
}

class _CustomAudioPlayer extends State<CustomAudioPlayer> {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  // AudioPlayer advancedPlayer;
  // AudioCache audioCache;
  String currentDuration = "       ";

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  void initPlayer() {
    /*  advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);

    advancedPlayer.durationHandler = (d) => setState(() {
          _duration = d;
        });

    advancedPlayer.positionHandler = (p) => setState(() {
          _position = p;
        });

    advancedPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        currentDuration = d.toString().split(".")[0];
      });
    }); */
  }

  Widget slider() {}

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    // advancedPlayer.seek(newDuration);
  }

  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig _sf = SizeConfig.getInstance(context);
    return Row(
      children: [
        InkWell(
          onTap: () {
            if (isPlaying) {
              isPlaying = false;
              // advancedPlayer.pause();
              setState(() {});
            } else {
              isPlaying = true;
              // advancedPlayer.play(widget.filePath, isLocal: widget.isLocal);
              setState(() {});
            }
          },
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Theme.of(context).accentColor,
            size: _sf.scaleSize(30),
          ),
        ),
        Expanded(
          child: Slider(
              activeColor: Colors.black,
              inactiveColor: Colors.pink,
              value: _position.inSeconds.toDouble(),
              min: 0.0,
              max: _duration.inSeconds.toDouble(),
              onChanged: (double value) {
                setState(() {
                  seekToSecond(value.toInt());
                  value = value;
                });
              }),
        ),
        Text(currentDuration),
      ],
    );
    ;
  }

  @override
  void dispose() {
    // advancedPlayer.dispose();
    super.dispose();
  }
}
