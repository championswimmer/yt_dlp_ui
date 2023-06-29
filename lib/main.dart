import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('YouTube Downloader'),
        ),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: DownloadForm(),
          ),
        ),
      ),
    );
  }
}

class DownloadForm extends StatefulWidget {
  const DownloadForm({super.key});

  @override
  State<DownloadForm> createState() => _DownloadFormState();
}

class _DownloadFormState extends State<DownloadForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool dlVid = false;
  bool dlAud = false;
  bool dlThumb = false;
  List<String> videoQualityList = ['480p', '720p', '1080p', '1440p', '2160p'];
  List<String> audioQualityList = ['64k', '128k', '192k', '256k', '320k'];
  String videoQuality = '480p';
  String audioQuality = '64k';
  String timeStart = '';
  String timeEnd = '';

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Enter YouTube video URL',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter YouTube URL';
              }
              return null;
            },
          ),
          CheckboxListTile(
            title: const Text("Download Video"),
            value: dlVid,
            onChanged: (newValue) {
              setState(() {
                dlVid = newValue!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Download Audio"),
            value: dlAud,
            onChanged: (newValue) {
              setState(() {
                dlAud = newValue!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Download Thumbnail"),
            value: dlThumb,
            onChanged: (newValue) {
              setState(() {
                dlThumb = newValue!;
              });
            },
          ),
          DropdownButton<String>(
            value: videoQuality,
            onChanged: (String? newValue) {
              setState(() {
                videoQuality = newValue!;
              });
            },
            items:
                videoQualityList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          DropdownButton<String>(
            value: audioQuality,
            onChanged: (String? newValue) {
              setState(() {
                audioQuality = newValue!;
              });
            },
            items:
                audioQualityList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          // other input fields, dropdowns here
          // ...
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                handleDownload(_controller.text);
              }
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void handleDownload(String url) async {
    String cmd = 'yt-dlp ';

    if (dlVid) {
      cmd +=
          '--format "bestvideo[height<=${videoQuality.substring(0, videoQuality.length - 1)}]+bestaudio[abr<=${audioQuality.substring(0, audioQuality.length - 1)}]/best" ';
    } else if (dlAud) {
      cmd +=
          '-x --audio-quality ${audioQuality.substring(0, audioQuality.length - 1)} ';
    }

    if (dlThumb) {
      cmd += '--write-thumbnail ';
    }

    if (timeStart.isNotEmpty && timeEnd.isNotEmpty) {
      cmd += '--postprocessor-args "-ss ${timeStart} -to ${timeEnd}" ';
    }

    cmd += url;

    var shell = Shell();
    await shell.run(cmd);
  }
}
