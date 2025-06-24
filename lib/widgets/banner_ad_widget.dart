import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/ad_manager.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final AdManager _adManager = AdManager();
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _adManager.loadBannerAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || !_adManager.isBannerAdReady || _adManager.bannerAd == null) {
      // Return a placeholder with appropriate height to prevent layout shifts
      return Container(
        height: 50, // Standard banner height
        color: Colors.grey.withOpacity(0.1),
        child: const Center(
          child: Text(
            'Advertisement',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      width: _adManager.bannerAd!.size.width.toDouble(),
      height: _adManager.bannerAd!.size.height.toDouble(),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AdWidget(ad: _adManager.bannerAd!),
      ),
    );
  }

  @override
  void dispose() {
    // Don't dispose the ad here since AdManager handles it
    super.dispose();
  }
}
