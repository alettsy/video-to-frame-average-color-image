import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video to Frame Average Color Image')),
      body: Center(
        child: SizedBox(
          width: min(MediaQuery.of(context).size.width * 0.8, 400),
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const Text(
                '\nThis app takes in a video path, and some settings, '
                'then generates an image based on the average color of each '
                'frame at each interval',
              ),
              const Text(
                '\nYou can save your generated image to your downloads '
                'folder at the end!',
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/step_1'),
                    child: const Text('Start'),
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
