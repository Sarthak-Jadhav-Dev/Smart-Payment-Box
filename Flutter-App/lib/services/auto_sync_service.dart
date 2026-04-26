import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import 'api_service.dart';
import 'local_storage_service.dart';

final autoSyncServiceProvider = Provider<AutoSyncService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final storageService = ref.read(localStorageProvider);
  return AutoSyncService(apiService, storageService);
});

class AutoSyncService {
  final ApiService _apiService;
  final LocalStorageService _storageService;
  Timer? _syncTimer;

  AutoSyncService(this._apiService, this._storageService);

  void startSyncTimer() {
    developer.log('AutoSyncService started');
    // Run sync every 5 minutes
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _syncTransactions();
    });
    
    // Also trigger an immediate sync
    _syncTransactions();
  }

  /// Public method to trigger a sync manually (e.g. from the UI)
  Future<void> manualSync() => _syncTransactions();

  void stopSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
    developer.log('AutoSyncService stopped');
  }

  Future<void> _syncTransactions() async {
    try {
      final offlinePayments = _storageService.getOfflinePayments();
      
      if (offlinePayments.isEmpty) {
        developer.log('No offline payments to sync.');
        return;
      }

      developer.log('Syncing ${offlinePayments.length} transactions to backend...');

      // Send to the new App-Backend
      final response = await _apiService.post('/sync', data: {
        'transactions': offlinePayments,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('Successfully synced transactions.');
        
        // Clear local offline payments as they are now synced
        await _storageService.clearOfflinePayments();
        
        // Optionally request a report after syncing
        await _requestReportGeneration();
      }
    } catch (e) {
      developer.log('Failed to sync transactions: $e');
    }
  }

  Future<void> _requestReportGeneration() async {
    try {
      // Assuming a generic email to send the report
      await _apiService.post('/reports/email', data: {
        'targetEmail': 'admin@example.com',
      });
      developer.log('Successfully requested report generation.');
    } catch (e) {
      developer.log('Failed to request report generation: $e');
    }
  }
}
