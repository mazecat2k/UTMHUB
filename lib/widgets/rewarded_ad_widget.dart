import 'package:flutter/material.dart';
import '../utils/ad_manager.dart';

class RewardedAdButton extends StatefulWidget {
  final VoidCallback? onRewardEarned;
  final String buttonText;
  
  const RewardedAdButton({
    Key? key,
    this.onRewardEarned,
    this.buttonText = 'Watch Ad for Reward',
  }) : super(key: key);

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  final AdManager _adManager = AdManager();

  @override
  void initState() {
    super.initState();
    _adManager.loadRewardedAd();
  }

  void _showRewardedAd() {
    if (_adManager.isRewardedAdReady) {
      _adManager.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          // User earned reward
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Reward earned: ${reward.amount} ${reward.type}'),
                backgroundColor: Colors.green,
              ),
            );
            widget.onRewardEarned?.call();
          }
        },
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rewarded ad not ready. Please try again later.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _adManager.isRewardedAdReady ? _showRewardedAd : null,
      icon: const Icon(Icons.play_arrow),
      label: Text(widget.buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: _adManager.isRewardedAdReady 
            ? const Color.fromRGBO(224, 167, 34, 1) 
            : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}

// Example usage widget - can be integrated into any screen
class RewardedAdExample extends StatefulWidget {
  const RewardedAdExample({Key? key}) : super(key: key);

  @override
  State<RewardedAdExample> createState() => _RewardedAdExampleState();
}

class _RewardedAdExampleState extends State<RewardedAdExample> {
  int _points = 0;

  void _onRewardEarned() {
    setState(() {
      _points += 10; // Give user 10 points for watching ad
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Your Points: $_points',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            RewardedAdButton(
              onRewardEarned: _onRewardEarned,
              buttonText: 'Watch Ad for 10 Points',
            ),
          ],
        ),
      ),
    );
  }
}
