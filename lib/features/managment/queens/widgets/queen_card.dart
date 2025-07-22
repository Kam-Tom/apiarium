import 'package:flutter/material.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/features/managment/queen_detail/queen_detail_page.dart';
import 'package:apiarium/features/managment/queens/widgets/queen_status_badge.dart';
import 'package:easy_localization/easy_localization.dart';

class QueenCard extends StatelessWidget {
  final Queen queen;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const QueenCard({
    super.key,
    required this.queen,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                            queen.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                queen.breedName,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _getAgeText(),
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        QueenStatusBadge(status: queen.status),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _MarkedCircle(),
                            const SizedBox(width: 4),
                            Text(
                              "management.queens.marked".tr(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoItem(
                      label: 'management.queens.apiary'.tr(),
                      value: queen.apiaryName ?? 'management.queens.unassigned'.tr(),
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(width: 8),
                    _InfoItem(
                      label: 'management.queens.hive'.tr(),
                      value: queen.hiveName ?? 'management.queens.no_hive'.tr(),
                      icon: Icons.home_outlined,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text('common.edit'.tr()),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final confirmed = await _showDeleteConfirmation(context);
                        if (confirmed == true) {
                          onDelete?.call();
                        }
                      },
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
        ),
      ),
    );
  }

  String _getAgeText() {
    final currentYear = DateTime.now().year;
    final queenAge = currentYear - queen.birthDate.year;
    return '${queenAge}y';
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QueenDetailPage(queen: queen),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => DeleteConfirmationDialog(queenName: queen.name),
    );
  }
}

class _MarkedCircle extends StatelessWidget {
  const _MarkedCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final QueenCard? card = context.findAncestorWidgetOfExactType<QueenCard>();
    final queen = card?.queen;
    if (queen == null) return SizedBox.shrink();

    final bool isMarked = queen.marked == true;
    final Color? markColor = queen.markColor;
    final double size = 14;

    if (isMarked && markColor != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: markColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: const Center(
        child: Icon(Icons.help_outline, size: 10, color: Colors.black54),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isImportant = value == 'management.queens.no_hive'.tr() ||
        value == 'management.queens.unassigned'.tr() ||
        value == 'management.queens.unknown'.tr();

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isImportant ? FontWeight.bold : FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  icon,
                  size: 10,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final String queenName;

  const DeleteConfirmationDialog({required this.queenName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600, size: 28),
          const SizedBox(width: 8),
          Expanded(child: Text('management.queens.delete_title'.tr())),
        ],
      ),
      content: Text(
        'management.queens.delete_confirm'
            .tr(namedArgs: {'name': queenName}),
        style: const TextStyle(height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'common.cancel'.tr(),
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('common.delete'.tr()),
        ),
      ],
    );
  }
}