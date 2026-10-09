class SyncLog {
  final String syncId;
  final String userId;
  final String lastSync;
  final String syncStatus; // Normal, Syncing, Success, Failed, Offline
  final String? errorMessage;

  SyncLog({
    required this.syncId,
    required this.userId,
    required this.lastSync,
    required this.syncStatus,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'sync_id': syncId,
      'user_id': userId,
      'last_sync': lastSync,
      'sync_status': syncStatus,
      'error_message': errorMessage,
    };
  }

  factory SyncLog.fromMap(Map<String, dynamic> map) {
    return SyncLog(
      syncId: map['sync_id'] ?? '',
      userId: map['user_id'] ?? '',
      lastSync: map['last_sync'] ?? '',
      syncStatus: map['sync_status'] ?? 'Normal',
      errorMessage: map['error_message'],
    );
  }
}
