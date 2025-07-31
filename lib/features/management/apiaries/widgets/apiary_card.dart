import 'package:flutter/material.dart';
import 'dart:io';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/core/router/app_router.dart';
import 'package:go_router/go_router.dart';

class ApiaryCard extends StatelessWidget {
  final Apiary apiary;
  final VoidCallback onTap;
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const ApiaryCard({
    super.key,
    required this.apiary,
    required this.onTap,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = apiary.color ?? AppTheme.primaryColor;
    final bool isMigratory = apiary.isMigratory;
    final Color migratoryColor = isMigratory ? Colors.teal : Colors.orange;
    final String migratoryText = isMigratory
        ? 'apiaries.migratory'.tr()
        : 'apiaries.stationary'.tr();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push(
            AppRouter.apiaryDetail,
            extra: {'apiaryId': apiary.id},
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildApiaryBanner(accentColor),
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
                child: Center(
                  child: Text(
                    apiary.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((apiary.location != null && apiary.location!.trim().isNotEmpty) || true)
                      Row(
                        children: [
                          if (apiary.location != null && apiary.location!.trim().isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.teal),
                                const SizedBox(width: 6),
                                // Limit the width of the location text to avoid overlap
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 150), // adjust as needed
                                  child: Text(
                                    apiary.location!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: migratoryColor.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isMigratory
                                      ? Icons.transfer_within_a_station
                                      : Icons.location_city,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  migratoryText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (apiary.description != null && apiary.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        apiary.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.home, size: 16, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          '${apiary.activeHiveCount}/${apiary.hiveCount} ${'hives.hives'.tr()}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.calendar_today, size: 15, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM yyyy').format(apiary.createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
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

  Widget _buildApiaryBanner(Color accentColor) {
    return FutureBuilder<String?>(
      future: apiary.getLocalImagePath(),
      builder: (context, snapshot) {
        final localPath = snapshot.data;
        if (localPath != null && File(localPath).existsSync()) {
          return Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(localPath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultBanner(accentColor),
              ),
            ),
          );
        } else {
          return _buildDefaultBanner(accentColor);
        }
      },
    );
  }

  Widget _buildDefaultBanner(Color accentColor) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: apiary.color != null
            ? apiary.color!.withValues(alpha: 0.25)
            : Colors.grey.shade200,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Center(
        child: Icon(
          Icons.location_on,
          size: 40,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}