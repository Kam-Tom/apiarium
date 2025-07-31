import 'package:apiarium/features/management/hive_detail/cubit/hive_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/core/di/dependency_injection.dart';
import 'cubit/hive_detail_cubit.dart';
import 'widgets/hive_info_section.dart';

class HiveDetailPage extends StatelessWidget {
  final String hiveId;

  const HiveDetailPage({super.key, required this.hiveId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HiveDetailCubit(
        hiveService: getIt<HiveService>(),
        historyService: getIt<HistoryService>(),
        inspectionService: getIt<InspectionService>(),
      )..loadHiveDetail(hiveId),
      child: const _HiveDetailView(),
    );
  }
}

class _HiveDetailView extends StatelessWidget {
  const _HiveDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: BlocBuilder<HiveDetailCubit, HiveDetailState>(
          builder: (context, state) {
            return Text(
              state.hive?.name ?? 'details.hive.title'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
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
      body: BlocConsumer<HiveDetailCubit, HiveDetailState>(
        listener: (context, state) {
          if (state.status == HiveDetailStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'common.error_occurred'.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state.status) {
            HiveDetailStatus.initial || HiveDetailStatus.loading => 
              const Center(child: CircularProgressIndicator(color: Colors.amber)),
            HiveDetailStatus.error => _ErrorView(
              message: state.errorMessage ?? 'common.error_occurred'.tr(),
              onRetry: () => context.read<HiveDetailCubit>().refresh(
                (context.read<HiveDetailCubit>().state.hive?.id ?? ''),
              ),
            ),
            HiveDetailStatus.loaded => _LoadedView(
              hive: state.hive!,
              hiveType: state.hiveType,
              historyLogs: state.historyLogs,
              inspections: state.inspections,
            ),
          };
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  final Hive hive;
  final HiveType? hiveType;
  final List<HistoryLog> historyLogs;
  final List<Inspection> inspections;

  const _LoadedView({
    required this.hive,
    this.hiveType,
    required this.historyLogs,
    required this.inspections,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<HiveDetailCubit>().refresh(hive.id),
      color: Colors.amber,
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.amber.shade700,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.amber,
                tabs: [
                  Tab(text: 'details.hive.basicInfo'.tr()),
                  Tab(text: 'details.hive.history'.tr()),
                  Tab(text: 'details.hive.inspections'.tr()),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  HiveInfoSection(hive: hive, hiveType: hiveType),
                  _HistorySection(historyLogs: historyLogs),
                  _InspectionSection(inspections: inspections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  final List<HistoryLog> historyLogs;

  const _HistorySection({required this.historyLogs});

  @override
  Widget build(BuildContext context) {
    if (historyLogs.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'details.hive.no_history'.tr(),
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyLogs.length,
        itemBuilder: (context, index) {
          final log = historyLogs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.history, color: Colors.amber.shade700),
              title: Text('${'enums.history_action.${log.actionType.name}'.tr()} - ${log.entityName}',),
              subtitle: Text(
                DateFormat('MMM dd, yyyy HH:mm').format(log.timestamp),
              ),
              onTap: () => _showHistoryDetails(context, log),
            ),
          );
        },
      ),
    );
  }

  void _showHistoryDetails(BuildContext context, HistoryLog log) {
    HistoryLogModal.show(context, log);
  }
}

class _InspectionSection extends StatelessWidget {
  final List<Inspection> inspections;

  const _InspectionSection({required this.inspections});

  @override
  Widget build(BuildContext context) {
    if (inspections.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'details.hive.no_inspections'.tr(),
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: inspections.length,
        itemBuilder: (context, index) {
          final inspection = inspections[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.search, color: Colors.amber.shade700),
              title: Text(inspection.apiaryName ?? 'details.hive.unknown_apiary'.tr()),
              subtitle: Text(
                DateFormat('MMM dd, yyyy HH:mm').format(inspection.createdAt),
              ),
              onTap: () => _showInspectionDetails(context, inspection),
            ),
          );
        },
      )
    );
  }

  void _showInspectionDetails(BuildContext context, Inspection inspection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('details.hive.inspection_details'.tr()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(inspection.apiaryName ?? 'details.hive.unknown_apiary'.tr()),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM dd, yyyy HH:mm').format(inspection.createdAt),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (inspection.data != null && inspection.data!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('details.hive.inspection_data'.tr()),
                ...inspection.data!.entries.map((entry) => Padding(
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
            child: Text('common.close'.tr()),
          ),
        ],
      ),
    );
  }
}
