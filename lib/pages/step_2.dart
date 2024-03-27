import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_to_frame_color_image/src/rust/api/simple.dart';

class Step2 extends StatefulWidget {
  const Step2({super.key});

  @override
  State<Step2> createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  final selectedPath = Get.arguments;
  var gettingSeconds = true;
  late final videoSeconds;
  var errorText = '';

  final interval = TextEditingController(text: '1');
  final pixelWidth = TextEditingController(text: '1');
  final imageHeight = TextEditingController(text: '50');

  @override
  void initState() {
    super.initState();
    getVideoSeconds();
  }

  Future<void> getVideoSeconds() async {
    videoSeconds = await getVideoSecondsHelper(path: selectedPath);

    setState(() {
      gettingSeconds = false;
    });
  }

  void toStep3() {
    if (validateInterval(interval.text) &&
        validate(pixelWidth.text) &&
        validate(imageHeight.text)) {
      final intervalValue = int.parse(interval.text);
      final pixelWidthValue = int.parse(pixelWidth.text);
      final imageHeightValue = int.parse(imageHeight.text);

      Get.toNamed('/step_3', arguments: [
        selectedPath,
        intervalValue,
        pixelWidthValue,
        imageHeightValue,
        videoSeconds
      ]);
    }
  }

  bool validateInterval(String value) {
    if (!validate(value)) return false;
    if (int.parse(value) < videoSeconds) return true;

    setState(() {
      errorText = 'Interval cannot be longer than or equal to the video length';
    });
    return false;
  }

  bool validate(String value) {
    var regex = RegExp(r'^[1-9][0-9]*$');

    if (regex.firstMatch(value)?.group(0) == value) {
      final n = num.tryParse(value);
      if (n == null || n <= 0) {
        setState(() {
          errorText = 'Make sure all values are numbers greater than zero';
        });
        return false;
      }

      setState(() {
        errorText = '';
      });
      return true;
    }

    setState(() {
      errorText = 'Make sure all values are numbers greater than zero';
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video to Frame Color Image')),
      body: Center(
        child: SizedBox(
          width: min(MediaQuery.of(context).size.width * 0.8, 400),
          height: MediaQuery.of(context).size.height,
          child: gettingSeconds
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text('Fetching video length...'),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: interval,
                      decoration: InputDecoration(
                        labelText: "Frame interval in seconds",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: pixelWidth,
                      decoration: InputDecoration(
                        labelText: "Width per column in pixels",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: imageHeight,
                      decoration: InputDecoration(
                        labelText: "Height of image in pixels",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    errorText != ''
                        ? Text(errorText,
                            style: const TextStyle(color: Colors.red))
                        : const SizedBox.shrink(),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: toStep3,
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
