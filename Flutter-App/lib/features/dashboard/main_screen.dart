import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'reports_screen.dart';
import '../transactions/transactions_screen.dart';
import '../../services/notification_access_service.dart';
import '../../services/auto_sync_service.dart';
import '../../core/theme/app_theme.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _isSyncing = false;
  int _currentIndex = 0;
  final screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    AnalyticsScreen(),
    ReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    // Start the auto-sync timer
    Future.microtask(() {
      ref.read(autoSyncServiceProvider).startSyncTimer();
    });
  }

  @override
  void dispose() {
    // Stop the auto-sync timer when the main screen is disposed
    ref.read(autoSyncServiceProvider).stopSyncTimer();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }

    // Check notification listener service
    final isEnabled = await NotificationAccessService.isNotificationEnabled();
    if (!isEnabled && mounted) {
      _showNotificationAccessDialog();
    }
  }

  void _showNotificationAccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enable Notification Access'),
        content: const Text(
          'This app needs access to notifications to detect UPI payments.\n\n'
          'Please enable "smart_merchant_assistant" or "UPI Payment" in the next screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              NotificationAccessService.openNotificationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Transactions';
      case 2:
        return 'Analytics';
      case 3:
        return 'Reports';
      default:
        return 'Smart Merchant';
    }
  }

  Future<void> _manualSync() async {
    setState(() => _isSyncing = true);
    try {
      await ref.read(autoSyncServiceProvider).manualSync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sync complete!'),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sync Now',
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accentGreen,
                    ),
                  )
                : const Icon(Icons.sync_rounded),
            onPressed: _isSyncing ? null : _manualSync,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (v) => setState(() => _currentIndex = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.summarize_outlined),
            selectedIcon: Icon(Icons.summarize),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
