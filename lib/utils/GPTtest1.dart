import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        // ここでコメント欄のUIをカスタマイズします
        return Container(
          height: MediaQuery.of(context).size.height * 0.75, // 画面の75%の高さ
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("コメント", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: 10, // 仮のコメント数
                  itemBuilder: (context, index) {
                    // 仮のコメント表示。実際にはデータに基づいてリストを構築します。
                    return ListTile(
                      leading: Icon(Icons.account_circle),
                      title: Text("ユーザー$index"),
                      subtitle: Text("これはコメントの内容です。"),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Demo'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.comment),
          onPressed: _showCommentSheet,
        ),
      ],
    ),
    body: Center(
      child: Text('コメントアイコンをタップしてください'),
    ),
  );
}
}
