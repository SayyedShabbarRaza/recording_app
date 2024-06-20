import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var isPlaying = false;
  final AudioPlayer audioPlayer = AudioPlayer();
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  String? audioPath;

  @override
  void initState() {
    super.initState();
    initRecorder();
    audioPlayer.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    audioPlayer.dispose();
    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await recorder.openRecorder();
    isRecorderReady = true;
  }

  Future stop() async {
    if (!isRecorderReady) return;
    audioPath = await recorder.stopRecorder();
    setState(() {});
    print('Recorded audio path: $audioPath');
  }

  Future record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: 'audio');
  }

  Future playPause() async {
    if (isPlaying) {
      await audioPlayer.stop();
    } else {
      if (audioPath != null) {
        await audioPlayer.setFilePath(audioPath!);
        await audioPlayer.play();
      } else {
        print('No audio file to play');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (recorder.isRecording) {
            await stop();
          } else {
            await record();
          }
          setState(() {});
        },
        child: Icon(recorder.isRecording ? Icons.stop : Icons.mic),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await playPause();
              },
              child: Text(isPlaying ? 'Stop' : 'Play'),
            ),
          ),
          // if (audioPath != null) Text('Recorded audio path: $audioPath'),
        ],
      ),
    );
  }
}
