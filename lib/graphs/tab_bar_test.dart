/*
import 'package:flutter/material.dart';
import 'package:share_your_q/image_operations/image_display.dart'; // ImageDisplayScreenが定義されたファイルをインポート
import 'package:share_your_q/utils/various.dart';
import 'package:file_picker/file_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import "package:share_your_q/pages/profile_page.dart";


class MainPage extends StatefulWidget {
  const MainPage ({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int _currentPageIndex = 0;// ②：ここにTapされたバーのindex番号を入れる
  void _onItemTapped(int index) {
    //Tapされたindexを上記_currentPageIndexに代入するメソッド
    setState(() {
      _currentPageIndex = index;
    });
  }
  static final List<Widget> _widgetOptions = <Widget>[
    //_widgetOptionsというWidgetの配列を持つ要素を定義しておく
    ProfilePage(),
    ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false,
            // //以上の記述一行だけでNavigationのBack矢印が消せる。豆知識
            title: GestureDetector(//このGesutureDetectorは要らないです今気づきました。


              child: TabBar(//①TabBarWidgetで上部のバーが作れる
                onTap: _onItemTapped, //タップしたtabs:[] のindex番号を_onItemTappedの引数(int index)として渡している
                tabs: [
                  Tab(text: '1',),
                  Tab(text: '2'),
              ],
              indicatorColor: Colors.white,
        ),
            ),
        backgroundColor: Colors.blue),
        body: Column(
          children: [
            Expanded(
                child: Container(
                    child: _widgetOptions.elementAt(_currentPageIndex))) 
                    //③タップしたバーによって表示を変える。そのwidgetをここに設置している
                     //elementAt()メソッド：()内のindex番号を取り出す。ここでは　_currentPageIndex　を渡す
          ],
        ),
      ),
    );
  }
}
 */