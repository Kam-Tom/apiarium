import 'dart:io';

import 'package:apiarium/shared/domain/models/queen_breed.dart';
import 'package:apiarium/shared/services/queen_service.dart';
import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class QueenBreedDetailPage extends StatefulWidget {
  final String breedId;
  
  const QueenBreedDetailPage({
    super.key,
    required this.breedId,
  });

  @override
  State<QueenBreedDetailPage> createState() => _QueenBreedDetailPageState();
}

class _QueenBreedDetailPageState extends State<QueenBreedDetailPage> {
  final QueenService _queenService = getIt<QueenService>();
  QueenBreed? _queenBreed;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadQueenBreed();
  }

  Future<void> _loadQueenBreed() async {
    try {
      final breeds = await _queenService.getAllQueenBreeds();
      final breed = breeds.where((b) => b.id == widget.breedId).firstOrNull;
      
      if (mounted) {
        setState(() {
          _queenBreed = breed;
          _isLoading = false;
          if (breed == null) {
            _error = 'Queen breed not found';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load queen breed: $e';
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

    if (_error != null || _queenBreed == null) {
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
          child: Text(_error ?? 'queen_breed_detail.not_found'.tr()),
        ),
      );
    }

    final queenBreed = _queenBreed!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(queenBreed.name),
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
              _buildHeaderCard(queenBreed),
              const SizedBox(height: 16),
              _buildBasicInfoCard(queenBreed),
              const SizedBox(height: 16),
              if (_hasCharacteristics(queenBreed)) ...[
                _buildCharacteristicsCard(queenBreed),
                const SizedBox(height: 16),
              ],
              if (_hasOriginInfo(queenBreed)) ...[
                _buildOriginCard(queenBreed),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(QueenBreed queenBreed) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildHeaderImage(queenBreed),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        queenBreed.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (queenBreed.scientificName != null)
                        Text(
                          queenBreed.scientificName!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      const SizedBox(height: 8),
                      _buildBadges(queenBreed),
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

  Widget _buildHeaderImage(QueenBreed queenBreed) {
    return FutureBuilder<String?>(
      future: queenBreed.getLocalImagePath(),
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
                      return Icon(
                        Icons.pets,
                        size: 40,
                        color: Colors.amber.shade700,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.pets,
                  size: 40,
                  color: Colors.amber.shade700,
                ),
        );
      },
    );
  }

  Widget _buildBadges(QueenBreed queenBreed) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (queenBreed.isStarred)
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
                  'queen_breed_detail.starred'.tr(),
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        if (queenBreed.isLocal)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'queen_breed_detail.local'.tr(),
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfoCard(QueenBreed queenBreed) {
    final basicInfoItems = <Widget>[];
    
    if (queenBreed.origin != null && queenBreed.origin!.isNotEmpty) {
      basicInfoItems.add(_buildInfoRow('queen_breed_detail.origin'.tr(), queenBreed.origin!));
    }
    if (queenBreed.country != null && queenBreed.country!.isNotEmpty) {
      basicInfoItems.add(_buildInfoRow('queen_breed_detail.country'.tr(), queenBreed.country!));
    }
    if (queenBreed.cost != null) {
      basicInfoItems.add(_buildInfoRow('queen_breed_detail.cost'.tr(), '\$${queenBreed.cost!.toStringAsFixed(2)}'));
    }
    if (queenBreed.characteristics != null && queenBreed.characteristics!.isNotEmpty) {
      basicInfoItems.add(_buildInfoRow('queen_breed_detail.characteristics'.tr(), queenBreed.characteristics!));
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
                  'queen_breed_detail.basic_info'.tr(),
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

  bool _hasCharacteristics(QueenBreed queenBreed) {
    return queenBreed.honeyProductionRating != null ||
           queenBreed.springDevelopmentRating != null ||
           queenBreed.gentlenessRating != null ||
           queenBreed.swarmingTendencyRating != null ||
           queenBreed.winterHardinessRating != null ||
           queenBreed.diseaseResistanceRating != null ||
           queenBreed.heatToleranceRating != null;
  }

  Widget _buildCharacteristicsCard(QueenBreed queenBreed) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'edit_queen_breed.breed_characteristics'.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (queenBreed.honeyProductionRating != null)
              _buildCharacteristicRow(
                'edit_queen_breed.honey_production'.tr(),
                queenBreed.honeyProductionRating!,
                [
                  'edit_queen_breed.very_low'.tr(),
                  'edit_queen_breed.low'.tr(),
                  'edit_queen_breed.medium'.tr(),
                  'edit_queen_breed.high'.tr(),
                  'edit_queen_breed.very_high'.tr(),
                ],
              ),
            if (queenBreed.springDevelopmentRating != null) ...[
              const SizedBox(height: 12),
              _buildCharacteristicRow(
                'edit_queen_breed.spring_development'.tr(),
                queenBreed.springDevelopmentRating!,
                [
                  'edit_queen_breed.very_slow'.tr(),
                  'edit_queen_breed.slow'.tr(),
                  'edit_queen_breed.moderate'.tr(),
                  'edit_queen_breed.fast'.tr(),
                  'edit_queen_breed.very_fast'.tr(),
                ],
              ),
            ],
            if (queenBreed.gentlenessRating != null) ...[
              const SizedBox(height: 12),
              _buildCharacteristicRow(
                'edit_queen_breed.gentleness'.tr(),
                queenBreed.gentlenessRating!,
                [
                  'edit_queen_breed.very_aggressive'.tr(),
                  'edit_queen_breed.aggressive'.tr(),
                  'edit_queen_breed.moderate'.tr(),
                  'edit_queen_breed.gentle'.tr(),
                  'edit_queen_breed.very_gentle'.tr(),
                ],
              ),
            ],
            if (queenBreed.swarmingTendencyRating != null) ...[
              const SizedBox(height: 12),
              _buildCharacteristicRow(
                'edit_queen_breed.swarming_tendency'.tr(),
                queenBreed.swarmingTendencyRating!,
                [
                  'edit_queen_breed.very_high'.tr(),
                  'edit_queen_breed.high'.tr(),
                  'edit_queen_breed.moderate'.tr(),
                  'edit_queen_breed.low'.tr(),
                  'edit_queen_breed.very_low'.tr(),
                ],
              ),
            ],
            if (queenBreed.winterHardinessRating != null) ...[
              const SizedBox(height: 12),
              _buildCharacteristicRow(
                'edit_queen_breed.winter_hardiness'.tr(),
                queenBreed.winterHardinessRating!,
                [
                  'edit_queen_breed.very_poor'.tr(),
                  'edit_queen_breed.poor'.tr(),
                  'edit_queen_breed.average'.tr(),
                  'edit_queen_breed.good'.tr(),
                  'edit_queen_breed.excellent'.tr(),
                ],
              ),
            ],
            if (queenBreed.diseaseResistanceRating != null) ...[
              const SizedBox(height: 12),
              _buildCharacteristicRow(
                'edit_queen_breed.disease_resistance'.tr(),
                queenBreed.diseaseResistanceRating!,
                [
                  'edit_queen_breed.very_poor'.tr(),
                  'edit_queen_breed.poor'.tr(),
                  'edit_queen_breed.average'.tr(),
                  'edit_queen_breed.good'.tr(),
                  'edit_queen_breed.excellent'.tr(),
                ],
              ),
            ],
            if (queenBreed.heatToleranceRating != null) ...[
              const SizedBox(height: 12),
              _buildCharacteristicRow(
                'edit_queen_breed.heat_tolerance'.tr(),
                queenBreed.heatToleranceRating!,
                [
                  'edit_queen_breed.very_poor'.tr(),
                  'edit_queen_breed.poor'.tr(),
                  'edit_queen_breed.average'.tr(),
                  'edit_queen_breed.good'.tr(),
                  'edit_queen_breed.excellent'.tr(),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasOriginInfo(QueenBreed queenBreed) {
    return (queenBreed.origin != null && queenBreed.origin!.isNotEmpty) ||
           (queenBreed.country != null && queenBreed.country!.isNotEmpty);
  }

  Widget _buildOriginCard(QueenBreed queenBreed) {
    final originInfoItems = <Widget>[];
    
    if (queenBreed.origin != null && queenBreed.origin!.isNotEmpty) {
      originInfoItems.add(_buildInfoRow('queen_breed_detail.origin'.tr(), queenBreed.origin!));
    }
    if (queenBreed.country != null && queenBreed.country!.isNotEmpty) {
      originInfoItems.add(_buildInfoRow('queen_breed_detail.country'.tr(), queenBreed.country!));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.public, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'queen_breed_detail.origin_info'.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...originInfoItems,
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicRow(String label, int rating, List<String> labels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 16,
                  color: index < rating ? Colors.amber : Colors.grey.shade300,
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          labels[rating - 1],
          style: TextStyle(
            color: Colors.amber.shade700,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
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
}