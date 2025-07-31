import 'package:apiarium/features/management/apiary_detail/cubit/apiary_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:go_router/go_router.dart';
import 'cubit/apiary_detail_cubit.dart';
import 'widgets/apiary_info_section.dart';
import 'widgets/hive_tile.dart';

class ApiaryDetailPage extends StatelessWidget {
  final String apiaryId;

  const ApiaryDetailPage({super.key, required this.apiaryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApiaryDetailCubit(
        apiaryService: getIt<ApiaryService>(),
        hiveService: getIt<HiveService>(),
        historyService: getIt<HistoryService>(),
      )..loadApiaryDetail(apiaryId),
      child: const _ApiaryDetailView(),
    );
  }
}

class _ApiaryDetailView extends StatelessWidget {
  const _ApiaryDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: BlocBuilder<ApiaryDetailCubit, ApiaryDetailState>(
          builder: (context, state) {
            return Text(
              state.apiary?.name ?? 'details.apiary.title'.tr(),
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
      body: BlocConsumer<ApiaryDetailCubit, ApiaryDetailState>(
        listener: (context, state) {
          if (state.status == ApiaryDetailStatus.error) {
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
            ApiaryDetailStatus.initial || ApiaryDetailStatus.loading => 
              const Center(child: CircularProgressIndicator(color: Colors.amber)),
            ApiaryDetailStatus.error => _ErrorView(
              message: state.errorMessage ?? 'common.error_occurred'.tr(),
              onRetry: () => context.read<ApiaryDetailCubit>().refresh(
                context.read<ApiaryDetailCubit>().state.apiary?.id ?? '',
              ),
            ),
            ApiaryDetailStatus.loaded => _LoadedView(
              apiary: state.apiary!,
              hives: state.hives,
              historyLogs: state.historyLogs,
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
  final Apiary apiary;
  final List<Hive> hives;
  final List<HistoryLog> historyLogs;

  const _LoadedView({
    required this.apiary,
    required this.hives,
    required this.historyLogs,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ApiaryDetailCubit>().refresh(apiary.id),
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
                  Tab(text: 'details.apiary.basicInfo'.tr()),
                  Tab(text: 'details.apiary.hives'.tr()),
                  Tab(text: 'details.apiary.history'.tr()),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ApiaryInfoSection(apiary: apiary),
                  _HivesSection(hives: hives),
                  _HistorySection(historyLogs: historyLogs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HivesSection extends StatelessWidget {
  final List<Hive> hives;

  const _HivesSection({required this.hives});

  @override
  Widget build(BuildContext context) {
    if (hives.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'details.apiary.no_hives'.tr(),
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
        itemCount: hives.length,
        itemBuilder: (context, index) {
          return HiveTile(
            hive: hives[index],
            onTap: () => _showHiveDetails(context, hives[index]),
          );
        },
      ),
    );
  }

  void _showHiveDetails(BuildContext context, Hive hive) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hive.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(hive.hiveType),
              const SizedBox(height: 8),
              Text(
                'Status: ${hive.status.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (hive.queenName != null) ...[
                const SizedBox(height: 8),
                Text('Queen: ${hive.queenName}'),
              ],
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM dd, yyyy').format(hive.createdAt),
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.close'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push(
                AppRouter.editHive,
                extra: {'hiveId': hive.id},
              );
            },
            child: Text('common.edit'.tr()),
          ),
        ],
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
                'details.apiary.no_history'.tr(),
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
              title: Text(
                '${'enums.history_action.${log.actionType.name}'.tr()} - ${log.entityName}',
              ),
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
      