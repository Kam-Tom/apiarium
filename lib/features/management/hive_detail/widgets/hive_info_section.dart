import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/shared/shared.dart';
import 'dart:io';

class HiveInfoSection extends StatelessWidget {
  final Hive hive;
  final HiveType? hiveType;

  const HiveInfoSection({
    super.key,
    required this.hive,
    this.hiveType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoCard(),
            const SizedBox(height: 16),
            _buildHiveTypeCard(),
            if (hive.hasQueen) ...[
              const SizedBox(height: 16),
              _buildQueenCard(),
            ],
            const SizedBox(height: 16),
            _buildFramesCard(),
            const SizedBox(height: 16),
            _buildLocationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'details.hive.basicInfo'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'common.name'.tr(), value: hive.name),
            _InfoRow(label: 'common.status'.tr(), value: 'hive_status.${hive.status.name}'.tr()),
            _InfoRow(
              label: 'edit_hive.acquisition_date_title'.tr(),
              value: DateFormat('MMM dd, yyyy').format(hive.acquisitionDate),
            ),
            if (hive.order > 0)
              _InfoRow(label: 'edit_hive.order'.tr(), value: hive.order.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildHiveTypeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'details.hive_type'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(label: 'details.hive_type'.tr(), value: hive.hiveType),
                      if (hive.manufacturer != null)
                        _InfoRow(label: 'edit_hive_type.manufacturer'.tr(), value: hive.manufacturer!),
                      _InfoRow(label: 'edit_hive_type.material'.tr(), value: 'enums.HiveMaterial.${hive.material.name}'.tr()),
                      _InfoRow(label: 'edit_hive_type.has_frames'.tr(), value: hive.hasFrames ? 'common.yes'.tr() : 'common.no'.tr()),
                      if (hive.frameStandard != null)
                        _InfoRow(label: 'edit_hive_type.frame_standard'.tr(), value: hive.frameStandard!),
                    ],
                  ),
                ),
                if (hiveType != null) ...[
                  const SizedBox(width: 16),
                  _buildHiveTypeImage(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiveTypeImage() {
    return FutureBuilder<String?>(
      future: hiveType!.getLocalImagePath(),
      builder: (context, snapshot) {
        final localPath = snapshot.data;
        if (localPath != null && File(localPath).existsSync()) {
          return Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(localPath),
                fit: BoxFit.cover,
              ),
            ),
          );
        }
        // fallback if no image
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200, width: 2),
          ),
          child: HiveIcons(icon: 
            hiveType!.iconType,
            size: 40,
            color: Colors.amber.shade600,
          ),
        );
      },
    );
  }

  Widget _buildQueenCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'details.queen.title'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'details.queen.name'.tr(), value: hive.queenName ?? 'common.none'.tr()),
            if (hive.breed != null)
              _InfoRow(label: 'details.queen.breed'.tr(), value: hive.breed!),
            if (hive.queenBirthDate != null)
              _InfoRow(
                label: 'details.queen.birthDate'.tr(),
                value: DateFormat('MMM dd, yyyy').format(hive.queenBirthDate!),
              ),
            _InfoRow(
              label: 'details.queen.marked'.tr(),
              value: hive.queenMarked == true ? 'common.yes'.tr() : 'common.no'.tr(),
            ),
            if (hive.lastTimeQueenSeen != null)
              _InfoRow(
                label: 'details.queen.last_seen'.tr(),
                value: DateFormat('MMM dd, yyyy').format(hive.lastTimeQueenSeen!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFramesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'frames_and_boxes'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (hive.hasFrames) ...[
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'brood_frames'.tr(),
                      current: hive.currentBroodFrameCount ?? 0,
                      max: hive.maxBroodFrameCount ?? 0,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      title: 'normal_frames'.tr(),
                      current: hive.currentHoneyFrameCount ?? 0,
                      max: hive.maxHoneyFrameCount ?? 0,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'brood_boxes'.tr(),
                    current: hive.currentBoxCount ?? 0,
                    max: hive.maxBoxCount ?? 0,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    title: 'honey_supers'.tr(),
                    current: hive.currentSuperBoxCount ?? 0,
                    max: hive.maxSuperBoxCount ?? 0,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'edit_apiary.location'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'hives.apiary'.tr(),
              value: hive.apiaryName ?? 'hives.no_apiary'.tr(),
            ),
            if (hive.apiaryLocation != null)
              _InfoRow(label: 'edit_apiary.location_address'.tr(), value: hive.apiaryLocation!),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
                fontSize: 14,
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final int current;
  final int max;
  final Color color;

  const _StatCard({
    required this.title,
    required this.current,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = max > 0 ? (current / max * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$current/${max > 0 ? max : '-'}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (max > 0) ...[
            const SizedBox(height: 4),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
