import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/theme/colors.dart';
import '../filing/filing_screen.dart';
import '../chat/chatbot_screen.dart'; // 👈 Import Chatbot screen
import '../settings/settings_screen.dart'; // 👈 Import Settings screen
import '../history/history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Pay ZRA"),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await dashboard.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      // ✅ Each tab shows the corresponding screen
      body: IndexedStack(
        index: dashboard.selectedIndex,
        children: [
          _buildHomeTab(context, dashboard), // Home (Analytics)
          const ChatbotScreen(), // 👈 Chatbot screen
          const FilingScreen(), // Filing
          const HistoryScreen(), // 👈 Now connected to real history tab
          const SettingsScreen(), // 👈 Settings screen
        ],
      ),

      // ✅ Bottom navigation controls tab switching
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: dashboard.selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: dashboard.onTabSelected,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.adb), label: "Chatbot"),
          BottomNavigationBarItem(
              icon: Icon(Icons.upload_file), label: "Filing"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  // ✅ Home Analytics Tab
  Widget _buildHomeTab(BuildContext context, DashboardController dashboard) {
    final total = dashboard.total;
    final anomalies = dashboard.anomalies;
    final normal = dashboard.normal;

    final anomalyPercent =
        total > 0 ? (anomalies / total * 100).toStringAsFixed(1) : "0";
    final normalPercent =
        total > 0 ? (normal / total * 100).toStringAsFixed(1) : "0";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📊 Fraud Detection Insights",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Summary Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statCard("Anomalies", anomalies, Colors.red, "$anomalyPercent%"),
              _statCard("Normal", normal, Colors.green, "$normalPercent%"),
              _statCard("Total", total, Colors.blue, ""),
            ],
          ),
          const SizedBox(height: 24),

          // Bar Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Fraud Detection Overview",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: total > 0 ? total.toDouble() : 10,
                      barTouchData: const BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 32),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text("Anomalies");
                                case 1:
                                  return const Text("Normal");
                                case 2:
                                  return const Text("Total");
                              }
                              return const Text("");
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: anomalies.toDouble(),
                              color: Colors.redAccent,
                              width: 25,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: normal.toDouble(),
                              color: Colors.green,
                              width: 25,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: total.toDouble(),
                              color: Colors.blue,
                              width: 25,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Insights
          _insightCard(anomalies, normal, total),
        ],
      ),
    );
  }

  Widget _statCard(String title, int value, Color color, String percent) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value.toString(),
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20, color: color)),
          if (percent.isNotEmpty)
            Text(percent,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _insightCard(int anomalies, int normal, int total) {
    String message;
    Color color;

    if (total == 0) {
      message = "No records analyzed yet.";
      color = Colors.grey;
    } else if (anomalies == 0) {
      message = "✅ All records look normal — great performance!";
      color = Colors.green;
    } else if (anomalies <= total * 0.2) {
      message = "⚠️ Few anomalies detected. Keep monitoring closely.";
      color = Colors.orange;
    } else {
      message = "🚨 High anomaly rate! Possible fraud detected!";
      color = Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
