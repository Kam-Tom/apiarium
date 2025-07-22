
import 'package:apiarium/shared/domain/enums/hive_material.dart';
import 'package:apiarium/shared/domain/models/hive_type.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HiveTypeDetailPage extends StatelessWidget {
  final HiveType hiveType;
  
  const HiveTypeDetailPage({
    super.key,
    required this.hiveType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/edit-hive-type',
                arguments: hiveType.id,
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildBasicInfoCard(),
              const SizedBox(height: 16),
              _buildFrameInfoCard(),
              const SizedBox(height: 16),
              _buildCapacityCard(),
              const SizedBox(height: 16),
              if (hiveType.accessories != null && hiveType.accessories!.isNotEmpty)
                _buildAccessoriesCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.amber.shade50,
                  ),
                  child: Icon(
                    Icons.home_work,
                    size: 40,
                    color: _getMaterialColor(),
                  ),
                ),
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
                      Row(
                        children: [
                          if (hiveType.isStarred)
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade700,
                              size: 20,
                            ),
                          if (hiveType.isLocal)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Local',
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getMaterialColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getMaterialText(),
                              style: TextStyle(
                                color: _getMaterialColor(),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildBasicInfoCard() {
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
                const Text(
                  'Basic Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Material', _getMaterialText()),
            _buildInfoRow('Has Frames', hiveType.hasFrames ? 'Yes' : 'No'),
            if (hiveType.frameStandard != null)
              _buildInfoRow('Frame Standard', hiveType.frameStandard!),
            if (hiveType.country != null)
              _buildInfoRow('Country', hiveType.country!),
            if (hiveType.cost != null)
              _buildInfoRow('Cost', '\$${hiveType.cost!.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildFrameInfoCard() {
    if (!hiveType.hasFrames) return const SizedBox.shrink();
    
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
                const Text(
                  'Frame Configuration',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hiveType.broodFrameCount != null)
              _buildInfoRow('Brood Frames', '${hiveType.broodFrameCount}'),
            if (hiveType.honeyFrameCount != null)
              _buildInfoRow('Honey Frames', '${hiveType.honeyFrameCount}'),
            if (hiveType.framesPerBox != null)
              _buildInfoRow('Frames per Box', '${hiveType.framesPerBox}'),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityCard() {
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
                const Text(
                  'Capacity Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hiveType.boxCount != null)
              _buildInfoRow('Box Count', '${hiveType.boxCount}'),
            if (hiveType.superBoxCount != null)
              _buildInfoRow('Super Box Count', '${hiveType.superBoxCount}'),
            if (hiveType.maxBroodFrameCount != null)
              _buildInfoRow('Max Brood Frames', '${hiveType.maxBroodFrameCount}'),
            if (hiveType.maxHoneyFrameCount != null)
              _buildInfoRow('Max Honey Frames', '${hiveType.maxHoneyFrameCount}'),
            if (hiveType.maxBoxCount != null)
              _buildInfoRow('Max Boxes', '${hiveType.maxBoxCount}'),
            if (hiveType.maxSuperBoxCount != null)
              _buildInfoRow('Max Super Boxes', '${hiveType.maxSuperBoxCount}'),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessoriesCard() {
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
                const Text(
                  'Accessories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Color _getMaterialColor() {
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

  String _getMaterialText() {
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