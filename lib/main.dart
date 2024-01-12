import 'package:flutter/material.dart';
//import "package:google_fonts/google_fonts.dart";

import 'package:share_your_q/pages/login_relatives/redirect.dart';

//Supabase
import 'package:supabase_flutter/supabase_flutter.dart';

//dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';

//OneSignal

import 'package:timeago/timeago.dart' as timeago;

//google_admob
/*
import 'package:google_mobile_ads/google_mobile_ads.dart';
import "package:share_your_q/admob/ad_helper.dart";
import "package:share_your_q/admob/ad_mob.dart";
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //TODO ここはandroidビルドリリースの時のみ
  //MobileAds.instance.initialize();
  
  await dotenv.load(fileName: '.env');

  timeago.setLocaleMessages("ja", timeago.JaMessages());


  await Supabase.initialize(
    // TODO: ここにSupabaseのURLとAnon Keyを入力
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_KEY'),
  );

  /*
  
   */

  //TODO ここはandroidビルドリリースの時のみ
  //OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  

  // The promptForPushNotificationsWithUserResponse function will show the iOS or Android 
  //push notification prompt. We recommend removing the following code and 
  //instead using an In-App Message to prompt for notification permission
  
  //OneSignal.Notifications.requestPermission(true);

  //TODO ここはandroidビルドリリースの時のみ
  //OneSignal.initialize(dotenv.get('ONESIGNAL_ID'));

  
  
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
            backgroundColor: Colors.green,
          ),
        ),

      ),
      home: const SplashPage(), 
    );
  }

  
}
