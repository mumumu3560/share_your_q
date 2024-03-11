import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyXWidget extends ConsumerWidget {
  const MyXWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text("ここにデータが表示");
  }
}