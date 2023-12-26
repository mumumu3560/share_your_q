import 'package:flutter/material.dart';
import 'package:share_your_q/pages/login_relatives/redirect.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';

//import "package:google_fonts/google_fonts.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    // TODO: ここにSupabaseのURLとAnon Keyを入力
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_KEY'),
  );

  
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'タイトル',
      theme: ThemeData.dark().copyWith( 

        primaryColor: Colors.green,
        //scaffoldBackgroundColor: Colors.black,

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
