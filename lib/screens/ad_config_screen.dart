import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdConfigScreen extends StatefulWidget {
  const AdConfigScreen({Key? key}) : super(key: key);

  @override
  State<AdConfigScreen> createState() => _AdConfigScreenState();
}

class _AdConfigScreenState extends State<AdConfigScreen> {
  final TextEditingController _bannerAdUnitController = TextEditingController();
  final TextEditingController _interstitialAdUnitController = TextEditingController();
  final TextEditingController _rewardedAdUnitController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }
  Future<void> _loadCurrentConfig() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('admin_config')
          .doc('ad_units')
          .get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _bannerAdUnitController.text = data['banner'] ?? 'ca-app-pub-8384063836870954/9246979173';
        _interstitialAdUnitController.text = data['interstitial'] ?? 'ca-app-pub-8384063836870954/2537831094';
        _rewardedAdUnitController.text = data['rewarded'] ?? 'ca-app-pub-8384063836870954/1104765275';
      } else {
        // Set default UTMHUB ad unit IDs
        _bannerAdUnitController.text = 'ca-app-pub-8384063836870954/9246979173';
        _interstitialAdUnitController.text = 'ca-app-pub-8384063836870954/2537831094';
        _rewardedAdUnitController.text = 'ca-app-pub-8384063836870954/1104765275';
      }
    } catch (e) {
      print('Error loading ad config: $e');
      // Set default UTMHUB ad unit IDs on error
      _bannerAdUnitController.text = 'ca-app-pub-8384063836870954/9246979173';
      _interstitialAdUnitController.text = 'ca-app-pub-8384063836870954/2537831094';
      _rewardedAdUnitController.text = 'ca-app-pub-8384063836870954/1104765275';
    }
  }

  Future<void> _saveAdConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('admin_config')
          .doc('ad_units')
          .set({
        'banner': _bannerAdUnitController.text,
        'interstitial': _interstitialAdUnitController.text,
        'rewarded': _rewardedAdUnitController.text,
        'lastUpdated': Timestamp.now(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ad configuration saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving configuration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Configuration'),
        backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [            const Text(
              'AdMob Configuration - UTMHUB',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'App ID: ca-app-pub-8384063836870954~4061266951\nConfigure your AdMob Ad Unit IDs. Currently using test IDs.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            Card(
              color: const Color.fromARGB(255, 37, 37, 37),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Banner Ad Unit ID',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),                    TextField(
                      controller: _bannerAdUnitController,
                      decoration: const InputDecoration(
                        hintText: 'ca-app-pub-8384063836870954/9246979173',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'UTMHUB Banner ID: ca-app-pub-8384063836870954/9246979173',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              color: const Color.fromARGB(255, 37, 37, 37),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Interstitial Ad Unit ID',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),                    TextField(
                      controller: _interstitialAdUnitController,
                      decoration: const InputDecoration(
                        hintText: 'ca-app-pub-8384063836870954/2537831094',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'UTMHUB Interstitial ID: ca-app-pub-8384063836870954/2537831094',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              color: const Color.fromARGB(255, 37, 37, 37),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rewarded Ad Unit ID',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),                    TextField(
                      controller: _rewardedAdUnitController,
                      decoration: const InputDecoration(
                        hintText: 'ca-app-pub-8384063836870954/1104765275',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'UTMHUB Rewarded ID: ca-app-pub-8384063836870954/1104765275',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAdConfig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Configuration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Important Notes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),                    SizedBox(height: 8),
                    Text(
                      '• Real UTMHUB Ad Unit IDs are now configured\n'
                      '• These will display actual ads and generate revenue\n'
                      '• Revenue tracking is active for all ad types\n'
                      '• Monitor performance via Revenue Analytics',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAdUnitController.dispose();
    _interstitialAdUnitController.dispose();
    _rewardedAdUnitController.dispose();
    super.dispose();
  }
}
