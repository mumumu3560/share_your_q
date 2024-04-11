
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:share_your_q/pages/create_page/create_page_test2.dart';
import 'package:share_your_q/pages/home_page/notification/notification_page.dart';
import 'package:share_your_q/pages/home_page/settings/setting_page.dart';
import 'package:share_your_q/pages/redirect_page/fetchLikedImageWithId.dart';
import 'package:share_your_q/pages/redirect_page/redirect_to_liked_page.dart';

import 'package:share_your_q/pages/search_page/search_page.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:share_your_q/image_operations/image_list_display.dart';
import 'package:share_your_q/pages/profile_page/profile_page.dart';

//TODO OneSignal
import 'package:supabase_flutter/supabase_flutter.dart';




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

  String? profileId = "";
  String userName = "";

  Future<void> fetchProfile() async{
    try{
      final response = await supabase
        .from('profiles')
        .select()
        .eq('id', myUserId);
      setState(() {
        profileId = response[0]["profile_image_id"];
        userName = response[0]["username"];
      });
    } on PostgrestException catch(e){
      if(mounted){
        context.showErrorSnackBar(message: e.message);
      }
      
    } catch(e){
      if(mounted){
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
    }
  }

  Future<void> onTapPushNotification()async {

    
    OneSignal.Notifications.addClickListener((event) async {


      final additionalData = event.notification.additionalData;

      //ここでredirectToLikedPageに飛ばす
      if (additionalData!["action"] == "like") {
        //OneSignal.Notifications.clearAll();
        //await fetchLikedAndRedirect(context, additionalData["imageId"]);
        /*
        
         */
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RedirectToLikedPage(
              likedImageId: additionalData["imageId"],
            ),
          ),
        );
      }

      if(additionalData!["action"] == "follow"){
        //OneSignal.Notifications.clearAll();
        if(!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(userId: additionalData["userId"], userName: additionalData["userName"], /*profileImage: profileId,*/),
          ),
        );
      }
      


    });
  }


  Future<void> fetchData() async {
    try {
      final response = await supabase
            .from("image_data")
            .select()
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

      return;

    } on PostgrestException catch(error){
      if(mounted){
        context.showErrorSnackBar(message: error.message);
      }

      return;

    }
    catch (e) {
      if(mounted){
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }

      return;
    }
  }

  Future<void> initFetch() async{
    await onTapPushNotification();
    await fetchData();
    await fetchProfile();

  }

  

  @override
  void initState() {
    super.initState();
    // ここでSupabaseからデータを取得し、リストに格納する処理を呼び出す

    //TODO ここでOneSignalの通知をタップした時の処理を書く
    //onTapPushNotification();

    //fetchData();
    //fetchProfile();

    initFetch();

    
    
    
    //
    final String externalId = supabase.auth.currentUser!.id.toString();
    //TODO ここはandroidビルドリリースの時のみ
    //OneSignal.login(externalId);
  }


  


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
                    builder: (context) => ProfilePage(userId:myUserId, userName: userName, /*profileImage: profileId, */), // ImageDisplayに遷移
                  ),
                );
              },
            ),

            ListTile(
              title: const Text('投稿した問題'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ImageListDisplay(subject: "全て", level: "全て", method: "新着", tags: const [], title: "自分の投稿一覧", searchUserId: supabase.auth.currentUser!.id.toString(), showAppbar: true, lang: "全て", canToPage: true, add: false, showAdd: true,), // ImageDisplayに遷移
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
          const ImageListDisplay(title: "新着", subject: "全て", level: "全て", method: "新着",tags: [], searchUserId: "", showAppbar: false, lang: "全て", canToPage: true, add: false,  showAdd: true,),
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

          

        ],

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