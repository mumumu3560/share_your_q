//import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_your_q/pages/create_page/create_page_test2.dart';
import 'package:share_your_q/pages/home_page/notification/notification_page.dart';
import 'package:share_your_q/pages/home_page/settings/setting_page.dart';
//import 'package:share_your_q/pages/notification_page.dart';
import 'package:share_your_q/pages/search_page/search_page.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:share_your_q/image_operations/image_list_display.dart';
import "package:share_your_q/pages/test_pages.dart";
import 'package:share_your_q/pages/profile_page/profile_page.dart';

//TODO OneSignal
import 'package:onesignal_flutter/onesignal_flutter.dart';

//import "package:share_your_q/admob/ad_test.dart";





//homepage
//TODO ここではホームページを作成する
//navigationbottombarを使って、ホーム、検索、プロフィール、設定の4つのページに遷移できるようにしたい？
//プロフィールはボトムナビゲーションよりも左上のappbarから遷移できるようにした方がいいかもしれない


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  
  static MaterialPageRoute route() {
    return MaterialPageRoute(
      builder: (_) => const HomePage(),
    );
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // データを格納するリスト
   List<Map<String,dynamic>> imageData = [];

  // データ取得中フラグ
  bool isLoading = true;

  bool firstFetch = true;

  String profileId = "";
  String userName = "";

  Future<void> fetchProfile() async{
    try{
      final response = await supabase
        .from('profiles')
        .select<List<Map<String, dynamic>>>()
        .eq('id', myUserId);
      setState(() {
        profileId = response[0]["profile_image_id"];
        userName = response[0]["username"];
      });
    }
    catch(e){
      print("error");
    }
  }


  Future<void> fetchData() async {
    try {
      final response = await supabase
            .from("image_data")
            .select<List<Map<String, dynamic>>>()
            .order('created_at');
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

    } catch (e) {
      // エラーハンドリングを実装
      print('Error fetching data: $e');
      context.showErrorSnackBar(message: "データの取得に失敗しました。");
    }
  }

  @override
  void initState() {
    super.initState();
    // ここでSupabaseからデータを取得し、リストに格納する処理を呼び出す
    fetchData();
    fetchProfile();
    //
    final String externalId = supabase.auth.currentUser!.id.toString();
    print(externalId);
    //TODO ここはandroidビルドリリースの時のみ
    //OneSignal.login(externalId);
  }

  /*
  void _handleLogin() {
    print("Setting external user ID");
    if ( == null) return;
    OneSignal.login(_externalUserId!);
    OneSignal.User.addAlias("fb_id", "1341524");
  }
   */



  


  int _selectedIndex = 0;
  final _pageViewController = PageController();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        //title: Text('ホーム'),
      ),

      drawer: Drawer(


        child: ListView(
          children: [
            SizedBox(
              height: SizeConfig.blockSizeVertical! * 15,
              child: const DrawerHeader(
                child: Text("Share"),
              ),
            ),

            ListTile(
              title: const Text('問題を作る'),
              onTap: () {
                // 画像投稿ページに遷移するコードを追加
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreatePage(), // ImageDisplayに遷移
                  ),
                );
              },
            ),

            ListTile(
              title: const Text('問題を探す'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(), // ImageDisplayに遷移
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
                    builder: (context) => ProfilePage(userId:myUserId, userName: userName, profileImage: profileId,), // ImageDisplayに遷移
                  ),
                );
              },
            ),

            ListTile(
              title: const Text('投稿した問題'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ImageListDisplay(subject: "全て", level: "全て", method: "新着", tags: const [], title: "自分の投稿一覧", searchUserId: supabase.auth.currentUser!.id.toString(), showAppbar: true, lang: "全て", canToPage: true, add: false,), // ImageDisplayに遷移
                  ),
                );
              },
            ),

          ],
        ),

      ),

      body: PageView(
        controller: _pageViewController,
        // スワイプ無効
        physics: const NeverScrollableScrollPhysics(),
        
        children:  <Widget>[
          const ImageListDisplay(title: "新着", subject: "全て", level: "全て", method: "新着",tags: [], searchUserId: "", showAppbar: false, lang: "全て", canToPage: true, add: false,),
          const SearchPage(),
          const NotificationPage(),
          SettingPage(),
          //ProfilePage(userId: myUserId,userName: userName, profileImage: profileId,),
          //const TestPages(title: "D"),
        ],
        
        /*
         */
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          //_pageViewController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
          _pageViewController.jumpToPage(index);
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

          //通知欄
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'notification',
            tooltip: "notification",
            backgroundColor: Colors.black,
          ),

          //設定
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'setting',
            tooltip: "setting",
            backgroundColor: Colors.black,
          ),

          

          /*
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
          */
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