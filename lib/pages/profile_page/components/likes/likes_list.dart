import 'package:flutter/material.dart';

import 'package:share_your_q/pages/profile_page/profile_page.dart';
import 'package:share_your_q/utils/various.dart';

//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:share_your_q/image_operations/image_list_display.dart';

//import "package:share_your_q/admob/ad_test.dart";

import 'dart:typed_data';


//google_admob
//TODO ビルドリリースの時のみ
import 'package:share_your_q/admob/inline_adaptive_banner.dart';

class LikesList extends StatefulWidget {

  final String userId;
  final List<Map<String,dynamic>> likesData;

  const LikesList({
    Key? key,
    required this.userId,
    required this.likesData,

  }) :super(key: key);

  @override
  LikesListState createState() => LikesListState();

}


class LikesListState extends State<LikesList> {
  bool isLoading = true;


  String profileImageId = "";

  


  
  @override
  void initState() {
    super.initState();
    isLoading = false;


    //TODO ビルドリリースの時のみ
  }

  @override
  void dispose() {
    super.dispose();
    //TODO ビルドリリースの時のみ
  }

  


  // リストをリロードするメソッド
  void reloadList() {
    setState(() {
      isLoading = true;
    });

    setState(() {
      isLoading = false;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("いいね")  // アプリバーに表示するタイトル

      ),
      body: Center(
        child: Container(
          //中央寄り
          alignment: Alignment.center,
          
          child: Column(
            children: [

              if(widget.likesData.isEmpty && !isLoading)
                Container(
                  //padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 10),
                  child: const Text(
                    "data is empty",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                )

              else 
                isLoading
                    ? const Expanded(
                        child: Center(
                          child: CircularProgressIndicator()
                        )
                      )
                    : Expanded(
                      
                      //RefreshIndicatorによってリロードできるようになる。
                        child: RefreshIndicator(
                          color: Colors.green,
                          onRefresh: () async{ 
                            reloadList();
                          },

                          //リストビューを作成する
                          //TODOスクロールバーの追加
                          child: ListView.builder(
                            //https://stackoverflow.com/questions/68623174/why-cant-i-slide-the-listview-builder-on-flutter-web
                            physics: const AlwaysScrollableScrollPhysics(),
                            
                            
                            //TODO ここでリストの保持を行う。
                            itemCount: widget.likesData.length,
                            //itemCount: 10,
                            itemBuilder: (context, index) {
                                                
                              //6の倍数の時には広告を表示する。
                              if(index%6 == 1){
                                final item = widget.likesData[index];
                                return Column(
                                  children: [
                                    /*
                                    Container(
                                      height: 64,
                                      width: double.infinity,
                                      color: Colors.white,
                                      //TODO ビルドリリースの時のみ
                                      //child: _adMob.getAdBanner(),
                                    ),
                                     */
                                                
                                    SizedBox(
                                      height: SizeConfig.blockSizeVertical! * 40,
                                      //InlineAdaptiveAdBanner(requestId: "LIST",),
                                      //TODO Admob
                                      /*
                                      //InlineAdaptiveExample(),
                                       */
                                      child: InlineAdaptiveAdBanner(
                                        requestId: "LIST", 
                                        adHeight: SizeConfig.blockSizeVertical!.toInt() * 40,
                                      )
                                    ),
                                    //const ,
                                                
                                    
                                    MyListItem(item: item, canToPage: true,),
                                  ],
                                );
                              }
                              else{
                                final item = widget.likesData[index];
                                return MyListItem(item: item, canToPage: true,);
                              }
                              
                              
                            },
                          ),
                        ),
                      ),
              
            ],
          ),
        ),
      ),
    );
  }
}






