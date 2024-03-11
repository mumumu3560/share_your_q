import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_your_q/river_test/x/my_x2_widget.dart';
import 'package:share_your_q/river_test/x/x.dart';
import 'package:share_your_q/river_test/xxx/my_xxx_widget.dart';
import 'package:share_your_q/utils/various.dart';

class MyXWidget extends ConsumerWidget {
  const MyXWidget({super.key});

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

    final button2 = ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyX2Widget())
        );
        
      },
      child: const Text("ページ遷移"),
    );

    return Column(
      children: [
        Text("$sx"),
        Text("$sListen "),
        button, 

        button2,
      ],
    );
  }
}