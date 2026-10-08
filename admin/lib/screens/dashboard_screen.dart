import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../utils/app_theme.dart';
import 'users_screen.dart';
import 'medicines_screen.dart';
import 'logs_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardHome(),
    const UsersScreen(),
    const MedicinesScreen(),
    const LogsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      if (authProvider.token != null) {
        adminProvider.loadDashboard(authProvider.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'المستخدمين',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'الأدوية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'السجلات',
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);

    return RefreshIndicator(
      onRefresh: () async {
        if (authProvider.token != null) {
          await adminProvider.loadDashboard(authProvider.token!);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'نظرة عامة',
                  style: AppTheme.heading2,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (adminProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (adminProvider.dashboardStats != null)
              _buildStats(adminProvider.dashboardStats!)
            else
              Center(
                child: Text(
                  'لا توجد بيانات',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(Map<String, dynamic> stats) {
    return Column(
      children: [
        _buildStatCard(
          'المستخدمين',
          stats['users']?['total_users']?.toString() ?? '0',
          Icons.people,
          AppTheme.secondaryColor,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'الأدوية',
          stats['medicines']?['total_medicines']?.toString() ?? '0',
          Icons.medication,
          AppTheme.primaryColor,
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'التذكيرات',
          stats['reminders']?['total_reminders']?.toString() ?? '0',
          Icons.notifications,
          AppTheme.warningColor,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: AppTheme.cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: AppTheme.heading2.copyWith(
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

