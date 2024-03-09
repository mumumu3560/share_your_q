import 'package:flutter/material.dart';


final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(MyApp());
}

BuildContext? contextSave;
bool flagFirst = true;
BuildContext? contextStable;

int count = 0;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      navigatorObservers: [routeObserver], // ここに追加
    );
  }
}



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int now = 0;
  @override
  Widget build(BuildContext context) {

    print("ここはHomePageです");
    print(contextSave);
    print(context);
    contextStable = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(count.toString() + 'Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              //isDismissible: true, // モーダルを閉じるためのジェスチャーを無効にする
              backgroundColor: Colors.transparent, // 背景を透明にする
              builder: (context) => PopScope(
                canPop: false, // 戻るキーの動作で戻ることを一旦防ぐ
                onPopInvoked: (didPop) async {
                  now--;

                  print("----HomePage---------");
                  print("contextSave=${contextSave}");
                  print("context=${context}");
                  if (didPop) {
                    return;
                  }




                  if(!flagFirst && contextSave != null){
                    print("!=null");
                    print("contextSave=${contextSave}");
                    print("context=${context}");
                    context = contextSave!;
                    Navigator.of(context).pop();
                  }
                  else{
                    //firstpageでmodalの外をタップするとエラーnullになる
                    //final NavigatorState navigator = Navigator.of(context);

                    final bool? shouldPop = true;// ダイアログで戻るか確認
                    if (shouldPop ?? true) {

                      print("contextSave=${contextSave}");
                      print("context=${context}");

                      print("ここです");
                      //navigator.pop(); // 戻るを選択した場合のみpopを明示的に呼ぶ
                      Navigator.of(contextStable!, rootNavigator: true).pop();
                    }
                    print("pop000");
                    /*
                    final NavigatorState navigator = Navigator.of(context);
                    navigator.pop();
                    
                    */
                  
                  }
                  
                },
                child: Navigator(
                  onGenerateRoute: (context) => MaterialPageRoute<ModalPage>(
                    builder: (context) => ModalPage(),
                  ),
                ),
              ),
            );
          },
          child: Text('Open Modal'),
        ),
      ),
    );
  }
}





class ModalPage extends StatefulWidget {
  @override
  State<ModalPage> createState() => _ModalPageState();
}

class _ModalPageState extends State<ModalPage> with RouteAware {

  


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }


  @override
  void didPush() {
    // ページがプッシュされたときに呼ばれる
    print("ModalPageが表示されました");
  }

  @override
  Future<void> didPopNext() async{
    // 次のページがポップされてこのページに戻ったときに呼ばれる
    print("ModalPageに戻ってきました");
    count = 9;
  }






  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    contextSave = null;
    flagFirst = true;
    routeObserver.unsubscribe(this);
  }

  @override
  Widget build(BuildContext context) {
    contextStable = context;

    contextSave = context;
    flagFirst = true;
    print(flagFirst); 
    print("ここはModalPageです");
    return Scaffold(
      appBar: AppBar(
        title: Text(count.toString() + 'First Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return SecondPage();
                },
              ),
            );
          },
          child: Text('Go to Second Page'),
        ),
      ),
    );
  }
}





class SecondPage extends StatefulWidget {
  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> with RouteAware {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }


  @override
  void didPush() {
    // ページがプッシュされたときに呼ばれる
    print("SecondPageが表示されました");
    print("");
  }

  @override
  Future<void> didPopNext() async{
    
    print("SecondPageに戻ってきました");
  }










  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    flagFirst = true;
  }

  @override
  Widget build(BuildContext context) {
    contextSave = context;
    flagFirst = false;
    print(flagFirst);
    print("ここはSecondPageです");
    return Scaffold(
      appBar: AppBar(
        title: Text(count.toString() + 'Second Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close Page'),
        ),
      ),
    );
  }
}
