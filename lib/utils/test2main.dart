import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyScrollingScreen(),
    );
  }
}

class MyScrollingScreen extends StatelessWidget {
  final ScrollController parentController = ScrollController();
  final ScrollController childController = ScrollController();

  MyScrollingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nested ScrollViews'),
      ),
      body: NotificationListener<ScrollEndNotification>(
        onNotification: (notification) {
          // 子ScrollViewがスクロールし終わったら、親ScrollViewもスクロールする
          if (notification.depth == 0) {
            parentController.animateTo(
              childController.offset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          return true;
        },
        child: SingleChildScrollView(
          controller: parentController,
          child: Column(
            children: [
              // ここに親ScrollViewのコンテンツを配置

              SizedBox(
                height: 300, // 例として高さ300の領域を確保
                child: SingleChildScrollView(
                  controller: childController,
                  scrollDirection: Axis.horizontal,
                  child: const Row(
                    children: [
                      // ここに子ScrollViewのコンテンツを配置
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
