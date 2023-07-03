import 'package:flutter/material.dart';
import 'package:process_run/cmd_run.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Downloader GUI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String ytUrl;
  bool dlVid = true;
  bool dlAud = false;
  bool dlThumb = false;
  TimeOfDay timeStart;
  TimeOfDay timeEnd;
  String qualVid = '1080p';
  String qualAud = '192k';

  List<String> qualVidOptions = ['480p', '720p', '1080p', '2K', '4K'];
  List<String> qualAudOptions = ['64k', '128k', '192k', '256k', '320k'];

  void download() async {
    if (ytUrl == null || !ytUrl.contains('youtube.com')) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text('Enter valid YouTube URL'),
        ),
      );
      return;
    }

    String command =
        'yt-dlp -f \'bestvideo[height<=${qualVid.replaceAll('p', '')}]'
        '+bestaudio/best[height<=${qualVid.replaceAll('p', '')}]\' $ytUrl';
    if (dlAud) command += ' -x --audio-format mp3 --audio-quality ${qualAud}';
    if (dlThumb) command += ' --write-thumbnail';
    if (timeStart != null && timeEnd != null)
      command +=
          ' --postprocessor-args "-ss ${timeStart.format(context)} -to ${timeEnd.format(context)}"';

    await runCmd(
        ProcessCmd(command.split(' ')[0], command.split(' ').sublist(1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Downloader GUI'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (value) => ytUrl = value,
              decoration: InputDecoration(
                labelText: 'YouTube Video URL',
              ),
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: dlVid,
                  onChanged: (bool value) {
                    setState(() {
                      dlVid = value;
                    });
                  },
                ),
                Text('Video'),
                Checkbox(
                  value: dlAud,
                  onChanged: (bool value) {
                    setState(() {
                      dlAud = value;
                    });
                  },
                ),
                Text('Audio'),
                Checkbox(
                  value: dlThumb,
                  onChanged: (bool value) {
                    setState(() {
                      dlThumb = value;
                    });
                  },
                ),
                Text('Thumbnail'),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onTap: () async {
                      TimeOfDay time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) setState(() => timeStart = time);
                    },
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Start Time',
                      hintText: timeStart?.format(context) ?? '',
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    onTap: () async {
                      TimeOfDay time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) setState(() => timeEnd = time);
                    },
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'End Time',
                      hintText: timeEnd?.format(context) ?? '',
                    ),
                  ),
                ),
              ],
            ),
            DropdownButton(
              value: qualVid,
              items: qualVidOptions
                  .map((value) => DropdownMenuItem(
                        child: Text(value),
                        value: value,
                      ))
                  .toList(),
              onChanged: (String value) {
                setState(() {
                  qualVid = value;
                });
              },
            ),
            DropdownButton(
              value: qualAud,
              items: qualAudOptions
                  .map((value) => DropdownMenuItem(
                        child: Text(value),
                        value: value,
                      ))
                  .toList(),
              onChanged: (String value) {
                setState(() {
                  qualAud = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: download,
              child: Text('Download'),
            ),
          ],
        ),
      ),
    );
  }
}
