import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share_your_q/env/env.dart';
import 'package:share_your_q/pages/home_page/home_page_web.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//https://zenn.dev/dshukertjr/books/flutter-supabase-chat/viewer/page1

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const LoginPage());
  }

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {

    setState(() {
      _isLoading = true;
    });


    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(HomePage.route(), (route) => false);

    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }




  Future<void> _googleSignIn() async {

    /// TODO: update the Web client ID with your own.
    final webClientId = Env.g3;

    /// TODO: update the iOS client ID with your own.
    //const iosClientId = 'my-ios.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      //clientId: iosClientId,
      serverClientId: webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    await supabase.auth.signInWithIdToken(
      //provider: OAuthProvider.google,
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }




  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {

        Navigator.of(context).pushReplacement(HomePage.route());

      }
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupAuthListener();
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      
      body: ListView(

        padding: formPadding,

        children: [

          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'メールアドレス'),
            keyboardType: TextInputType.emailAddress,
          ),

          formSpacer,

          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'パスワード'),
            obscureText: true,
          ),

          formSpacer,

          ElevatedButton(
            onPressed: _isLoading ? null : _signIn,
            child: const Text('ログイン'),
          ),

          formSpacer,

          ElevatedButton(
              //背景色を変えたい
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Image.asset("assets/images/google-symbol.png", width: 24, height: 24),

                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 5,),
                  const Text('Login with Google'),
                ],
              ),

              onPressed: _isLoading ? null : () async {
                try {
                  await _googleSignIn();
                } on PostgrestException catch (e) {
                  if(context.mounted){
                    context.showErrorSnackBar(message: e.message);
                  }
                } catch (e) {
                  if(context.mounted){
                    context.showErrorSnackBar(message: unexpectedErrorMessage);
                  }
                }
              },
            ),

        ],
      ),
    );
  }
}