import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../models/medicine.dart';
import '../utils/app_theme.dart';

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  final _searchController = TextEditingController();
  String _filter = 'all';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  void _loadMedicines() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    if (authProvider.token != null) {
      adminProvider.loadMedicines(
        authProvider.token!,
        page: _currentPage,
        search: _searchController.text.isEmpty ? null : _searchController.text,
        filter: _filter == 'all' ? null : _filter,
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
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: AppTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'بحث عن دواء...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppTheme.textSecondaryColor),
                          onPressed: () {
                            _searchController.clear();
                            _loadMedicines();
                          },
                        )
                      : null,
                ),
                onSubmitted: (_) => _loadMedicines(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('الكل'),
                      selected: _filter == 'all',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _filter = 'all';
                            _loadMedicines();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('منتهية الصلاحية'),
                      selected: _filter == 'expired',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _filter = 'expired';
                            _loadMedicines();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('محذوفة'),
                      selected: _filter == 'deleted',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _filter = 'deleted';
                            _loadMedicines();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: adminProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : adminProvider.medicines.isEmpty
                  ? Center(
                      child: Text(
                        'لا يوجد أدوية',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => _loadMedicines(),
                      child: ListView.builder(
                        itemCount: adminProvider.medicines.length,
                        itemBuilder: (context, index) {
                          final medicine = adminProvider.medicines[index];
                          return _buildMedicineCard(medicine);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final isExpired = medicine.expiryDate != null &&
        medicine.expiryDate!.isBefore(DateTime.now());

    return Card(
      color: medicine.isDeleted ? AppTheme.surfaceVariantColor : AppTheme.cardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: medicine.isDeleted
              ? AppTheme.errorColor.withOpacity(0.5)
              : isExpired
                  ? AppTheme.warningColor.withOpacity(0.5)
                  : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: medicine.isDeleted
                ? Colors.grey.shade300
                : Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            medicine.isDeleted ? Icons.delete : Icons.medication,
            size: 28,
            color: medicine.isDeleted ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          medicine.name,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            decoration: medicine.isDeleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: medicine.isDeleted 
                ? AppTheme.textTertiaryColor 
                : AppTheme.textPrimaryColor,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (medicine.brand != null)
                Row(
                  children: [
                    const Icon(
                      Icons.branding_watermark,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'العلامة: ${medicine.brand}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              if (medicine.dosage != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.science,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'الجرعة: ${medicine.dosage}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              if (medicine.createdByName != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.secondaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_add,
                        size: 14,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'أضافه: ${medicine.createdByName}',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (medicine.isDeleted && medicine.deletedByName != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.errorColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.delete,
                        size: 14,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'حذفه: ${medicine.deletedByName}',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (medicine.expiryDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isExpired 
                          ? AppTheme.errorColor 
                          : AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'انتهاء: ${DateFormat('yyyy-MM-dd').format(medicine.expiryDate!)}',
                      style: AppTheme.caption.copyWith(
                        color: isExpired 
                            ? AppTheme.errorColor 
                            : AppTheme.textTertiaryColor,
                        fontWeight: isExpired 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        isThreeLine: false,
        trailing: medicine.isDeleted
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete, color: Colors.red, size: 20),
              )
            : IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red, size: 20),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: Text(
                        'تأكيد الحذف',
                        style: AppTheme.heading3,
                      ),
                      content: Text(
                        'هل أنت متأكد من حذف ${medicine.name}؟',
                        style: AppTheme.bodyMedium,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'إلغاء',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('حذف'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && authProvider.token != null) {
                    await adminProvider.deleteMedicine(
                      authProvider.token!,
                      medicine.id,
                    );
                    _loadMedicines();
                  }
                },
              ),
      ),
    );
  }
}

