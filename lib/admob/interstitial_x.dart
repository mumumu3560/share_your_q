
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:share_your_q/utils/various.dart';

/// A simple app that loads an interstitial ad.
class InterstitialExample extends StatefulWidget {
  const InterstitialExample({super.key});

  @override
  InterstitialExampleState createState() => InterstitialExampleState();
}

class InterstitialExampleState extends State<InterstitialExample> {
  InterstitialAd? _interstitialAd;

  final String _adUnitId = Platform.isAndroid
      ? dotenv.get("INTERSTITIAL_ID_CREATE")
      : dotenv.get("INTERSTITIAL_ID_CREATE");

  @override
  void initState() {
    super.initState();

    _startNewGame();
  }

  void _startNewGame() {
    _loadAd();
    context.showSuccessSnackBar(message: "InterstitialAd loaded");
  }

  @override
  Widget build(BuildContext context) {

    return ElevatedButton(
      onPressed: () {
        if (_interstitialAd == null) {
          return;
        }
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) =>
                //print('$ad onAdShowedFullScreenContent.'),
                context.showSuccessSnackBar(message: "aaa"),
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print('$ad onAdDismissedFullScreenContent.');
              context.showSuccessSnackBar(message: "bbb");
              ad.dispose();
              _loadAd();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('$ad onAdFailedToShowFullScreenContent: $error');
              context.showSuccessSnackBar(message: "ccc");
              ad.dispose();
              _loadAd();
            },
            onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
            onAdClicked: (InterstitialAd ad) => print('$ad clicked.'));

        _interstitialAd!.show();
        _interstitialAd = null;
        //Navigator.of(context).pop(); 
      },
      child: Text("aaaaaaaaa")
    );
  }

  /// Loads an interstitial ad.
  void _loadAd() {
    InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {
                  //print('$ad onAdShowedFullScreenContent.');
                  context.showSuccessSnackBar(message: "onAdShowedFullScreenContent");
                },
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            // ignore: avoid_print
            print('InterstitialAd failed to load: $error');
            context.showErrorSnackBar(message: "InterstitialAd failed to load: $error");
            
            
          },
        ));
  }


  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}