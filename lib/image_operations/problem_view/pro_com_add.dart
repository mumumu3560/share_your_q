import 'package:flutter/material.dart';
import 'package:share_your_q/admob/inline_adaptive_banner.dart';
import 'package:share_your_q/pages/profile_page/profile_page.dart';
import 'package:share_your_q/utils/various.dart';

import 'package:share_your_q/pages/display_page/display_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:timeago/timeago.dart';

import 'package:http/http.dart' as http;
import 'package:share_your_q/admob/anchored_adaptive_banner.dart';
//import "package:share_your_q/admob/ad_test.dart";

import 'dart:typed_data';


//google_admob
//TODO ビルドリリースの時のみ
//import "package:share_your_q/admob/ad_mob.dart";


class ProblemOrCommentAdding extends StatefulWidget {

  final String userId;
  final int? imageId;
  final bool isProblem;

  final int? addNum;

  const ProblemOrCommentAdding({
    Key? key,
    required this.userId,
    required this.imageId,
    required this.isProblem,
    required this.addNum,
  }): super(key: key);


  @override
  _ProblemAddingState createState() => _ProblemAddingState();
}

class _ProblemAddingState extends State<ProblemOrCommentAdding>{

  String proOrCom = "";
  List<Map<String, dynamic>> likesData = [];

  bool isLiked = false;

  int? addNum = 0;

  Future<void> fetchData()async {

    try{
      likesData = await supabase
        .from('likes')
        .select<List<Map<String, dynamic>>>()
        .eq('image_id', widget.imageId)
        .eq('user_id', widget.userId);

      if(likesData.isNotEmpty){
        setState(() {
          isLiked = likesData[0][proOrCom];  

          if(widget.addNum == null){
            addNum = 0;
          }  
          else{
            addNum = widget.addNum;
          }
        });
      }

    }
    on PostgrestException catch (error){
      if(context.mounted){
        context.showErrorSnackBar(message: error.message);
        
      }
    } catch(_){
      if(context.mounted){
        context.showErrorSnackBar(message: unexpectedErrorMessage);
        
      }
    }
  }

  Future<void> addLike()async{
    try{
      
      if(isLiked){
        await supabase
          .from('likes')
          .update({proOrCom: false})
          .eq('image_id', widget.imageId)
          .eq('user_id', widget.userId);
      }
      else{
        await supabase
          .from('likes')
          .update({proOrCom: true})
          .eq('image_id', widget.imageId)
          .eq('user_id', widget.userId);
      }
      setState(() {
        
        if(isLiked){
          addNum = addNum! - 1;
        }
        else{
          addNum = addNum! + 1;
        }
        isLiked = !isLiked;
      });
    }
    on PostgrestException catch (error){
      if(context.mounted){
        context.showErrorSnackBar(message: error.message);
        
      }
    } catch(_){
      if(context.mounted){
        context.showErrorSnackBar(message: unexpectedErrorMessage);
        
      }
    }

  }

  @override
  void initState() {

    if(widget.isProblem){
      proOrCom = "pro_add";
    }
    else{
      proOrCom = "com_add";
    }


    // TODO: implement initState
    super.initState();

    if(widget.imageId != null){
      fetchData();
    }

  }

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        IconButton(
          onPressed: widget.imageId == null ? null : addLike,

          icon: isLiked 

            ? widget.isProblem
              ?  const Icon(
                  Icons.thumb_up_alt, 
                  color: Colors.green,
                ) 
              : const Icon(
                  Icons.thumb_up_alt,
                  color: Colors.blue,
                )


            : const Icon(
                Icons.thumb_up_alt_outlined,
              ),
        ),

        Text(
          addNum.toString(),
        ),
      ],
    );
  }

}
