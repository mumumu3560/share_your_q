import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:share_your_q/env/env.dart';


/*

 */







class AdaptiveAdBanner extends StatelessWidget{
  final String requestId;

  const AdaptiveAdBanner({
    Key? key,
    required this.requestId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }


}

































/*






class AdaptiveAdBanner extends StatelessWidget {

  final String requestId;
  const AdaptiveAdBanner({
    Key? key,
    this.onLoaded,
    required this.requestId,
  }): super(key: key);

  static Map<String, String> adUnits = {
    "CREATE": Env.b1,
    "UPDATE": Env.b2,
    "SEARCH": Env.b3,
    "PROFILE": Env.b4,
    "LIST": Env.b5,
    "DISPLAY": Env.b6,
    "SETTING": Env.b7,
    "NOTIFICATION": Env.b8,
  };

  final VoidCallback? onLoaded;

  @override
  Widget build(BuildContext context) {
    final adUnitId = adUnits[requestId];
    return LayoutBuilder(builder: (context, constraint) {
      return HookBuilder(builder: (context) {
        final bannerLoaded = useState(false);
        final bannerAd = useFuture(
          useMemoized(
            () async {
              final adWidth = constraint.maxWidth.truncate();
              final adSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
                MediaQuery.of(context).orientation,
                adWidth,
              ) as AdSize;

              return BannerAd(
                size: adSize,
                adUnitId: adUnitId!,
                listener: BannerAdListener(
                  onAdFailedToLoad: (ad, error) {
                    ad.dispose();
                    bannerLoaded.value = false;
                  },
                  onAdLoaded: (ad) {
                    bannerLoaded.value = true;
                    onLoaded?.call();
                  },
                ),
                request: const AdRequest(),
              );
            },
          ),
        ).data;

        if (bannerAd == null) {
          return const SizedBox.shrink();
        }

        useEffect(() {
          bannerAd.load();
          return () async => await bannerAd.dispose();
        }, [bannerAd]);

        return bannerLoaded.value
            ? SizedBox(
                width: bannerAd.size.width.toDouble(),
                height: bannerAd.size.height.toDouble(),
                child: AdWidget(ad: bannerAd),
              )
            : const SizedBox.shrink();
      });
    });
  }
}
 */




