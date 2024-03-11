import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_your_q/river_test/x/x.dart';
import 'package:share_your_q/river_test/xxx/my_xxx_widget.dart';
import 'package:share_your_q/utils/various.dart';

class MyX2Widget extends ConsumerWidget {
  const MyX2Widget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final sx = ref.watch(s1NotifierProvider);

    final sListen = ref.watch(s1NotifierProvider);

    ref.listen(
      s1NotifierProvider, 
      (previous, next) {
        print("previous: $previous, next: $next");

       }
    );


    final button = ElevatedButton(
      onPressed: () {
        final notifier = ref.read(s1NotifierProvider.notifier);
        notifier.updateState();
      },
      child: const Text('Increment'),
    );

    final popButton = ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text("戻る"),
    );


    return Material(
      child: Column(
        children: [
          Text("$sx"),
          Text("$sListen "),
          button, 

          popButton,
        ],
      ),
    );
  }
}