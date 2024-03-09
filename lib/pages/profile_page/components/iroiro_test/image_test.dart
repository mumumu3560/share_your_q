import 'package:flutter/material.dart';

import 'package:share_your_q/pages/profile_page/profile_page.dart';
import 'package:share_your_q/utils/various.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:share_your_q/image_operations/image_list_display.dart';

//import "package:share_your_q/admob/ad_test.dart";

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';


//google_admob
//TODO ビルドリリースの時のみ
//import 'package:share_your_q/admob/inline_adaptive_banner.dart';


class ImageTest extends StatefulWidget {

  final Uint8List image;

  ImageTest({required this.image});

  @override
  _ImageTestState createState() => _ImageTestState();
}

class _ImageTestState extends State<ImageTest> {

  void showPreviewImage(
    BuildContext context, {
    required Uint8List image,
  }) {
    showDialog(
      barrierDismissible: true,
      barrierLabel: '閉じる',
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InteractiveViewer(
                    minScale: 0.1,
                    maxScale: 5,
                    child: Image.memory(
                      image,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Test"),
      ),
      body: Center(
        child: GestureDetector(
          child: Image.memory(widget.image, fit: BoxFit.cover,),
          onTap: (){
            showPreviewImage(context, image: widget.image);
          }
        )
      ),
    );
  }
}