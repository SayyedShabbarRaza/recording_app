import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioRecorder audioRecorder = AudioRecorder();
  var isRecording = false;
  var isPlaying = false;
  final AudioPlayer audioPlayer = AudioPlayer();
  String? recPath;
  recording() async {
    if (isRecording) {
      //When to stop
      String? filePath = await audioRecorder.stop();
      if (filePath != null) {
        setState(() {
          isRecording = false;
          recPath = filePath;
        });
      }
    } else {
      //When to start
      if (await audioRecorder.hasPermission()) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String filePath = path.join(appDir.path, "voice.wav");
        await audioRecorder.start(const RecordConfig(echoCancel: true),
            path: filePath);
        setState(() {
          isRecording = true;
          recPath = null;
        });
      }
      print('Have no permissions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Audio'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => recording(),
        child: Icon(isRecording ? Icons.stop : Icons.mic),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (recPath != null)
            Center(
              child: ElevatedButton(
                  onPressed: () async {
                    if (audioPlayer.playing) {
                      audioPlayer.stop();
                      setState(() {
                        isPlaying = false;
                      });
                    } else {
                      await audioPlayer.setFilePath(recPath!);
                      audioPlayer.play();
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                  child: Text(isPlaying ? 'Stop' : 'Play recording')),
            ),
          if (recPath == null)
            const Center(child: Text('No recording was found.'))
        ],
      ),
    );
  }
}
