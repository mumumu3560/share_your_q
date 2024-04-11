import 'package:flutter/material.dart';
//import 'package:share_your_q/admob/ad_test.dart';
import 'package:share_your_q/admob/anchored_adaptive_banner.dart';
import 'package:share_your_q/env/env.dart';
import 'package:share_your_q/pages/display_page/display_page.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_your_q/image_operations/problem_view/problem_view.dart';
import 'package:share_your_q/pages/display_page/components/appbar_actions/appbar_actions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//google_admob
//TODO ビルドリリースの時のみ
//import "package:share_your_q/admob/ad_mob.dart";


class RedirectToLikedPage extends StatefulWidget {

  final likedImageId;



  const RedirectToLikedPage({
    Key? key,
    required this.likedImageId
    

  }) : super(key: key);

  @override
  _RedirectToLikedPageState createState() => _RedirectToLikedPageState();
}

class _RedirectToLikedPageState extends State<RedirectToLikedPage>{


  late String profileImageId;

  Future<String> fetchProfileImage(String target) async {
      try {

        final response = await supabase
            .from("profiles")
            .select()
            .eq("id", target);

        if (response[0]["profile_image_id"] == null) {
          return Env.c3;
        } else {
          profileImageId = response[0]["profile_image_id"];
          return response[0]["profile_image_id"];
        }

      } on PostgrestException catch (error) {
        if (mounted) {
          context.showErrorSnackBar(message: error.message);
        }
        return Env.c3;
      } catch (_) {
        if (mounted) {
          context.showErrorSnackBar(message: unexpectedErrorMessage);
        }
        return Env.c3;
      }
    }

  Future<List<Map<String, dynamic>>> fetchData() async {
    try {
      final List<Map<String, dynamic>> response;

      response = await supabase
          .from('image_data')
          .select()
          .eq('image_data_id', widget.likedImageId);

      return response;
    }
    on PostgrestException catch (e) {
      if (mounted) {
        context.showErrorSnackBar(message: e.message);
      }
      return [];
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      return [];
    }


  }

  Future<void> _fetchLikedAndRedirect() async {
    await Future.delayed(Duration.zero);
    //TODO ここでlikedのimage_idを取得して、それを元にDisplayPageにリダイレクトする

    final response = await fetchData();

    final imageData = response[0];

    final profileImage = await fetchProfileImage(imageData["user_id"]);


    //これ必要なやつ全部持ってくる

    /*

     */

    //TODO ここでlikedのimage_idを取得して、それを元にDisplayPageにリダイレクトする
    if(!mounted) return;
    if (response.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DisplayPage(
            // パラメータをここに保持します
            image1: null,
            image2: null,
            title: imageData["title"],
            image_id: imageData["image_data_id"],
            image_own_user_id: imageData["user_id"],
            tag1: imageData["tag1"],
            tag2: imageData["tag2"],
            tag3: imageData["tag3"],
            tag4: imageData["tag4"],
            tag5: imageData["tag5"],
            level: imageData["level"],
            subject: imageData["subject"],
            imageUrlPX: imageData["problem_id"],
            imageUrlCX: imageData["comment_id"],
            explanation: imageData["explain"],
            num: imageData["num"],
            watched: imageData["watched"],
            likes: imageData["likes"],
            problem_id: imageData["problem_id"],
            comment_id: imageData["comment_id"],
            userName: imageData["user_name"],
            difficulty: imageData["eval_num"] != 0
                  ? imageData["difficulty_point"] / imageData["eval_num"].toDouble()
                  : 0,
            profileImage: profileImage,
            problemAdd: imageData["pro_add"],
            commentAdd: imageData["com_add"],
          ),
        ), 
      );
      
    } else {
      context.showErrorSnackBar(message: '問題が見つかりません。');
    }


  }

  


  @override
  void initState(){
    

    super.initState();
    _fetchLikedAndRedirect();

    //TODO ビルドリリースの時のみ
  }


  @override
  Widget build(BuildContext context){

    //ここでローディング中の表示をする
     return Center(
      child: CircularProgressIndicator(),
     );

  }
}



