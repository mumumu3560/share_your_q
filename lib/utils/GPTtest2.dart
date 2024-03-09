import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (context) => Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (context) => FirstPage(),
              ),
            ),
          ),
          child: Text('Show modal'),
        ),
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // モーダルを閉じる際にrootNavigatorを使用
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          icon: Icon(Icons.close),
        ),
        title: Text('First Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SecondPage(),
          )),
          child: Text('Go to Second Page'),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Center(
        child: Text('This is the second page'),
      ),
    );
  }
}
