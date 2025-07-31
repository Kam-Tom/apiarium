import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/shared/shared.dart';
import 'dart:io';

class ApiaryInfoSection extends StatelessWidget {
  final Apiary apiary;

  const ApiaryInfoSection({super.key, required this.apiary});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildStatsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return FutureBuilder<String?>(
      future: apiary.getLocalImagePath(),
      builder: (context, snapshot) {
        final localPath = snapshot.data;
        if (localPath != null && File(localPath).existsSync()) {
          return Card(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(localPath),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        return Card(
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: apiary.color?.withValues(alpha: 0.3) ?? Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.location_on,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'details.apiary.basicInfo'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.label, 'common.name'.tr(), apiary.name),
            if (apiary.description != null && apiary.description!.isNotEmpty)
              _buildInfoRow(Icons.description, 'common.description'.tr(), apiary.description!),
            if (apiary.location != null && apiary.location!.isNotEmpty)
              _buildInfoRow(Icons.location_on, 'edit_apiary.location'.tr(), apiary.location!),
            _buildInfoRow(
              apiary.isMigratory ? Icons.transfer_within_a_station : Icons.location_city,
              'details.apiary.unknown_type'.tr(),
              apiary.isMigratory ? 'apiaries.migratory'.tr() : 'apiaries.stationary'.tr(),
            ),
            _buildInfoRow(Icons.flag, 'common.status'.tr(), apiary.status.name.tr()),
            _buildInfoRow(
              Icons.calendar_today,
              'common.date'.tr(),
              DateFormat('MMM dd, yyyy').format(apiary.createdAt),
            ),
            _buildInfoRow(
              Icons.check,
              'common.migratory'.tr(),
              apiary.isMigratory ? 'common.yes'.tr() : 'common.no'.tr(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'details.apiary.statistics'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.home,
                    'apiary_details.total_hives'.tr(),
                    apiary.hiveCount.toString(),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.check_circle,
                    'apiary_details.active_hives'.tr(),
                    apiary.activeHiveCount.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.amber.shade700),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
