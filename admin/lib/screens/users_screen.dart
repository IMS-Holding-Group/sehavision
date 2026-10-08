import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../models/user.dart';
import '../utils/app_theme.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    if (authProvider.token != null) {
      adminProvider.loadUsers(
        authProvider.token!,
        page: _currentPage,
        search: _searchController.text.isEmpty ? null : _searchController.text,
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
          child: TextField(
            controller: _searchController,
            style: AppTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'بحث عن مستخدم...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.textSecondaryColor),
                      onPressed: () {
                        _searchController.clear();
                        _loadUsers();
                      },
                    )
                  : null,
            ),
            onSubmitted: (_) => _loadUsers(),
          ),
        ),
        Expanded(
          child: adminProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : adminProvider.users.isEmpty
                  ? Center(
                      child: Text(
                        'لا يوجد مستخدمين',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => _loadUsers(),
                      child: ListView.builder(
                        itemCount: adminProvider.users.length,
                        itemBuilder: (context, index) {
                          final user = adminProvider.users[index];
                          return _buildUserCard(user);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildUserCard(User user) {
    final isAdmin = user.role == 'admin';
    return Card(
      color: AppTheme.cardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isAdmin 
                ? AppTheme.secondaryColor.withOpacity(0.2) 
                : AppTheme.textTertiaryColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              user.name[0].toUpperCase(),
              style: AppTheme.heading3.copyWith(
                color: isAdmin ? AppTheme.secondaryColor : AppTheme.textSecondaryColor,
              ),
            ),
          ),
        ),
        title: Text(
          user.name,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.email, size: 14, color: AppTheme.textSecondaryColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      user.email,
                      style: AppTheme.bodySmall,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              if (user.phone != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: AppTheme.textSecondaryColor),
                    const SizedBox(width: 4),
                    Text(
                      user.phone!,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? AppTheme.secondaryColor.withOpacity(0.2)
                      : AppTheme.surfaceVariantColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'الدور: ${isAdmin ? 'مدير' : 'مستخدم'}',
                  style: AppTheme.bodySmall.copyWith(
                    color: isAdmin ? AppTheme.secondaryColor : AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (user.createdAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'تاريخ التسجيل: ${DateFormat('yyyy-MM-dd').format(user.createdAt!)}',
                  style: AppTheme.caption,
                ),
              ],
            ],
          ),
        ),
        isThreeLine: false,
      ),
    );
  }
}

