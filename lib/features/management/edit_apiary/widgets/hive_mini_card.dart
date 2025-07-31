import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/management/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:go_router/go_router.dart';

class HiveMiniCard extends StatelessWidget {
  final Hive hive;

  const HiveMiniCard({
    super.key,
    required this.hive,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(AppRouter.editHive, extra: {'hiveId': hive.id, 'hideLocation': true});
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const SizedBox(height: 6), // Reduced spacing
              _buildHiveInfo(),
              const SizedBox(height: 6), // Reduced spacing
              Divider(
                color: Colors.grey.shade200,
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: 6), // Reduced spacing
              _buildQueenInfo(),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.drag_handle,
                    size: 14, // Smaller icon
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            hive.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        InkWell(
          onTap: () {
            context.read<EditApiaryBloc>().add(EditApiaryRemoveHive(hive));
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHiveInfo() {
    return Row(
      children: [
        Icon(
          Icons.hive, // Changed to hive icon
          size: 20,
          color: hive.color ?? Colors.amber.shade800,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hive.hiveType,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildQueenInfo() {
    if (hive.queenId == null) {
      return Row(
        children: [
          Icon(
            Icons.do_not_disturb_on_outlined,
            size: 14,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'edit_hive.no_queen'.tr(),
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hive.queenMarked == true
                    ? (hive.queenMarkColor ?? Colors.grey.shade400)
                    : Colors.grey.shade300,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                hive.queenName ?? 'edit_hive.no_queen'.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            hive.breed ?? 'edit_hive.queen_breed'.tr(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}