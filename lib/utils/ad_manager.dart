import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();  // UTMHUB Real Ad Unit IDs from AdMob Console
  // App ID: ca-app-pub-8384063836870954~4061266951
  static const String _bannerAdUnitId = 'ca-app-pub-8384063836870954/9246979173';
  static const String _interstitialAdUnitId = 'ca-app-pub-8384063836870954/2537831094';
  static const String _rewardedAdUnitId = 'ca-app-pub-8384063836870954/1104765275';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;

  // Initialize AdMob
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Banner Ad Methods
  void loadBannerAd({Function()? onAdLoaded}) {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerAdReady = true;
          _trackAdEvent('banner', 'loaded');
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, err) {
          _isBannerAdReady = false;
          ad.dispose();
          print('Banner ad failed to load: $err');
        },
        onAdClicked: (_) {
          _trackAdEvent('banner', 'clicked');
        },
      ),
    );
    _bannerAd!.load();
  }

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdReady => _isBannerAdReady;

  // Interstitial Ad Methods
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _trackAdEvent('interstitial', 'loaded');
          
          _interstitialAd!.setImmersiveMode(true);
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdClicked: (_) => _trackAdEvent('interstitial', 'clicked'),
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _isInterstitialAdReady = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isInterstitialAdReady = false;
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _trackAdEvent('interstitial', 'shown');
      _interstitialAd!.show();
    }
  }

  bool get isInterstitialAdReady => _isInterstitialAdReady;

  // Rewarded Ad Methods
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          _trackAdEvent('rewarded', 'loaded');

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdClicked: (_) => _trackAdEvent('rewarded', 'clicked'),
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _isRewardedAdReady = false;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isRewardedAdReady = false;
          print('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  void showRewardedAd({Function(AdWithoutView, RewardItem)? onUserEarnedReward}) {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _trackAdEvent('rewarded', 'shown');
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          _trackAdEvent('rewarded', 'reward_earned');
          onUserEarnedReward?.call(ad, reward);
        },
      );
    }
  }

  bool get isRewardedAdReady => _isRewardedAdReady;

  // Track ad events for revenue reporting
  Future<void> _trackAdEvent(String adType, String event) async {
    try {
      await FirebaseFirestore.instance.collection('ad_analytics').add({
        'adType': adType,
        'event': event,
        'timestamp': Timestamp.now(),
        'date': DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD format
        'revenue': _calculateRevenue(adType, event),
      });
    } catch (e) {
      print('Error tracking ad event: $e');
    }
  }

  // Calculate estimated revenue based on industry standards
  double _calculateRevenue(String adType, String event) {
    if (event != 'clicked' && event != 'reward_earned') return 0.0;
    
    switch (adType) {
      case 'banner':
        return 0.01; // $0.01 per click (typical banner CPM)
      case 'interstitial':
        return 0.05; // $0.05 per click (higher value)
      case 'rewarded':
        return 0.10; // $0.10 per completion (highest value)
      default:
        return 0.0;
    }
  }

  // Get daily revenue report
  static Future<Map<String, dynamic>> getDailyRevenue(DateTime date) async {
    String dateStr = date.toIso8601String().split('T')[0];
    
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('ad_analytics')
        .where('date', isEqualTo: dateStr)
        .get();

    double totalRevenue = 0.0;
    int totalClicks = 0;
    int totalImpressions = 0;
    Map<String, int> adTypeBreakdown = {
      'banner': 0,
      'interstitial': 0,
      'rewarded': 0,
    };

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String adType = data['adType'] ?? '';
      String event = data['event'] ?? '';
      double revenue = (data['revenue'] ?? 0.0).toDouble();

      totalRevenue += revenue;

      if (event == 'clicked' || event == 'reward_earned') {
        totalClicks++;
        adTypeBreakdown[adType] = (adTypeBreakdown[adType] ?? 0) + 1;
      } else if (event == 'loaded' || event == 'shown') {
        totalImpressions++;
      }
    }

    return {
      'totalRevenue': totalRevenue,
      'totalClicks': totalClicks,
      'totalImpressions': totalImpressions,
      'adTypeBreakdown': adTypeBreakdown,
      'ctr': totalImpressions > 0 ? (totalClicks / totalImpressions * 100) : 0.0,
    };
  }

  // Get revenue for date range
  static Future<List<Map<String, dynamic>>> getRevenueRange(
      DateTime startDate, DateTime endDate) async {
    List<Map<String, dynamic>> revenueData = [];
    
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      Map<String, dynamic> dayData = await getDailyRevenue(currentDate);
      dayData['date'] = currentDate.toIso8601String().split('T')[0];
      revenueData.add(dayData);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return revenueData;
  }

  // Dispose all ads
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
