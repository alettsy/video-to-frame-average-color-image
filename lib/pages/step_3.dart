import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_to_frame_color_image/src/rust/api/simple.dart';
import 'package:video_to_frame_color_image/src/rust/frb_generated.dart';

class Step3 extends StatefulWidget {
  const Step3({super.key});

  @override
  State<Step3> createState() => _Step3State();
}

class _Step3State extends State<Step3> {
  var generating = true;
  var saved = false;

  @override
  void initState() {
    super.initState();
    var parameters = Get.arguments;
    generate(
      parameters[0],
      parameters[1],
      parameters[2],
      parameters[3],
    );
  }

  void setGenerating(bool value) {
    setState(() {
      generating = value;
    });
  }

  Future<void> deleteOldFiles() async {
    final temp = await getTemporaryDirectory();

    if (temp != null) {
      final outputFile = File('${temp.path}/output.jpg');
      final frameFile = File('${temp.path}/frame.jpg');

      if (outputFile.existsSync()) {
        outputFile.deleteSync();
      }

      if (frameFile.existsSync()) {
        frameFile.deleteSync();
      }
    }
  }

  Future<void> generate(
      String path, int interval, int pixelWidth, int height) async {
    try {
      await deleteOldFiles();

      await Isolate.run(() async {
        await RustLib.init();
        generateImage(
          path: path,
          interval: interval,
          pixelWidth: pixelWidth,
          height: height,
        );
      });
    } finally {
      setGenerating(false);
    }
  }

  Future<void> goHome(BuildContext context) async {
    if (!saved) {
      final choice = await confirmDialog(context);
      if (choice == null || !choice) {
        return;
      }
    }

    Get.offAllNamed('/');
  }

  Future<bool?> confirmDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restart'),
          content:
              const Text('Are you sure you want to restart without saving?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void save(File image) async {
    final downloads = await getDownloadsDirectory();

    if (downloads != null) {
      final file = File('${downloads.path}/output.jpg');

      await file.writeAsBytes(image.readAsBytesSync());

      setState(() {
        saved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video to Frame Color Image')),
      body: Center(
        child: SizedBox(
          width: min(MediaQuery.of(context).size.width * 0.8, 400),
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              generating
                  ? const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Generating your image...'),
                      ],
                    )
                  : FutureBuilder<File>(
                      future: getTemporaryDirectory().then(
                          (directory) => File(directory.path + "\\output.jpg")),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return Column(
                            children: [
                              Image.file(snapshot.data!, fit: BoxFit.scaleDown,
                                  errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'There was an error loading the image',
                                );
                              }),
                              const SizedBox(height: 50),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => goHome(context),
                                    child: const Text('Restart'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => save(snapshot.data!),
                                    child:
                                        Text(saved ? 'Saved!' : 'Save Image'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          return const Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 10),
                              Text('Loading your image...'),
                            ],
                          );
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
