import 'dart:io';

import 'package:apiarium/shared/domain/enums/hive_material.dart';
import 'package:apiarium/shared/domain/models/hive_type.dart';
import 'package:apiarium/shared/services/hive_service.dart';
import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/shared/widgets/icons/hive_app_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HiveTypeDetailPage extends StatefulWidget {
  final String hiveTypeId;
  
  const HiveTypeDetailPage({
    super.key,
    required this.hiveTypeId,
  });

  @override
  State<HiveTypeDetailPage> createState() => _HiveTypeDetailPageState();
}

class _HiveTypeDetailPageState extends State<HiveTypeDetailPage> {
  final HiveService _hiveService = getIt<HiveService>();
  HiveType? _hiveType;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHiveType();
  }

  Future<void> _loadHiveType() async {
    try {
      final hiveType = await _hiveService.getHiveTypeById(widget.hiveTypeId);
      if (mounted) {
        setState(() {
          _hiveType = hiveType;
          _isLoading = false;
          if (hiveType == null) {
            _error = 'Hive type not found';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load hive type: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text('common.loading'.tr()),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade800, Colors.amber.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _hiveType == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text('common.error'.tr()),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade800, Colors.amber.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Center(
          child: Text(_error ?? 'hive_type_detail.not_found'.tr()),
        ),
      );
    }

    final hiveType = _hiveType!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(hiveType.name),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade800, Colors.amber.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeaderCard(hiveType),
              const SizedBox(height: 16),
              _buildBasicInfoCard(hiveType),
              const SizedBox(height: 16),
              if (_hasFrameInfo(hiveType)) ...[
                _buildFrameInfoCard(hiveType),
                const SizedBox(height: 16),
              ],
              if (_hasCapacityInfo(hiveType)) ...[
                _buildCapacityCard(hiveType),
                const SizedBox(height: 16),
              ],
              if (hiveType.accessories != null && hiveType.accessories!.isNotEmpty) ...[
                _buildAccessoriesCard(hiveType),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(HiveType hiveType) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildHeaderImage(hiveType),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hiveType.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hiveType.manufacturer != null)
                        Text(
                          hiveType.manufacturer!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      const SizedBox(height: 8),
                      _buildBadges(hiveType),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage(HiveType hiveType) {
    return FutureBuilder<String?>(
      future: hiveType.getLocalImagePath(),
      builder: (context, snapshot) {
        final imagePath = snapshot.data;
        
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.amber.shade50,
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: imagePath != null && imagePath.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return HiveIcons(icon: 
                        hiveType.iconType,
                        size: 40,
                        color: _getMaterialColor(hiveType),
                      );
                    },
                  ),
                )
              : HiveIcons(icon: 
                  hiveType.iconType,
                  size: 40,
                  color: _getMaterialColor(hiveType),
                ),
        );
      },
    );
  }

  Widget _buildBadges(HiveType hiveType) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (hiveType.isStarred)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber.shade700, size: 16),
                const SizedBox(width: 4),
                Text(
                  'hive_type_detail.starred'.tr(),
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        if (hiveType.isLocal)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'hive_type_detail.local'.tr(),
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getMaterialColor(hiveType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getMaterialText(hiveType),
            style: TextStyle(
              color: _getMaterialColor(hiveType),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoCard(HiveType hiveType) {
    final basicInfoItems = <Widget>[];
    
    basicInfoItems.add(_buildInfoRow('edit_hive_type.material'.tr(), _getMaterialText(hiveType)));
    basicInfoItems.add(_buildInfoRow('edit_hive_type.has_frames'.tr(), hiveType.hasFrames ? 'common.yes'.tr() : 'common.no'.tr()));
    
    if (hiveType.frameStandard != null && hiveType.frameStandard!.isNotEmpty) {
      basicInfoItems.add(_buildInfoRow('edit_hive_type.frame_standard'.tr(), hiveType.frameStandard!));
    }
    if (hiveType.country != null && hiveType.country!.isNotEmpty) {
      basicInfoItems.add(_buildInfoRow('details.queen.country'.tr(), hiveType.country!));
    }
    if (hiveType.cost != null) {
      basicInfoItems.add(_buildInfoRow('edit_hive_type.cost'.tr(), '\$${hiveType.cost!.toStringAsFixed(2)}'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'hive_type_detail.basic_info'.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...basicInfoItems,
          ],
        ),
      ),
    );
  }

  bool _hasFrameInfo(HiveType hiveType) {
    if (!hiveType.hasFrames) return false;
    return hiveType.broodFrameCount != null ||
           hiveType.honeyFrameCount != null ||
           hiveType.framesPerBox != null;
  }

  Widget _buildFrameInfoCard(HiveType hiveType) {
    final frameInfoItems = <Widget>[];
    
    if (hiveType.broodFrameCount != null) {
      frameInfoItems.add(_buildInfoRow('brood_frames'.tr(), '${hiveType.broodFrameCount}'));
    }
    if (hiveType.honeyFrameCount != null) {
      frameInfoItems.add(_buildInfoRow('normal_frames'.tr(), '${hiveType.honeyFrameCount}'));
    }
    if (hiveType.framesPerBox != null) {
      frameInfoItems.add(_buildInfoRow('edit_hive_type.frames_per_box'.tr(), '${hiveType.framesPerBox}'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.grid_view, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'hive_type_detail.frame_config'.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...frameInfoItems,
          ],
        ),
      ),
    );
  }

  bool _hasCapacityInfo(HiveType hiveType) {
    return hiveType.boxCount != null ||
           hiveType.superBoxCount != null ||
           hiveType.maxBroodFrameCount != null ||
           hiveType.maxHoneyFrameCount != null ||
           hiveType.maxBoxCount != null ||
           hiveType.maxSuperBoxCount != null;
  }

  Widget _buildCapacityCard(HiveType hiveType) {
    final capacityInfoItems = <Widget>[];
    
    if (hiveType.boxCount != null) {
      capacityInfoItems.add(_buildInfoRow('box_count'.tr(), '${hiveType.boxCount}'));
    }
    if (hiveType.superBoxCount != null) {
      capacityInfoItems.add(_buildInfoRow('super_count'.tr(), '${hiveType.superBoxCount}'));
    }
    if (hiveType.maxBroodFrameCount != null) {
      capacityInfoItems.add(_buildInfoRow('hives.brood_frames'.tr(), '${hiveType.maxBroodFrameCount}'));
    }
    if (hiveType.maxHoneyFrameCount != null) {
      capacityInfoItems.add(_buildInfoRow('hives.honey_frames'.tr(), '${hiveType.maxHoneyFrameCount}'));
    }
    if (hiveType.maxBoxCount != null) {
      capacityInfoItems.add(_buildInfoRow('hives.boxes'.tr(), '${hiveType.maxBoxCount}'));
    }
    if (hiveType.maxSuperBoxCount != null) {
      capacityInfoItems.add(_buildInfoRow('hives.supers'.tr(), '${hiveType.maxSuperBoxCount}'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.layers, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'hive_type_detail.capacity_info'.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...capacityInfoItems,
          ],
        ),
      ),
    );
  }

  Widget _buildAccessoriesCard(HiveType hiveType) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                Text(
                  'edit_hive_type.accessories'.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hiveType.accessories!.map((accessory) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  accessory,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMaterialColor(HiveType hiveType) {
    switch (hiveType.material) {
      case HiveMaterial.wood:
        return Colors.brown;
      case HiveMaterial.plastic:
        return Colors.blue;
      case HiveMaterial.polystyrene:
        return Colors.green;
      case HiveMaterial.metal:
        return Colors.grey;
      default:
        return Colors.brown;
    }
  }

  String _getMaterialText(HiveType hiveType) {
    switch (hiveType.material) {
        case HiveMaterial.wood:
            return 'enums.HiveMaterial.wood'.tr();
        case HiveMaterial.plastic:
            return 'enums.HiveMaterial.plastic'.tr();
        case HiveMaterial.polystyrene:
            return 'enums.HiveMaterial.polystyrene'.tr();
        case HiveMaterial.metal:
            return 'enums.HiveMaterial.metal'.tr();
        default:
            return 'enums.HiveMaterial.other'.tr();
    }
  }
}