import 'dart:ui';
import '../shared.dart';

class DashboardService {
  static const String _tag = 'DashboardService';
  
  final ApiaryRepository _apiaryRepository;
  final HiveRepository _hiveRepository;
  final QueenRepository _queenRepository;
  final InspectionRepository _inspectionRepository;
  final HistoryLogRepository _historyRepository;
  
  DashboardService({
    required ApiaryRepository apiaryRepository,
    required HiveRepository hiveRepository,
    required QueenRepository queenRepository,
    required InspectionRepository inspectionRepository,
    required HistoryLogRepository historyRepository,
  }) : _apiaryRepository = apiaryRepository,
       _hiveRepository = hiveRepository,
       _queenRepository = queenRepository,
       _inspectionRepository = inspectionRepository,
       _historyRepository = historyRepository;

  Future<DashboardStats> getDashboardStats() async {
    try {
      final apiaries = await _apiaryRepository.getAllApiaries();
      final hives = await _hiveRepository.getAllHives();
      final queens = await _queenRepository.getAllQueens();
      final inspections = await _inspectionRepository.getAllInspections();
      
      final activeApiaries = apiaries.where((a) => a.status == ApiaryStatus.active && !a.deleted).length;
      final activeHives = hives.where((h) => h.status == HiveStatus.active && !h.deleted).length;
      final totalHives = hives.where((h) => !h.deleted).length;
      final activeQueens = queens.where((q) => q.status == QueenStatus.active && !q.deleted).length;
      final unassignedQueens = queens.where((q) => q.hiveId == null && q.status == QueenStatus.active && !q.deleted).length;
      
      // Recent inspections (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentInspections = inspections.where((i) => i.createdAt.isAfter(thirtyDaysAgo) && !i.deleted).length;
      
      // Hives needing attention (no recent inspection)
      final hivesNeedingAttention = hives.where((h) {
        if (h.deleted || h.status != HiveStatus.active) return false;
        final hiveInspections = inspections.where((i) => i.hiveId == h.id && !i.deleted);
        if (hiveInspections.isEmpty) return true;
        final lastInspection = hiveInspections.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
        return lastInspection.createdAt.isBefore(DateTime.now().subtract(const Duration(days: 14)));
      }).length;
      
      return DashboardStats(
        totalApiaries: activeApiaries,
        totalHives: totalHives,
        activeHives: activeHives,
        totalQueens: activeQueens,
        unassignedQueens: unassignedQueens,
        recentInspections: recentInspections,
        hivesNeedingAttention: hivesNeedingAttention,
        seasonalAlert: '',
      );
    } catch (e) {
      Logger.e('Failed to get dashboard stats', tag: _tag, error: e);
      return DashboardStats.empty();
    }
  }

  Future<List<ApiaryMapData>> getApiaryMapData() async {
    try {
      final apiaries = await _apiaryRepository.getAllApiaries();
      final hives = await _hiveRepository.getAllHives();
      
      return apiaries
          .where((a) => !a.deleted && a.latitude != null && a.longitude != null)
          .map((apiary) {
        final apiaryHives = hives.where((h) => h.apiaryId == apiary.id && !h.deleted);
        final activeHives = apiaryHives.where((h) => h.status == HiveStatus.active);
        
        Color statusColor;
        switch (apiary.status) {
          case ApiaryStatus.active:
            statusColor = const Color(0xFF4CAF50); // Green
            break;
          case ApiaryStatus.inactive:
            statusColor = const Color(0xFF9E9E9E); // Grey
            break;
          case ApiaryStatus.archived:
            statusColor = const Color(0xFFF57C00); // Orange
            break;
          default:
            statusColor = const Color(0xFF9E9E9E);
        }
        
        return ApiaryMapData(
          id: apiary.id,
          name: apiary.name,
          latitude: apiary.latitude!,
          longitude: apiary.longitude!,
          hiveCount: apiaryHives.length,
          activeHiveCount: activeHives.length,
          color: statusColor,
          status: apiary.status,
        );
      }).toList();
    } catch (e) {
      Logger.e('Failed to get apiary map data', tag: _tag, error: e);
      return [];
    }
  }
}

class DashboardStats {
  final int totalApiaries;
  final int totalHives;
  final int activeHives;
  final int totalQueens;
  final int unassignedQueens;
  final int recentInspections;
  final int hivesNeedingAttention;
  final String seasonalAlert;

  const DashboardStats({
    required this.totalApiaries,
    required this.totalHives,
    required this.activeHives,
    required this.totalQueens,
    required this.unassignedQueens,
    required this.recentInspections,
    required this.hivesNeedingAttention,
    required this.seasonalAlert,
  });

  factory DashboardStats.empty() {
    return const DashboardStats(
      totalApiaries: 0,
      totalHives: 0,
      activeHives: 0,
      totalQueens: 0,
      unassignedQueens: 0,
      recentInspections: 0,
      hivesNeedingAttention: 0,
      seasonalAlert: '',
    );
  }
}

class ApiaryMapData {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int hiveCount;
  final int activeHiveCount;
  final Color? color;
  final ApiaryStatus status;

  const ApiaryMapData({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.hiveCount,
    required this.activeHiveCount,
    this.color,
    required this.status,
  });
}