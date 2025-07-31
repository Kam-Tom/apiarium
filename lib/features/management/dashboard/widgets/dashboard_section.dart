import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:apiarium/shared/services/dashboard_service.dart';

class DashboardSection extends StatelessWidget {
  final DashboardStats stats;

  const DashboardSection({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'dashboard.overview'.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('dashboard.apiaries'.tr(), '${stats.totalApiaries}', Icons.location_on, Colors.green),
                  _buildStatItem('dashboard.hives'.tr(), '${stats.activeHives}/${stats.totalHives}', Icons.home, Colors.blue),
                  _buildStatItem('dashboard.queens.title'.tr(), '${stats.totalQueens}', Icons.casino, Colors.purple),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.grey.shade200),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('dashboard.unassigned'.tr(), '${stats.unassignedQueens}', Icons.warning, Colors.orange),
                  _buildStatItem('dashboard.recent_inspections'.tr(), '${stats.recentInspections}', Icons.search, Colors.teal),
                  _buildStatItem('dashboard.need_attention'.tr(), '${stats.hivesNeedingAttention}', Icons.priority_high, Colors.red),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
