import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Page1 extends HookWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    final count = useState(5);

    final text = "Count: ${count.value}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 1'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(text),
            ElevatedButton(
              onPressed: () {
                count.value++;
              },
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}