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
      title: 'YouTube Downloader GUI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        key: Key("app"),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required Key key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? ytUrl;
  bool dlVid = true;
  bool dlAud = false;
  bool dlThumb = false;
  TimeOfDay? timeStart;
  TimeOfDay? timeEnd;
  String qualVid = '1080p';
  String qualAud = '192k';

  List<String> qualVidOptions = ['480p', '720p', '1080p', '2K', '4K'];
  List<String> qualAudOptions = ['64k', '128k', '192k', '256k', '320k'];

  void download() async {
    if (ytUrl == null || !ytUrl!.contains('youtube.com')) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
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
    if (timeStart != null && timeEnd != null) {
      command +=
          ' --postprocessor-args "-ss ${timeStart!.format(context)} -to ${timeEnd!.format(context)}"';
    }
    Shell shell = Shell();
    await shell.run(command);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Downloader GUI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (value) => ytUrl = value,
              decoration: const InputDecoration(
                labelText: 'YouTube Video URL',
              ),
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: dlVid,
                  onChanged: (bool? value) {
                    setState(() {
                      dlVid = value!;
                    });
                  },
                ),
                const Text('Video'),
                Checkbox(
                  value: dlAud,
                  onChanged: (bool? value) {
                    setState(() {
                      dlAud = value!;
                    });
                  },
                ),
                const Text('Audio'),
                Checkbox(
                  value: dlThumb,
                  onChanged: (bool? value) {
                    setState(() {
                      dlThumb = value!;
                    });
                  },
                ),
                const Text('Thumbnail'),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onTap: () async {
                      TimeOfDay? time = await showTimePicker(
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
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    onTap: () async {
                      TimeOfDay? time = await showTimePicker(
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
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (String? value) {
                setState(() {
                  qualVid = value!;
                });
              },
            ),
            DropdownButton(
              value: qualAud,
              items: qualAudOptions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (String? value) {
                setState(() {
                  qualAud = value!;
                });
              },
            ),
            ElevatedButton(
              onPressed: download,
              child: const Text('Download'),
            ),
          ],
        ),
      ),
    );
  }
}
