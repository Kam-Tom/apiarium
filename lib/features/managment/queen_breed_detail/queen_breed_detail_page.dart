import 'package:flutter/material.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';

class QueenBreedDetailPage extends StatelessWidget {
  final QueenBreed breed;
  
  const QueenBreedDetailPage({
    super.key,
    required this.breed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(breed.name),
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
                '/edit-queen-breed',
                arguments: breed.id,
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
              _buildHeaderCard(context),
              const SizedBox(height: 16),
              _buildBasicInfoCard(context),
              const SizedBox(height: 16),
              _buildRatingsCard(context),
              const SizedBox(height: 16),
              if (breed.characteristics != null && breed.characteristics!.isNotEmpty)
                _buildCharacteristicsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildHeaderImage(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        breed.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (breed.scientificName != null && breed.scientificName!.isNotEmpty)
                        Text(
                          breed.scientificName!,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (breed.isStarred)
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade700,
                              size: 20,
                            ),
                          if (breed.isLocal)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'edit_queen_breed.local'.tr(),
                                style: TextStyle(
                                  color: Colors.green.shade800,
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

  Widget _buildHeaderImage() {
    return FutureBuilder<String?>(
      future: breed.getLocalImagePath(),
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
          child: imagePath != null && File(imagePath).existsSync()
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

  Widget _buildBasicInfoCard(BuildContext context) {
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
                  'edit_queen_breed.basic_information'.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (breed.origin != null && breed.origin!.isNotEmpty) 
              _buildInfoRow('edit_queen_breed.origin'.tr(), breed.origin!),
            if (breed.country != null && breed.country!.isNotEmpty) 
              _buildInfoRow('edit_queen_breed.country'.tr(), breed.country!),
            if (breed.scientificName != null && breed.scientificName!.isNotEmpty)
              _buildInfoRow('edit_queen_breed.scientific_name'.tr(), breed.scientificName!),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsCard(BuildContext context) {
    final hasRatings = breed.temperamentRating != null ||
                      breed.honeyProductionRating != null ||
                      breed.winterHardinessRating != null ||
                      breed.diseaseResistanceRating != null ||
                      breed.popularityRating != null;

    if (!hasRatings) return const SizedBox.shrink();

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
            if (breed.temperamentRating != null)
              _buildRatingRow(
                'edit_queen_breed.temperament'.tr(),
                breed.temperamentRating!,
                _getTemperamentLabel(breed.temperamentRating!),
              ),
            if (breed.honeyProductionRating != null)
              _buildRatingRow(
                'edit_queen_breed.honey_production'.tr(),
                breed.honeyProductionRating!,
                _getHoneyProductionLabel(breed.honeyProductionRating!),
              ),
            if (breed.winterHardinessRating != null)
              _buildRatingRow(
                'edit_queen_breed.winter_hardiness'.tr(),
                breed.winterHardinessRating!,
                _getWinterHardinessLabel(breed.winterHardinessRating!),
              ),
            if (breed.diseaseResistanceRating != null)
              _buildRatingRow(
                'edit_queen_breed.disease_resistance'.tr(),
                breed.diseaseResistanceRating!,
                _getDiseaseResistanceLabel(breed.diseaseResistanceRating!),
              ),
            if (breed.popularityRating != null)
              _buildRatingRow(
                'edit_queen_breed.popularity'.tr(),
                breed.popularityRating!,
                _getPopularityLabel(breed.popularityRating!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacteristicsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                Text(
                  'edit_queen_breed.characteristics'.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              breed.characteristics!,
              style: const TextStyle(fontSize: 16, height: 1.5),
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

  Widget _buildRatingRow(String title, int rating, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  final starRating = index + 1;
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.star_rounded,
                      color: starRating <= rating ? Colors.amber : Colors.grey.shade300,
                      size: 20,
                    ),
                  );
                }),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTemperamentLabel(int rating) {
    switch (rating) {
      case 1: return 'edit_queen_breed.very_aggressive'.tr();
      case 2: return 'edit_queen_breed.aggressive'.tr();
      case 3: return 'edit_queen_breed.moderate'.tr();
      case 4: return 'edit_queen_breed.gentle'.tr();
      case 5: return 'edit_queen_breed.very_gentle'.tr();
      default: return 'edit_queen_breed.moderate'.tr();
    }
  }

  String _getHoneyProductionLabel(int rating) {
    switch (rating) {
      case 1: return 'edit_queen_breed.very_low'.tr();
      case 2: return 'edit_queen_breed.low'.tr();
      case 3: return 'edit_queen_breed.medium'.tr();
      case 4: return 'edit_queen_breed.high'.tr();
      case 5: return 'edit_queen_breed.very_high'.tr();
      default: return 'edit_queen_breed.medium'.tr();
    }
  }

  String _getWinterHardinessLabel(int rating) {
    switch (rating) {
      case 1: return 'edit_queen_breed.very_poor'.tr();
      case 2: return 'edit_queen_breed.poor'.tr();
      case 3: return 'edit_queen_breed.average'.tr();
      case 4: return 'edit_queen_breed.good'.tr();
      case 5: return 'edit_queen_breed.excellent'.tr();
      default: return 'edit_queen_breed.average'.tr();
    }
  }

  String _getDiseaseResistanceLabel(int rating) {
    switch (rating) {
      case 1: return 'edit_queen_breed.very_poor'.tr();
      case 2: return 'edit_queen_breed.poor'.tr();
      case 3: return 'edit_queen_breed.average'.tr();
      case 4: return 'edit_queen_breed.good'.tr();
      case 5: return 'edit_queen_breed.excellent'.tr();
      default: return 'edit_queen_breed.average'.tr();
    }
  }

  String _getPopularityLabel(int rating) {
    switch (rating) {
      case 1: return 'edit_queen_breed.very_rare'.tr();
      case 2: return 'edit_queen_breed.rare'.tr();
      case 3: return 'edit_queen_breed.common'.tr();
      case 4: return 'edit_queen_breed.popular'.tr();
      case 5: return 'edit_queen_breed.very_popular'.tr();
      default: return 'edit_queen_breed.common'.tr();
    }
  }
}