import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../models/activity_log.dart';
import '../utils/app_theme.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  String _actionFilter = 'all';
  String _entityFilter = 'all';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    if (authProvider.token != null) {
      adminProvider.loadLogs(
        authProvider.token!,
        page: _currentPage,
        action: _actionFilter == 'all' ? null : _actionFilter,
        entityType: _entityFilter == 'all' ? null : _entityFilter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _actionFilter,
                  dropdownColor: AppTheme.cardColor,
                  style: AppTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'نوع الإجراء',
                    labelStyle: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('الكل', style: AppTheme.bodyMedium),
                    ),
                    DropdownMenuItem(
                      value: 'create',
                      child: Text('إضافة', style: AppTheme.bodyMedium),
                    ),
                    DropdownMenuItem(
                      value: 'update',
                      child: Text('تعديل', style: AppTheme.bodyMedium),
                    ),
                    DropdownMenuItem(
                      value: 'delete',
                      child: Text('حذف', style: AppTheme.bodyMedium),
                    ),
                    DropdownMenuItem(
                      value: 'login',
                      child: Text('تسجيل دخول', style: AppTheme.bodyMedium),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _actionFilter = value;
                        _loadLogs();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _entityFilter,
                  dropdownColor: AppTheme.cardColor,
                  style: AppTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'نوع الكيان',
                    labelStyle: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('الكل', style: AppTheme.bodyMedium),
                    ),
                    DropdownMenuItem(
                      value: 'medicine',
                      child: Text('دواء', style: AppTheme.bodyMedium),
                    ),
                    DropdownMenuItem(
                      value: 'user',
                      child: Text('مستخدم', style: AppTheme.bodyMedium),
                    ),
                    DropdownMenuItem(
                      value: 'reminder',
                      child: Text('تذكير', style: AppTheme.bodyMedium),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _entityFilter = value;
                        _loadLogs();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: adminProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : adminProvider.logs.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد سجلات',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => _loadLogs(),
                      child: ListView.builder(
                        itemCount: adminProvider.logs.length,
                        itemBuilder: (context, index) {
                          final log = adminProvider.logs[index];
                          return _buildLogCard(log);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildLogCard(ActivityLog log) {
    IconData icon;
    Color color;

    switch (log.action) {
      case 'create':
        icon = Icons.add_circle;
        color = AppTheme.successColor;
        break;
      case 'update':
        icon = Icons.edit;
        color = AppTheme.secondaryColor;
        break;
      case 'delete':
        icon = Icons.delete;
        color = AppTheme.errorColor;
        break;
      case 'login':
        icon = Icons.login;
        color = AppTheme.warningColor;
        break;
      default:
        icon = Icons.info;
        color = AppTheme.textTertiaryColor;
    }

    return Card(
      color: AppTheme.cardColor,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        title: Row(
          children: [
            Text(
              _getActionText(log.action),
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariantColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getEntityText(log.entityType),
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (log.userName != null)
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      log.userName!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              if (log.details != null && log.details!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariantColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.textTertiaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    log.details!.toString().replaceAll('{', '').replaceAll('}', ''),
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppTheme.textTertiaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt),
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textTertiaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        isThreeLine: false,
      ),
    );
  }

  String _getActionText(String action) {
    switch (action) {
      case 'create':
        return 'إضافة';
      case 'update':
        return 'تعديل';
      case 'delete':
        return 'حذف';
      case 'login':
        return 'تسجيل دخول';
      default:
        return action;
    }
  }

  String _getEntityText(String entityType) {
    switch (entityType) {
      case 'medicine':
        return 'دواء';
      case 'user':
        return 'مستخدم';
      case 'reminder':
        return 'تذكير';
      default:
        return entityType;
    }
  }
}

