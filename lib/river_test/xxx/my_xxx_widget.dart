import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_your_q/river_test/xxx/s3.dart';

class MyXXXWidget extends ConsumerWidget {
  const MyXXXWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final s3 = ref.watch(s3NotifierProvider);

    final button = ElevatedButton(
      onPressed: () {
        ref.read(s3NotifierProvider.notifier).updateState();
      },
      child: const Text('更新'),
    );

    final widget = s3.when(
      loading: () => const CircularProgressIndicator(),
      //どんなエラーどこでエラー
      error: (error, stackTrace) => Text('Error: $error'),
      data: (data) => Text(data),


      
    );

    return Column(
      children: [
        //Text("$s3"),
        widget,
        button,
      ],
    );
    
  }
}