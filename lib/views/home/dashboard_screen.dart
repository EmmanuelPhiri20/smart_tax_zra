import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/dashboard_controller.dart';
import '../../core/theme/colors.dart';

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
      body: Center(
        child: dashboard.currentUser == null
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, ${dashboard.currentUser!.email}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              "Current Tab: ${dashboard.tabs[dashboard.selectedIndex]}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: dashboard.selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        onTap: dashboard.onTabSelected,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payments"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.ac_unit), label: "Settings")
        ],
      ),
    );
  }
}
