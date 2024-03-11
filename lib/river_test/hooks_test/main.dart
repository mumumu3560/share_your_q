import 'package:flutter/material.dart';
import 'package:share_your_q/river_test/hooks_test/page_1.dart';
import 'package:share_your_q/river_test/hooks_test/page_2.dart';
import 'page_1.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'タイトル',
      
      home: Page2(),
    );
  }

  
}
