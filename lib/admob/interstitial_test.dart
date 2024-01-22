import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_your_q/utils/various.dart';


class InterstitialAdManager implements InterstitialAdLoadCallback{
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  
  void interstitialAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? dotenv.get("INTERSTITIAL_ID_CREATE")
          : dotenv.get("INTERSTITIAL_ID_CREATE"),

      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isAdLoaded) {
      _interstitialAd?.fullScreenContentCallback;
      _interstitialAd?.show();

    } else {
      print('Interstitial ad is not yet loaded.');
    }
  }

  @override
  // TODO: implement onAdFailedToLoad
  FullScreenAdLoadErrorCallback get onAdFailedToLoad => throw UnimplementedError();

  @override
  // TODO: implement onAdLoaded
  GenericAdEventCallback<InterstitialAd> get onAdLoaded => throw UnimplementedError();
}
