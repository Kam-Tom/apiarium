import 'package:flutter/material.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

class HiveCard extends StatelessWidget {
  final Hive hive;
  final VoidCallback onTap;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;
  final DateTime? lastInspectionDate;

  const HiveCard({
    super.key,
    required this.hive,
    required this.onTap,
    required this.onEditTap,
    required this.onDeleteTap,
    this.lastInspectionDate,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = hive.color ?? AppTheme.primaryColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHiveImageOrIcon(),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hive.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    hive.hiveType,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: accentColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildStatusBadge(context, hive.status),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _InfoItem(
                          label: 'hives.apiary'.tr(),
                          value: hive.apiaryName ?? 'hives.no_apiary'.tr(),
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(width: 8),
                        _InfoItem(
                          label: 'hives.queen'.tr(),
                          value: hive.queenName ?? 'hives.no_queen'.tr(),
                          icon: Icons.pets,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _FrameProgressBars(
                      honeyCurrent: hive.honeyFrameCount ?? 0,
                      honeyMax: hive.maxHoneyFrameCount ?? 0,
                      broodCurrent: hive.broodFrameCount ?? 0,
                      broodMax: hive.maxBroodFrameCount ?? 0,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _BoxCountItem(
                          icon: Icons.view_module,
                          label: 'hives.boxes'.tr(),
                          count: hive.boxCount ?? 0,
                        ),
                        const SizedBox(width: 12),
                        _BoxCountItem(
                          icon: Icons.layers,
                          label: 'hives.supers'.tr(),
                          count: hive.superBoxCount ?? 0,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (lastInspectionDate != null)
                      Row(
                        children: [
                          Icon(Icons.search, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            '${'hives.last_inspection'.tr()}: ${_formatDate(lastInspectionDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: onEditTap,
                          icon: const Icon(Icons.edit, size: 18),
                          label: Text('common.edit'.tr()),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: onDeleteTap,
                          icon: const Icon(Icons.delete, size: 18),
                          label: Text('common.delete'.tr()),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHiveImageOrIcon() {
    if (hive.imageUrl != null) {
      return Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: NetworkImage(hive.imageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: (hive.color ?? Colors.amber.shade300).withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(Icons.home, size: 32, color: Colors.white),
        ),
      );
    }
  }

  Widget _buildStatusBadge(BuildContext context, HiveStatus status) {
    Color badgeColor;
    String statusText;
    IconData iconData;

    switch (status) {
      case HiveStatus.active:
        badgeColor = Colors.green;
        statusText = 'hive_status.active'.tr();
        iconData = Icons.check_circle;
        break;
      case HiveStatus.inactive:
        badgeColor = Colors.grey;
        statusText = 'hive_status.inactive'.tr();
        iconData = Icons.pause_circle;
        break;
      case HiveStatus.archived:
        badgeColor = Colors.red;
        statusText = 'hive_status.archived'.tr();
        iconData = Icons.archive;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 12, color: badgeColor),
          const SizedBox(width: 3),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  icon,
                  size: 10,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FrameProgressBars extends StatelessWidget {
  final int honeyCurrent;
  final int honeyMax;
  final int broodCurrent;
  final int broodMax;

  const _FrameProgressBars({
    Key? key,
    required this.honeyCurrent,
    required this.honeyMax,
    required this.broodCurrent,
    required this.broodMax,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProgressBarWithLabel(
          label: 'hives.honey_frames'.tr(),
          current: honeyCurrent,
          max: honeyMax,
          color: Colors.amber.shade700,
        ),
        const SizedBox(height: 6),
        _ProgressBarWithLabel(
          label: 'hives.brood_frames'.tr(),
          current: broodCurrent,
          max: broodMax,
          color: Colors.brown.shade400,
        ),
      ],
    );
  }
}

class _ProgressBarWithLabel extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;

  const _ProgressBarWithLabel({
    Key? key,
    required this.label,
    required this.current,
    required this.max,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double percent = (max > 0) ? (current / max).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$current/${max > 0 ? max : "-"}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _BoxCountItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _BoxCountItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}