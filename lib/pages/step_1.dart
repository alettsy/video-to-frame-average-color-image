import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Step1 extends StatefulWidget {
  const Step1({super.key});

  @override
  State<Step1> createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  var selectedPath = '';

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['mp4', 'flv', 'avi'],
    );

    if (result != null) {
      setState(() {
        selectedPath = result.files.single.path!;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: pickFile,
                child: const Text('Select video'),
              ),
              const SizedBox(height: 25),
              const Text(
                'Video path selected:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(selectedPath),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: selectedPath != ''
                        ? () => Get.toNamed('/step_2', arguments: selectedPath)
                        : null,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
