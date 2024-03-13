import 'package:flutter/material.dart';
import 'package:share_your_q/env/env.dart';

//import "package:google_fonts/google_fonts.dart";

import 'package:share_your_q/pages/login_relatives/redirect.dart';

//Supabase
import 'package:supabase_flutter/supabase_flutter.dart';

//dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';

//OneSignal
//TODO
//import 'package:onesignal_flutter/onesignal_flutter.dart';


import 'package:timeago/timeago.dart' as timeago;

//google_admob
//TODO
/*
OneSignal.Notifications.requestPermission(true);

  //TODO ここはandroidビルドリリースの時のみ
  OneSignal.initialize(dotenv.get('ONESIGNAL_ID'));

 */
//import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //TODO ここはandroidビルドリリースの時のみ
  //MobileAds.instance.initialize();
  
  //await dotenv.load(fileName: '.env');
  

  timeago.setLocaleMessages("ja", timeago.JaMessages());


  /*
  // *** ステータスバー/ナビゲーションバーを非表示
  //https://www.memory-lovers.blog/entry/2024/02/06/152340
  // スワイプで各バーを表示。画面端のスワイプは認識しない。Android4.4以上
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  
  // スワイプで各バーを半透明で表示。画面端のスワイプは認識する。Android4.4以上
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  // どこかをタップすると各バー表示。Android4.1以上
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

   */



  await Supabase.initialize(
    // TODO: ここにSupabaseのURLとAnon Keyを入力
    //url: dotenv.get('SUPABASE_URL'),
    //anonKey: dotenv.get('SUPABASE_KEY'),

    url: Env.s1,
    anonKey: Env.s2,
  );

  /*
  
   */

  //TODO ここはandroidビルドリリースの時のみ
  //OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  

  // The promptForPushNotificationsWithUserResponse function will show the iOS or Android 
  //push notification prompt. We recommend removing the following code and 
  //instead using an In-App Message to prompt for notification permission

  
  
  /*
  OneSignal.Notifications.requestPermission(true);

  //TODO ここはandroidビルドリリースの時のみ
  OneSignal.initialize(dotenv.get('ONESIGNAL_ID'));
  
  
  */

  
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'タイトル',
      theme: ThemeData.dark().copyWith( 

        primaryColor: Colors.green,
        //scaffoldBackgroundColor: Colors.black,

        /*
        textTheme: GoogleFonts.dotGothic16TextTheme(
          Theme.of(context).textTheme.copyWith(
            //テキストの色は白
            bodyLarge: const TextStyle(color: Colors.white),

          ),
          
        
        ),
         */

        /*
        // テキストのテーマ
        textTheme: GoogleFonts.dotGothic16TextTheme(
          Theme.of(context).textTheme.copyWith(
            //テキストの色は白
            bodyText1: const TextStyle(color: Colors.white),

          ),
          
        
        ),
         */

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.green,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            //backgroundColor: Color.fromARGB(255, 35, 142, 39),
            backgroundColor: Colors.green,
          ),
        ),

      ),
      home: const SplashPage(), 
    );
  }

  
}
