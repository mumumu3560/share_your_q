import 'package:flutter/material.dart';

import 'package:share_your_q/river_test/x/my_x_widget.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_your_q/river_test/xxx/my_xxx_widget.dart';

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
      
      home: Scaffold(
        body: Center(
          child: Column(
            children: const [
              MyXWidget(),
              MyXXXWidget(),
            ],
          ),
        ),

      ),
    );
  }

  
}
