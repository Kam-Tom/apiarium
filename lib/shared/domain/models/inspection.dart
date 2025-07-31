import 'package:apiarium/shared/domain/domain.dart';

class Inspection extends BaseModel {
  final String hiveId;
  final String? apiaryId;
  final String? groupId; 
  final String? apiaryName;
  final String hiveName;
  final String? queenId;
  final String? queenName;
  final Map<String, dynamic>? data;

  const Inspection({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.hiveId,
    required this.hiveName,
    this.apiaryId,
    this.groupId,
    this.apiaryName,
    this.queenId,
    this.queenName,
    this.data,
    super.syncStatus,
    super.lastSyncedAt,
    super.deleted,
    super.serverVersion,
  });

  factory Inspection.fromMap(Map<String, dynamic> data) {
    return Inspection(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.name == data['syncStatus'],
        orElse: () => SyncStatus.pending,
      ),
      lastSyncedAt: data['lastSyncedAt'] != null 
          ? DateTime.parse(data['lastSyncedAt']) 
          : null,
      deleted: data['deleted'] ?? false,
      serverVersion: data['serverVersion'] ?? 0,
      hiveId: data['hiveId'],
      hiveName: data['hiveName'],
      apiaryId: data['apiaryId'],
      groupId: data['groupId'],
      apiaryName: data['apiaryName'],
      queenId: data['queenId'],
      queenName: data['queenName'],
      data: data['data'] != null ? Map<String, dynamic>.from(data['data']) : null,
    );
  }

  Inspection copyWith({
    String Function()? hiveId,
    String? Function()? apiaryId,
    String? Function()? groupId,
    String? Function()? apiaryName,
    String Function()? hiveName,
    String? Function()? queenId,
    String? Function()? queenName,
    Map<String, dynamic>? Function()? data,
    SyncStatus Function()? syncStatus,
    DateTime? Function()? lastSyncedAt,
    DateTime Function()? updatedAt,
    bool Function()? deleted,
    int Function()? serverVersion,
  }) {
    return Inspection(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt != null ? updatedAt() : DateTime.now(),
      syncStatus: syncStatus != null ? syncStatus() : SyncStatus.pending,
      hiveId: hiveId != null ? hiveId() : this.hiveId,
      apiaryId: apiaryId != null ? apiaryId() : this.apiaryId,
      groupId: groupId != null ? groupId() : this.groupId,
      apiaryName: apiaryName != null ? apiaryName() : this.apiaryName,
      hiveName: hiveName != null ? hiveName() : this.hiveName,
      queenId: queenId != null ? queenId() : this.queenId,
      queenName: queenName != null ? queenName() : this.queenName,
      data: data != null ? data() : this.data,
      lastSyncedAt: lastSyncedAt != null ? lastSyncedAt() : this.lastSyncedAt,
      deleted: deleted != null ? deleted() : this.deleted,
      serverVersion: serverVersion != null ? serverVersion() : this.serverVersion,
    );
  }

  @override
  List<Object?> get props => [
    ...baseSyncProps,
    hiveId,
    apiaryId,
    groupId,
    apiaryName,
    hiveName,
    queenId,
    queenName,
    data,
  ];

  Map<String, dynamic> toJson() => {
    ...baseSyncFields,
    'hiveId': hiveId,
    'apiaryId': apiaryId,
    'groupId': groupId,
    'apiaryName': apiaryName,
    'hiveName': hiveName,
    'queenId': queenId,
    'queenName': queenName,
    'data': data,
  };
}
