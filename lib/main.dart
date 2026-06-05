import 'package:flutter/material.dart';
import 'theme/futuristic_theme.dart';
import 'pages/ip_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Robot Controller",
      theme: FuturisticTheme.darkTheme,
      home: const IpPage(),
    );
  }
}
