import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/features/management/queen_breeds/bloc/queen_breeds_bloc.dart';
import 'package:apiarium/features/management/queen_breeds/bloc/queen_breeds_event.dart';
import 'package:apiarium/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class ImprovedQueenBreedCard extends StatelessWidget {
  final QueenBreed breed;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const ImprovedQueenBreedCard({
    super.key,
    required this.breed,
    required this.onDelete,
    this.onTap,
    this.onEdit,
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
            AppRouter.queenBreedDetail,
            extra: breed.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Profile-style image
              _buildProfileImage(),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 8),
                    _buildDetailedInfo(),
                  ],
                ),
              ),
              // Actions
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FutureBuilder<String?>(
          future: breed.getLocalImagePath(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
              final file = File(snapshot.data!);
              return Image.file(
                file,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.pets,
                  size: 30,
                  color: Colors.amber.shade400,
                ),
              );
            }
            return Icon(
              Icons.pets,
              size: 30,
              color: Colors.amber.shade400,
            );
          },
        ),
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
                breed.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (breed.scientificName != null && breed.scientificName!.isNotEmpty)
                Text(
                  breed.scientificName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
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

  Widget _buildDetailedInfo() {
    final List<Widget> infoChips = [];
    
    // Origin and country info
    if (breed.origin != null && breed.origin!.isNotEmpty) {
      infoChips.add(_buildInfoChip(Icons.public, '${'queen_breed_detail.origin'.tr()}: ${breed.origin!}', Colors.green));
    } else if (breed.country != null && breed.country!.isNotEmpty) {
      infoChips.add(_buildInfoChip(Icons.flag, '${'queen_breed_detail.country'.tr()}: ${breed.country!}', Colors.blue));
    }
    
    // Local badge
    if (breed.isLocal) {
      infoChips.add(_buildInfoChip(Icons.home, 'queen_breed_detail.local'.tr(), Colors.orange));
    }
    
    // Cost
    if (breed.cost != null) {
      infoChips.add(_buildInfoChip(Icons.attach_money, '${'queen_breed_detail.cost'.tr()}: \$${breed.cost!.toStringAsFixed(0)}', Colors.purple));
    }

    // Best rating display (now using new fields)
    final ratings = [
      if (breed.honeyProductionRating != null && breed.honeyProductionRating! > 0)
        ('edit_queen_breed.honey_production'.tr(), breed.honeyProductionRating!, Colors.amber),
      if (breed.springDevelopmentRating != null && breed.springDevelopmentRating! > 0)
        ('edit_queen_breed.spring_development'.tr(), breed.springDevelopmentRating!, Colors.green),
      if (breed.gentlenessRating != null && breed.gentlenessRating! > 0)
        ('edit_queen_breed.gentleness'.tr(), breed.gentlenessRating!, Colors.blue),
      if (breed.swarmingTendencyRating != null && breed.swarmingTendencyRating! > 0)
        ('edit_queen_breed.swarming_tendency'.tr(), breed.swarmingTendencyRating!, Colors.deepOrange),
      if (breed.winterHardinessRating != null && breed.winterHardinessRating! > 0)
        ('edit_queen_breed.winter_hardiness'.tr(), breed.winterHardinessRating!, Colors.cyan),
      if (breed.diseaseResistanceRating != null && breed.diseaseResistanceRating! > 0)
        ('edit_queen_breed.disease_resistance'.tr(), breed.diseaseResistanceRating!, Colors.red),
      if (breed.heatToleranceRating != null && breed.heatToleranceRating! > 0)
        ('edit_queen_breed.heat_tolerance'.tr(), breed.heatToleranceRating!, Colors.deepPurple),
    ];
    
    // Show top 2 ratings if available
    if (ratings.isNotEmpty) {
      ratings.sort((a, b) => b.$2.compareTo(a.$2)); // Sort by rating descending
      final topRatings = ratings.take(2).toList();
      
      for (final rating in topRatings) {
        infoChips.add(_buildRatingChip(rating.$1, rating.$2, rating.$3));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (infoChips.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: infoChips,
          ),
        ],
        // Characteristics preview
        if (breed.characteristics != null && breed.characteristics!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            breed.characteristics!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
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

  Widget _buildRatingChip(String label, int rating, Color color) {
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
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 3),
          ...List.generate(rating, (index) => Icon(
            Icons.star,
            size: 8,
            color: color,
          )),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            context.read<QueenBreedsBloc>().add(ToggleBreedStar(breed.id));
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              breed.isStarred ? Icons.star : Icons.star_border,
              color: breed.isStarred ? Colors.amber : Colors.grey,
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
        title: Text('queen_breeds.delete_title'.tr()),
        content: Text('${'queen_breeds.delete_title'.tr()} ${breed.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('queen_breeds.delete_title'.tr()),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      onDelete();
    }
  }
}