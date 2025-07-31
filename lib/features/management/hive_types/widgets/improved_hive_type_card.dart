import 'dart:io';

import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/features/management/hive_types/bloc/hive_types_bloc.dart';
import 'package:apiarium/features/management/hive_types/bloc/hive_types_event.dart';
import 'package:apiarium/shared/domain/enums/hive_material.dart';
import 'package:apiarium/shared/domain/models/hive_type.dart';
import 'package:apiarium/shared/widgets/icons/hive_app_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ImprovedHiveTypeCard extends StatelessWidget {
  final HiveType hiveType;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ImprovedHiveTypeCard({
    super.key,
    required this.hiveType,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () {
          context.push(
            AppRouter.hiveTypeDetail,
            extra: hiveType.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildProfileImage(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 8),
                    _buildBasicInfo(),
                  ],
                ),
              ),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final materialColor = _getMaterialColor(hiveType.material);
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: materialColor.withValues(alpha:0.1),
              border: Border.all(color: materialColor.withValues(alpha:0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder<String?>(
                future: hiveType.getLocalImagePath(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.file(
                      File(snapshot.data!),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    );
                  }
                  return HiveIcons(
                    icon: hiveType.iconType,
                    size: 30,
                    color: materialColor.withValues(alpha:0.6),
                  );
                },
              ),
            ),
          ),
          if (hiveType.imageName != null)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: HiveIcons(
                  icon: hiveType.iconType,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hiveType.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (hiveType.manufacturer?.isNotEmpty == true)
                Text(
                  hiveType.manufacturer!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    final List<Widget> infoChips = [
      _buildInfoChip(Icons.handyman, _getMaterialName(hiveType.material), _getMaterialColor(hiveType.material)),
    ];

    if (hiveType.isLocal) {
      infoChips.add(_buildInfoChip(Icons.home, 'hive_types.local'.tr(), Colors.orange));
    }
    if (hiveType.cost != null) {
      infoChips.add(_buildInfoChip(Icons.attach_money, 'hive_types.cost_label'.tr(args: [hiveType.cost!.toStringAsFixed(0)]), Colors.purple));
    }
    if (hiveType.country?.isNotEmpty == true) {
      infoChips.add(_buildInfoChip(Icons.flag, hiveType.country!, Colors.blue));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: infoChips,
        ),
        if (hiveType.hasFrames) ...[
          const SizedBox(height: 8),
          _buildFrameInfoSummary(),
        ],
      ],
    );
  }

  Widget _buildFrameInfoSummary() {
    final List<String> frameInfo = [];
    if (hiveType.framesPerBox != null) {
      frameInfo.add('${hiveType.framesPerBox}/box');
    }
    if ((hiveType.broodFrameCount ?? 0) > 0) {
      frameInfo.add('${hiveType.broodFrameCount} brood');
    }
    if ((hiveType.honeyFrameCount ?? 0) > 0) {
      frameInfo.add('${hiveType.honeyFrameCount} honey');
    }
    if ((hiveType.boxCount ?? 0) > 0) {
      frameInfo.add('${hiveType.boxCount} boxes');
    }
    if (frameInfo.isEmpty) return const SizedBox.shrink();
    return Text(
      frameInfo.join(' • '),
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            context.read<HiveTypesBloc>().add(ToggleHiveTypeStar(hiveType.id));
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              hiveType.isStarred ? Icons.star : Icons.star_border,
              color: hiveType.isStarred ? Colors.amber : Colors.grey,
              size: 24,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showDeleteDialog(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.delete, color: Colors.red, size: 20),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('hive_types.delete_title'.tr()),
        content: Text('hive_types.delete_confirm'.tr(args: [hiveType.name])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('hive_types.delete_title'.tr()),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      onDelete?.call();
    }
  }

  Color _getMaterialColor(HiveMaterial material) {
    switch (material) {
      case HiveMaterial.wood:
        return Colors.brown;
      case HiveMaterial.plastic:
        return Colors.blue;
      case HiveMaterial.polystyrene:
        return Colors.green;
      case HiveMaterial.metal:
        return Colors.grey;
      case HiveMaterial.other:
        return Colors.orange;
    }
  }

  String _getMaterialName(HiveMaterial material) {
    switch (material) {
      case HiveMaterial.wood:
        return 'enums.HiveMaterial.wood'.tr();
      case HiveMaterial.plastic:
        return 'enums.HiveMaterial.plastic'.tr();
      case HiveMaterial.polystyrene:
        return 'enums.HiveMaterial.polystyrene'.tr();
      case HiveMaterial.metal:
        return 'enums.HiveMaterial.metal'.tr();
      case HiveMaterial.other:
        return 'enums.HiveMaterial.other'.tr();
    }
  }
}