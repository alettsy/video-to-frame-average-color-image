import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              const Text('Welcome to the generator!',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Text(
                'This app takes in a video path, and some settings, '
                'then generates an image based on the average color of each '
                'frame at each interval',
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
