import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class Step2 extends StatefulWidget {
  const Step2({super.key});

  @override
  State<Step2> createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  var selectedPath = Get.arguments;
  var errorText = '';

  var interval = TextEditingController(text: '1');
  var pixelWidth = TextEditingController(text: '1');
  var imageHeight = TextEditingController(text: '50');

  void toStep3() {
    if (validate(interval.text) &&
        validate(pixelWidth.text) &&
        validate(imageHeight.text)) {
      var intervalValue = int.parse(interval.text);
      var pixelWidthValue = int.parse(pixelWidth.text);
      var imageHeightValue = int.parse(imageHeight.text);

      Get.toNamed('/step_3', arguments: [
        selectedPath,
        intervalValue,
        pixelWidthValue,
        imageHeightValue
      ]);
    }
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
          width: MediaQuery.of(context).size.width / 2,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: interval,
                decoration:
                    const InputDecoration(labelText: "Interval in seconds"),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              TextField(
                controller: pixelWidth,
                decoration: const InputDecoration(labelText: "Width per pixel"),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              TextField(
                controller: imageHeight,
                decoration: const InputDecoration(labelText: "Height of image"),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              errorText != ''
                  ? Text(errorText, style: const TextStyle(color: Colors.red))
                  : const SizedBox.shrink(),
              const SizedBox(height: 25),
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
