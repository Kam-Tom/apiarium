import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:go_router/go_router.dart';

class HiveCard extends StatelessWidget {
  final Hive hive;

  const HiveCard({
    super.key,
    required this.hive,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkBackground = hive.color != null && hive.color!.computeLuminance() < 0.5;
    final textColor = isDarkBackground ? Colors.white : Colors.black;
    final moreSubtleTextColor = isDarkBackground ? Colors.white54 : Colors.black54;

    return InkWell(
      key: Key(hive.id),
      onTap: () {
        context.push(AppRouter.editHive, extra: {'hiveId': hive.id, 'hideLocation': true});
      },
      child: Container(
        decoration: BoxDecoration(
          color: hive.color ?? Colors.amber.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDarkBackground),
              _buildHiveInfo(textColor, moreSubtleTextColor),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Divider(
                  color: isDarkBackground ? Colors.white30 : Colors.black12,
                  height: 1,
                  thickness: 1,
                ),
              ),
              _buildQueenInfo(textColor, moreSubtleTextColor, isDarkBackground),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkBackground) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(
          Icons.hive,
          size: 16,
          color: isDarkBackground ? Colors.white : Colors.amber.shade800,
        ),
        InkWell(
          onTap: () {
            context.read<EditApiaryBloc>().add(EditApiaryRemoveHive(hive));
          },
          borderRadius: BorderRadius.circular(12),
          child: Icon(
            Icons.close_rounded,
            size: 14,
            color: isDarkBackground ? Colors.white70 : Colors.black45,
          ),
        ),
      ],
    );
  }

  Widget _buildHiveInfo(Color textColor, Color moreSubtleTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hive.name,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Text(
          hive.hiveType.name,
          style: TextStyle(
            fontSize: 10,
            color: moreSubtleTextColor,
            fontStyle: FontStyle.italic,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildQueenInfo(Color textColor, Color moreSubtleTextColor, bool isDarkBackground) {
    if (hive.queen == null) {
      return Row(
        children: [
          Icon(
            Icons.do_not_disturb,
            size: 12,
            color: moreSubtleTextColor,
          ),
          const SizedBox(width: 4),
          Text(
            'No Queen',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: moreSubtleTextColor,
            ),
          ),
        ],
      );
    }
    
    // For hives with queens
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hive.queen!.marked
                      ? hive.queen!.markColor ?? Colors.grey
                      : Colors.grey.withOpacity(0.4),
                  border: Border.all(
                    color: isDarkBackground ? Colors.white30 : Colors.black12,
                    width: 0.5,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  hive.queen!.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            hive.queen!.breed.name,
            style: TextStyle(
              fontSize: 10,
              color: moreSubtleTextColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
