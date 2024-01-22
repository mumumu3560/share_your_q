import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';

import "package:share_your_q/utils/various.dart";

class InlineAdaptiveAdBanner extends StatelessWidget {

  final String requestId;
  final int adHeight;
  const InlineAdaptiveAdBanner({
    Key? key,
    this.onLoaded,
    required this.requestId,
    required this.adHeight,
  });

  final VoidCallback? onLoaded;

  @override
  Widget build(BuildContext context) {
    final adUnitId = kReleaseMode ? dotenv.get("BANNER_ID_$requestId") : dotenv.get("BANNER_ID_$requestId");
    return LayoutBuilder(builder: (context, constraint) {
      return HookBuilder(builder: (context) {
        final bannerLoaded = useState(false);
        final bannerAd = useFuture(
          useMemoized(
            () async {
              final adWidth = constraint.maxWidth.truncate();
              final adSize = AdSize.getInlineAdaptiveBannerAdSize(
                adWidth,
                adHeight
              );

              return BannerAd(
                size: adSize,
                adUnitId: adUnitId,
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