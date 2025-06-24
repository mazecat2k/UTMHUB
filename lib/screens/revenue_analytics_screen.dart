import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/ad_manager.dart';

class RevenueAnalyticsScreen extends StatefulWidget {
  const RevenueAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<RevenueAnalyticsScreen> createState() => _RevenueAnalyticsScreenState();
}

class _RevenueAnalyticsScreenState extends State<RevenueAnalyticsScreen> {
  List<Map<String, dynamic>> _revenueData = [];
  bool _isLoading = true;
  String _selectedPeriod = 'Last 7 Days';
  
  @override
  void initState() {
    super.initState();
    _loadRevenueData();
  }

  Future<void> _loadRevenueData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DateTime endDate = DateTime.now();
      DateTime startDate;

      switch (_selectedPeriod) {
        case 'Last 7 Days':
          startDate = endDate.subtract(const Duration(days: 6));
          break;
        case 'Last 30 Days':
          startDate = endDate.subtract(const Duration(days: 29));
          break;
        case 'Last 3 Months':
          startDate = DateTime(endDate.year, endDate.month - 3, endDate.day);
          break;
        default:
          startDate = endDate.subtract(const Duration(days: 6));
      }

      _revenueData = await AdManager.getRevenueRange(startDate, endDate);
    } catch (e) {
      print('Error loading revenue data: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue Analytics'),
        backgroundColor: const Color.fromRGBO(224, 167, 34, 1),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadRevenueData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
              const PopupMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days')),
              const PopupMenuItem(value: 'Last 3 Months', child: Text('Last 3 Months')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  _buildRevenueChart(),
                  const SizedBox(height: 24),
                  _buildClickChart(),
                  const SizedBox(height: 24),
                  _buildAdTypeBreakdown(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {    double totalRevenue = _revenueData.fold(0.0, (sum, day) => sum + (day['totalRevenue'] ?? 0.0));
    int totalClicks = _revenueData.fold(0, (sum, day) => sum + ((day['totalClicks'] ?? 0) as int));
    int totalImpressions = _revenueData.fold(0, (sum, day) => sum + ((day['totalImpressions'] ?? 0) as int));
    double avgCTR = _revenueData.isNotEmpty 
        ? _revenueData.fold(0.0, (sum, day) => sum + (day['ctr'] ?? 0.0)) / _revenueData.length
        : 0.0;

    return Row(
      children: [
        Expanded(child: _buildSummaryCard('Total Revenue', '\$${totalRevenue.toStringAsFixed(2)}', Icons.monetization_on, Colors.green)),
        const SizedBox(width: 8),
        Expanded(child: _buildSummaryCard('Total Clicks', totalClicks.toString(), Icons.touch_app, Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: _buildSummaryCard('Impressions', totalImpressions.toString(), Icons.visibility, Colors.orange)),
        const SizedBox(width: 8),
        Expanded(child: _buildSummaryCard('Avg CTR', '${avgCTR.toStringAsFixed(2)}%', Icons.trending_up, Colors.purple)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _revenueData.length) {
                            String date = _revenueData[value.toInt()]['date'];
                            return Text(
                              date.split('-')[2], // Show day only
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _revenueData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value['totalRevenue']?.toDouble() ?? 0.0);
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
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

  Widget _buildClickChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Clicks & Impressions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,                  maxY: _revenueData.fold<double>(0.0, (double max, day) {
                    double impressions = ((day['totalImpressions'] ?? 0) as int).toDouble();
                    return impressions > max ? impressions : max;
                  }),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _revenueData.length) {
                            String date = _revenueData[value.toInt()]['date'];
                            return Text(
                              date.split('-')[2],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _revenueData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: (entry.value['totalImpressions'] ?? 0).toDouble(),
                          color: Colors.blue.withOpacity(0.7),
                          width: 8,
                        ),
                        BarChartRodData(
                          toY: (entry.value['totalClicks'] ?? 0).toDouble(),
                          color: Colors.orange,
                          width: 8,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: Colors.blue.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                const Text('Impressions', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                const Text('Clicks', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdTypeBreakdown() {
    Map<String, int> totalBreakdown = {'banner': 0, 'interstitial': 0, 'rewarded': 0};
    
    for (var day in _revenueData) {
      Map<String, int> dayBreakdown = Map<String, int>.from(day['adTypeBreakdown'] ?? {});
      totalBreakdown['banner'] = (totalBreakdown['banner'] ?? 0) + (dayBreakdown['banner'] ?? 0);
      totalBreakdown['interstitial'] = (totalBreakdown['interstitial'] ?? 0) + (dayBreakdown['interstitial'] ?? 0);
      totalBreakdown['rewarded'] = (totalBreakdown['rewarded'] ?? 0) + (dayBreakdown['rewarded'] ?? 0);
    }

    int total = totalBreakdown.values.fold(0, (sum, value) => sum + value);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ad Type Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...totalBreakdown.entries.map((entry) {
              double percentage = total > 0 ? (entry.value / total * 100) : 0;
              Color color = entry.key == 'banner' ? Colors.blue : 
                           entry.key == 'interstitial' ? Colors.orange : Colors.green;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${entry.key.toUpperCase()}: ${entry.value} clicks (${percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
