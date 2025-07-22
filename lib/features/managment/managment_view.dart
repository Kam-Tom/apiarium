import 'package:apiarium/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:apiarium/features/managment/apiaries/apiaries_page.dart';
import 'package:apiarium/features/managment/hives/hives_page.dart';
import 'package:apiarium/features/managment/queens/queens_page.dart';
import 'package:go_router/go_router.dart';

class ManagmentView extends StatelessWidget {
  const ManagmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dynamicSpacing = screenWidth < 400 ? 8.0 : 16.0;

    return SafeArea(
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(dynamicSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map section first
                const Text(
                  'Apiary Locations',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: dynamicSpacing),
                _buildMapCard(),
                SizedBox(height: dynamicSpacing * 1.5),                // Management navigation buttons
                const Text(
                  'Management Options',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: dynamicSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavigationButton(
                      context, 
                      'Apiaries', 
                      Icons.location_on,
                      () => context.push(AppRouter.apiaries),
                    ),
                    _buildNavigationButton(
                      context, 
                      'Hives', 
                      Icons.home,
                      () => context.push(AppRouter.hives),
                    ),
                    _buildNavigationButton(
                      context, 
                      'Queens', 
                      Icons.casino,
                      () => context.push(AppRouter.queens),
                    ),                  ],
                ),
                
                SizedBox(height: dynamicSpacing),
                
                // Additional options - smaller buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildWideNavigationButton(
                        context,
                        'Queen Breeds',
                        Icons.pets,
                        () => context.push(AppRouter.queenBreeds),
                      ),
                    ),
                    SizedBox(width: dynamicSpacing),                    Expanded(
                      child: _buildWideNavigationButton(
                        context,
                        'Hive Types',
                        Icons.category,
                        () => context.push(AppRouter.hiveTypes),
                      ),
                    ),
                  ],
                ),                
                SizedBox(height: dynamicSpacing * 2),
                
                // Statistics section
                const Text(
                  'Statistics',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: dynamicSpacing),
                _buildStatisticsCard(),
                
                SizedBox(height: dynamicSpacing * 1.5),
                
                // Recent activity
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: dynamicSpacing),
                _buildRecentActivityList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
    Widget _buildNavigationButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.amber.shade800),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWideNavigationButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.amber.shade700),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.amber.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatisticsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Apiaries', '5', Icons.location_on),
                _buildStatItem('Hives', '32', Icons.home),
                _buildStatItem('Queens', '28', Icons.casino),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Active', '27', Icons.check_circle, Colors.green),
                _buildStatItem('Alerts', '3', Icons.warning, Colors.orange),
                _buildStatItem('Inspections', '12', Icons.calendar_today),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color ?? Colors.amber.shade700),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }
  
  Widget _buildMapCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            const Text('Map of your apiary locations'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Navigate to detailed map
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
              ),
              child: const Text('View Full Map'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentActivityList() {
    final activities = [
      {'title': 'Hive inspection', 'location': 'Apiary #1', 'time': '2 days ago'},
      {'title': 'Queen replaced', 'location': 'Hive #7', 'time': '1 week ago'},
      {'title': 'Honey harvest', 'location': 'Apiary #3', 'time': '2 weeks ago'},
    ];
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            title: Text(activity['title'] ?? ''),
            subtitle: Text(activity['location'] ?? ''),
            trailing: Text(activity['time'] ?? '', style: TextStyle(color: Colors.grey.shade600)),
            leading: CircleAvatar(
              backgroundColor: Colors.amber.shade100,
              child: const Icon(Icons.edit, color: Colors.amber),
            ),
          );
        },
      ),
    );
  }
}