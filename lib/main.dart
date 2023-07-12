import 'package:flutter/material.dart';
import 'dr_opti.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // not quite smooth animation on Win or MacOS
      // or try DigitalRain() without TextPainter
      home: DROpti(),
    );
  }
}
