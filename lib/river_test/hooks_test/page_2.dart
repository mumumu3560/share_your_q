import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Page2 extends HookWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    final count = useState(5);

    final text = "Count: ${count.value}";

    useEffect(() {

      debugPrint('init');

      return () {
        debugPrint('dispose');
      };

    }, []);

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