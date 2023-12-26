//import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_your_q/pages/create_page_test2.dart';
import 'package:share_your_q/pages/search_page.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:share_your_q/image_operations/image_list_display.dart';
import "package:share_your_q/pages/test_pages.dart";
import "package:share_your_q/pages/profile_page.dart";
//import 'package:onesignal_flutter/onesignal_flutter.dart';

import "package:share_your_q/utils/various.dart";
import "package:share_your_q/image_operations/test_override.dart";



//homepage
//TODO ここではホームページを作成する
//navigationbottombarを使って、ホーム、検索、プロフィール、設定の4つのページに遷移できるようにしたい？
//プロフィールはボトムナビゲーションよりも左上のappbarから遷移できるようにした方がいいかもしれない


class HomePage extends StatefulWidget {
  
  static MaterialPageRoute route() {
    return MaterialPageRoute(
      builder: (_) => HomePage(),
    );
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // データを格納するリスト
   List<Map<String,dynamic>> imageData = [];
  //現在のページ番号
  int currentPage = 1;
  //1ページに表示するアイテム数
  int itemsPerPage = 10;
  // データ取得中フラグ
  bool isLoading = true;

  bool firstFetch = true;


  @override
  void initState() {
    super.initState();
    // ここでSupabaseからデータを取得し、リストに格納する処理を呼び出す
    fetchData(currentPage);
    //
    final String External_id = supabase.auth.currentUser!.id.toString();
    print(External_id);
    //TODO ここはandroidビルドリリースの時のみ
    //OneSignal.login(External_id);
  }

  /*
  void _handleLogin() {
    print("Setting external user ID");
    if ( == null) return;
    OneSignal.login(_externalUserId!);
    OneSignal.User.addAlias("fb_id", "1341524");
  }
   */



  Future<void> fetchData(int page) async {
    try {
      // ここでSupabaseからデータを取得し、imageDataに格納する処理を実装
      // 例: imageData = await fetchImageData();
      // 画像情報を新着順で非同期に取得（pageとitemsPerPageを使用してページごとにデータを制御）
      //final response = await supabase.from("image_data").select().
      

      /*
      //参考にしたURLのコードは
      _messagesStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at') // 送信日時が新しいものが先に来るようにソート
        .map((maps) => maps
            .map((map) => Message.fromMap(map: map, myUserId: myUserId))
            .toList());
      これはList<Map<String,dynamic>>を受け取るが、
       */

      //なぜだかわからないが、supabaseではrealtimeで取得するときは.select()で
      //List<Map<String,dynamic>>になるが、一回だけの時はList<dynamic>になる。
      //ただしselect<List<Map<String,dynamic>>>()とすればいいらしい。
    
      final response = await supabase
            .from("image_data")
            .select<List<Map<String, dynamic>>>()
            .order('created_at');
            //.map((maps) => maps.map((map) => ImageData.fromMap(map: map))
            //.toList());

      isLoading = false;
      imageData = response;
      

      
      if(!firstFetch){
        //ここでヴィジェットが再構築される
        setState(() {
          // データ取得完了後、isLoadingフラグをfalseに設定
          isLoading = false;
          // imageDataにデータをセット
          imageData = response;
        });
      }
      else{
        firstFetch = false;
      }
      //id(int8),created_at(timestamp),num(int4)これは問題の番号、PorC(int2)これはそれがproblemかcommentか、
      //title(text)、user_id(uuid)これはユーザーid,level(text)→小中高大学、subject(text)→教科、
      //P_I_count(int4)これは問題の画像の数、C_I_count(int4)これはコメントの画像の数、
      //supabaseのテーブルはこうなっている。ここからある画像の情報を取得し保存する。
      //形式はMap<String, dynamic>で、keyはカラム名、valueはカラムの値となる。
      //imageData = response;
      // データを格納するリスト
      //List<Map<String, dynamic>> imageData = [];


    } catch (e) {
      // エラーハンドリングを実装
      print('Error fetching data: $e');
      context.showErrorSnackBar(message: "データの取得に失敗しました。");
    }
  }

  // 次のページを読み込む処理
  void loadNextPage() {
    currentPage++;
    fetchData(currentPage);
  }

  // 前のページを読み込む処理
  void loadPreviousPage() {
    if (currentPage > 1) {
      currentPage--;
      fetchData(currentPage);
    }
  }

  int _selectedIndex = 0;
  final _pageViewController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(

      appBar: AppBar(
        //title: Text('ホーム'),
      ),

      drawer: Drawer(


        child: ListView(
          children: [
            SizedBox(
              height: SizeConfig.blockSizeVertical! * 15,
              child: DrawerHeader(
                child: Text("Share"),
              ),
            ),

            ListTile(
              title: const Text('問題を作る'),
              onTap: () {
                // 画像投稿ページに遷移するコードを追加
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreatePage(), // ImageDisplayに遷移
                  ),
                );
              },
            ),

            ListTile(
              title: Text('問題を探す'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SearchPage(), // ImageDisplayに遷移
                  ),
                );
                // 画像探しページに遷移するコードを追加
              },
            ),

            ListTile(
              title: const Text('プロフィール'),
              onTap: () {
                
                // プロフィールページに遷移するコードを追加
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(userId:myUserId), // ImageDisplayに遷移
                  ),
                );
              },
            ),

            ListTile(
              title: const Text('投稿した問題'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ImageListDisplay(subject: "全て", level: "全て", method: "新着", tags: [], title: "自分の投稿一覧", searchUserId: supabase.auth.currentUser!.id.toString()), // ImageDisplayに遷移
                  ),
                );
              },
            ),

          ],
        ),

      ),

      body: PageView(
        controller: _pageViewController,
        children:  <Widget>[
          ImageListDisplay(title: "新着", subject: "全て", level: "全て", method: "新着",tags: [], searchUserId: "",),
          SearchPage(),
          ProfilePage(userId: myUserId,),
          const TestPages(title: "D"),
        ],
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          _pageViewController.animateToPage(index, duration: Duration(milliseconds: 200), curve: Curves.easeOut);
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
            tooltip: "Home",
            backgroundColor: Colors.black,
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'search',
            tooltip: "Search",
            backgroundColor: Colors.black,
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
            tooltip: "Profile",
            backgroundColor: Colors.black,
            
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
            tooltip: "This is a Settings Page",
            backgroundColor: Colors.black,
          ),
        ],

        //type: BottomNavigationBarType.shifting,
        //type: BottomNavigationBarType.fixed,

        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black87,
        enableFeedback: true,
        iconSize: 18,
        selectedFontSize: 0,
        selectedIconTheme: const IconThemeData(size: 30, color: Colors.green),
        unselectedFontSize: 0,
        unselectedIconTheme: const IconThemeData(size: 25, color: Colors.white),
      ),




    );
  }
}