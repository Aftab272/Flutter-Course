import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../services/supabase_service.dart';
import '../services/database_service.dart';
import '../services/offline_queue_service.dart';
import '../services/google_drive_service.dart';
export '../core/theme/theme_provider.dart';

final supabaseServiceProvider = Provider((ref) => SupabaseService.instance);
final databaseServiceProvider = Provider((ref) => DatabaseService());
final offlineQueueServiceProvider = Provider((ref) {
  final service = OfflineQueueService();
  final db = ref.watch(databaseServiceProvider);
  service.initAutoSync(db);
  ref.onDispose(() => service.dispose());
  return service;
});
final googleDriveServiceProvider = Provider((ref) => GoogleDriveService());

// Auth State Notifier
class AuthUserNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() => null;
  void setUser(UserProfile? user) => state = user;
}

final authUserProvider = NotifierProvider<AuthUserNotifier, UserProfile?>(AuthUserNotifier.new);

// Offline Queue Count Provider
final offlineQueueCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(offlineQueueServiceProvider);
  return await service.getQueueCount();
});
