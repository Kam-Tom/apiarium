import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/shared/shared.dart';
import 'dart:io';

class QueenInfoSection extends StatelessWidget {
  final Queen queen;
  final QueenBreed? queenBreed;

  const QueenInfoSection({
    super.key, 
    required this.queen,
    this.queenBreed,
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
            _buildBreedInfoCard(),
            const SizedBox(height: 16),
            _buildMarkingCard(),
            const SizedBox(height: 16),
            _buildLocationCard(),
            if (queenBreed != null && _hasBreedCharacteristics()) ...[
              const SizedBox(height: 16),
              _buildBreedCharacteristicsCard(),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasBreedCharacteristics() {
    if (queenBreed == null) return false;
    return queenBreed!.honeyProductionRating != null ||
           queenBreed!.springDevelopmentRating != null ||
           queenBreed!.gentlenessRating != null ||
           queenBreed!.swarmingTendencyRating != null ||
           queenBreed!.winterHardinessRating != null ||
           queenBreed!.diseaseResistanceRating != null ||
           queenBreed!.heatToleranceRating != null ||
           (queenBreed!.characteristics != null && queenBreed!.characteristics!.isNotEmpty);
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'details.queen.basicInfo'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'common.name'.tr(), value: queen.name),
            _InfoRow(label: 'details.queen.status'.tr(), value: _getStatusDisplay()),
            _InfoRow(
              label: 'details.queen.birthDate'.tr(),
              value: DateFormat('MMM dd, yyyy').format(queen.birthDate),
            ),
            _InfoRow(
              label: 'details.queen.age'.tr(),
              value: _formatAge(),
            ),
            _InfoRow(label: 'details.queen.source'.tr(), value: _getSourceDisplay()),
          ],
        ),
      ),
    );
  }

  Widget _buildBreedInfoCard() {
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
                        'details.queen.breedCharacteristics'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(label: 'details.queen.breed'.tr(), value: queen.breedName),
                      if (queen.breedScientificName != null)
                        _InfoRow(label: 'details.queen.scientificName'.tr(), value: queen.breedScientificName!),
                      if (queen.breedOrigin != null && queen.breedOrigin!.isNotEmpty)
                        _InfoRow(label: 'details.queen.origin'.tr(), value: queen.breedOrigin!),
                      if (queen.origin != null && queen.origin!.isNotEmpty)
                        _InfoRow(label: 'details.queen.origin'.tr(), value: queen.origin!),
                    ],
                  ),
                ),
                if (queenBreed != null) ...[
                  const SizedBox(width: 16),
                  _buildBreedImage(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreedImage() {
    return FutureBuilder<String?>(
      future: queenBreed!.getLocalImagePath(),
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
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: queen.markColor?.withValues(alpha: 0.3) ?? Colors.amber.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade200, width: 2),
          ),
          child: Icon(
            Icons.pets,
            size: 40,
            color: Colors.grey.shade400,
          ),
        );
      },
    );
  }

  Widget _buildMarkingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'details.queen.marked'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'details.queen.marked'.tr(),
              value: queen.marked ? 'common.yes'.tr() : 'common.no'.tr(),
            ),
            if (queen.marked && queen.markColor != null)
              _ColorRow(
                label: 'details.queen.markColor'.tr(),
                color: queen.markColor!,
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
              'details.queen.location'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'details.queen.hive'.tr(),
              value: queen.hiveName ?? 'details.queen.no_hive'.tr(),
            ),
            _InfoRow(
              label: 'details.queen.apiary'.tr(),
              value: queen.apiaryName ?? 'details.queen.unknown_apiary'.tr(),
            ),
            if (queen.apiaryLocation != null)
              _InfoRow(label: 'details.queen.location'.tr(), value: queen.apiaryLocation!),
            if (queen.lastTimeSeen != null)
              _InfoRow(
                label: 'details.queen.lastTimeSeen'.tr(),
                value: DateFormat('MMM dd, yyyy HH:mm').format(queen.lastTimeSeen!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreedCharacteristicsCard() {
    if (queenBreed == null || !_hasBreedCharacteristics()) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'details.queen.breedCharacteristics'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (queenBreed!.honeyProductionRating != null)
              _RatingRow(
                label: 'details.queen.honeyProduction'.tr(),
                rating: queenBreed!.honeyProductionRating!,
              ),
            if (queenBreed!.springDevelopmentRating != null)
              _RatingRow(
                label: 'edit_queen_breed.spring_development'.tr(),
                rating: queenBreed!.springDevelopmentRating!,
              ),
            if (queenBreed!.gentlenessRating != null)
              _RatingRow(
                label: 'edit_queen_breed.gentleness'.tr(),
                rating: queenBreed!.gentlenessRating!,
              ),
            if (queenBreed!.swarmingTendencyRating != null)
              _RatingRow(
                label: 'edit_queen_breed.swarming_tendency'.tr(),
                rating: queenBreed!.swarmingTendencyRating!,
              ),
            if (queenBreed!.winterHardinessRating != null)
              _RatingRow(
                label: 'details.queen.winterHardiness'.tr(),
                rating: queenBreed!.winterHardinessRating!,
              ),
            if (queenBreed!.diseaseResistanceRating != null)
              _RatingRow(
                label: 'details.queen.diseaseResistance'.tr(),
                rating: queenBreed!.diseaseResistanceRating!,
              ),
            if (queenBreed!.heatToleranceRating != null)
              _RatingRow(
                label: 'edit_queen_breed.heat_tolerance'.tr(),
                rating: queenBreed!.heatToleranceRating!,
              ),
            if (queenBreed!.characteristics != null && queenBreed!.characteristics!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoRow(
                label: 'details.queen.characteristics'.tr(),
                value: queenBreed!.characteristics!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatAge() {
    final years = queen.ageInYears;
    final days = queen.ageInDays;
    
    if (years >= 1) {
      return '${years.toStringAsFixed(1)} ${'details.queen.yearsOld'.tr(args: [days.toString()])}';
    } else if (days >= 30) {
      final months = (days / 30.44).round();
      return '$months ${'common.months'.tr()} ($days ${'common.days'.tr()})';
    } else {
      return '$days ${'common.days'.tr()}';
    }
  }

  String _getStatusDisplay() {
    switch (queen.status) {
      case QueenStatus.active:
        return 'management.queens.status.active'.tr();
      case QueenStatus.dead:
        return 'management.queens.status.dead'.tr();
      case QueenStatus.replaced:
        return 'management.queens.status.replaced'.tr();
      case QueenStatus.lost:
        return 'management.queens.status.lost'.tr();
      case QueenStatus.superseded:
        return 'management.queens.status.superseded'.tr();
      case QueenStatus.missing:
        return 'management.queens.status.missing'.tr();
      case QueenStatus.quarantined:
        return 'management.queens.status.quarantined'.tr();
      default:
        return queen.status.name;
    }
  }

  String _getSourceDisplay() {
    switch (queen.source) {
      case QueenSource.bought:
        return 'enums.QueenSource.bought'.tr();
      case QueenSource.bred:
        return 'enums.QueenSource.bred'.tr();
      case QueenSource.swarm:
        return 'enums.QueenSource.swarm'.tr();
      case QueenSource.supersedure:
        return 'enums.QueenSource.supersedure'.tr();
      case QueenSource.emergency:
        return 'enums.QueenSource.emergency'.tr();
      case QueenSource.split:
        return 'enums.QueenSource.split'.tr();
      case QueenSource.other:
        return 'enums.QueenSource.other'.tr();
      default:
        return queen.source.name;
    }
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

class _ColorRow extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorRow({required this.label, required this.color});

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
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getColorName(color),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getColorName(Color color) {
    if (color == Colors.red) return 'details.queen.red'.tr();
    if (color == Colors.blue) return 'details.queen.blue'.tr();
    if (color == Colors.green) return 'details.queen.green'.tr();
    if (color == Colors.yellow) return 'details.queen.yellow'.tr();
    if (color == Colors.white) return 'details.queen.white'.tr();
    if (color == Colors.orange) return 'details.queen.orange'.tr();
    if (color == Colors.purple) return 'details.queen.purple'.tr();
    if (color == Colors.pink) return 'details.queen.pink'.tr();
    return 'details.queen.custom_color'.tr();
  }
}

class _RatingRow extends StatelessWidget {
  final String label;
  final int rating;

  const _RatingRow({required this.label, required this.rating});

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
            child: Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  size: 16,
                  color: Colors.amber.shade700,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
