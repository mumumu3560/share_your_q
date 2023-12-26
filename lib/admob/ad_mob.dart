import 'package:share_your_q/admob/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMob {
  BannerAd? _bannerAd;
  AdMob() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
          },
        ),
        request: const AdRequest());
  }

  void load() {
    _bannerAd!.load();
  }

  void dispose() {
    _bannerAd!.dispose();
  }

  Widget getAdBanner() {
    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  double getAdBannerHeight() {
    return _bannerAd!.size.height.toDouble();
  }
}


/*
leading: FutureBuilder(
  future: loadImage(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      // データの読み込み中はローディングインジケータなどを表示する
      return CircularProgressIndicator();
    } else if (snapshot.hasError || snapshot.data.isEmpty) {
      // エラーが発生した場合は代替のアイコンを表示する
      return GestureDetector(
        child: CircleAvatar(
          radius: 20,
          child: Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 40,
          ),
        ),
        onTap: () {
          print('Error occurred. Handle onTap action here.');
          // タップした際の処理を記述する
        },
      );
    } else {
      // データが正常に読み込まれた場合に画像を表示する
      return GestureDetector(
        child: CircleAvatar(
          radius: 20,
          child: ClipOval(
            child: Image.network(
              snapshot.data,
              fit: BoxFit.cover,
              width: 40,
              height: 40,
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfilePage(userId: myUserId),
            ),
          );
        },
      );
    }
  },
),

 */
