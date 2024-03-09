import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('コメントセクションデモ'),
        ),
        body: Center(
          child: ElevatedButton(
            child: Text('コメントを表示'),
            onPressed: () => showComments(context),
          ),
        ),
      ),
    );
  }

  void showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 0.9,
          child: CommentNavigator(),
        );
      },
    );
  }
}

class CommentNavigator extends StatelessWidget {
  const CommentNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: 'comments',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case 'comments':
            builder = (BuildContext context) => CommentsPage();
            break;
          case 'replies':
            builder = (BuildContext context) => RepliesPage();
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}

class CommentsPage extends StatelessWidget {
  const CommentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('コメント')),
      body: Center(
        child: ElevatedButton(
          child: Text('返信を表示'),
          onPressed: () => Navigator.pushNamed(context, 'replies'),
        ),
      ),
    );
  }
}

class RepliesPage extends StatelessWidget {
  const RepliesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('返信')),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // ここに外側をタップしたときの処理を書く
          // 例えば、一つ前のページに戻る
          Navigator.pop(context);
        },
        child: Center(
          child: Text('返信内容'),
        ),
      ),
    );
  }
}
