import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../shared/widgets/modals/history_log/history_log_modal.dart';
import '../models/activity_item.dart';
import '../bloc/dashboard_bloc.dart';

class RecentActivitySection extends StatefulWidget {
  final List<ActivityItem> activities;
  final bool isLoadingMore;

  const RecentActivitySection({
    super.key,
    required this.activities,
    required this.isLoadingMore,
  });

  @override
  State<RecentActivitySection> createState() => _RecentActivitySectionState();
}

class _RecentActivitySectionState extends State<RecentActivitySection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      context.read<DashboardBloc>().add(LoadMoreActivity());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'recent_activity.title'.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.activities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'recent_activity.empty'.tr(),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: widget.activities.length + (widget.isLoadingMore ? 1 : 0),
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    if (index >= widget.activities.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.amber,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    
                    final activity = widget.activities[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: activity.color.withValues(alpha: 0.1),
                        radius: 18,
                        child: Icon(
                          activity.icon,
                          color: activity.color,
                          size: 16,
                        ),
                      ),
                      title: Text(
                        activity.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        activity.subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Text(
                        DateFormat('MMM dd, HH:mm').format(activity.timestamp),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                      onTap: () => _showActivityDetails(context, activity),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showActivityDetails(BuildContext context, ActivityItem activity) {
    // If the activity has a historyLog, show the HistoryLogModal
    if (activity.historyLog != null) {
      HistoryLogModal.show(context, activity.historyLog!);
      return;
    }
    // Otherwise, fallback to the default dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(activity.icon, color: activity.color),
            const SizedBox(width: 8),
            Expanded(child: Text(activity.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('recent_activity.timestamp'.tr()),
              Text(
                DateFormat('MMM dd, yyyy HH:mm').format(activity.timestamp),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('recent_activity.details'.tr()),
              Text(activity.subtitle),
              if (activity.details.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('recent_activity.additional_info'.tr()),
                ...activity.details.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text('${entry.key}: ${entry.value}'),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('recent_activity.close'.tr()),
          ),
        ],
      ),
    );
  }
}
