import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_to_frame_color_image/pages/step_2.dart';
import 'package:video_to_frame_color_image/pages/step_3.dart';
import 'package:video_to_frame_color_image/src/rust/frb_generated.dart';

import 'home.dart';
import 'pages/step_1.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomePage()),
        GetPage(name: '/step_1', page: () => const Step1()),
        GetPage(name: '/step_2', page: () => const Step2()),
        GetPage(name: '/step_3', page: () => const Step3()),
      ],
    );
  }
}
