import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/health_ai_widgets.dart';
import '../scan/scan_screen.dart';
import '../reminders/reminders_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    const HomeTab(),
    const ScanScreen(),
    const RemindersScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final medicineProvider = Provider.of<MedicineProvider>(
      context,
      listen: false,
    );
    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );

    // Load medicines
    await medicineProvider.loadMedicines();

    // Load reminders if user is authenticated
    if (authProvider.token != null) {
      await reminderProvider.loadReminders(token: authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, AppLocalizations.of(context).home),
              _buildNavItem(1, Icons.camera_alt_rounded, AppLocalizations.of(context).scan),
              _buildNavItem(2, Icons.notifications_rounded, AppLocalizations.of(context).reminders),
              _buildNavItem(3, Icons.settings_rounded, AppLocalizations.of(context).settings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textTertiaryColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.caption.copyWith(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textTertiaryColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _cardsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOut),
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final medicineProvider = Provider.of<MedicineProvider>(context);
    final reminderProvider = Provider.of<ReminderProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          _buildModernAppBar(context, authProvider.user?.name ?? 'المستخدم'),

          // Main Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _cardsAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Quick Actions
                    _buildQuickActionsSection(context),

                    const SizedBox(height: 24),

                    // Health Stats
                    _buildHealthStatsSection(
                        context, medicineProvider, reminderProvider),

                    const SizedBox(height: 24),

                    // Recent Medicines
                    _buildRecentMedicinesSection(context, medicineProvider),

                    const SizedBox(height: 24),

                    // Upcoming Reminders
                    if (authProvider.isAuthenticated)
                      _buildUpcomingRemindersSection(context, reminderProvider),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, String userName) {
    final now = DateTime.now();
    final hour = now.hour;
    final localizations = AppLocalizations.of(context);
    String greeting;
    String greetingIcon;

    if (hour < 12) {
      greeting = localizations.goodMorning;
      greetingIcon = '🌅';
    } else if (hour < 17) {
      greeting = localizations.goodAfternoon;
      greetingIcon = '☀️';
    } else {
      greeting = localizations.goodEvening;
      greetingIcon = '🌙';
    }

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.surfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FadeTransition(
        opacity: _headerAnimation,
        child: FlexibleSpaceBar(
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        greetingIcon,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$greeting، $userName',
                              style: AppTheme.heading2.copyWith(
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context).welcomeToSehaVision,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showSearchDialog(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).quickActions,
          style: AppTheme.heading3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                AppLocalizations.of(context).scanMedicine,
                '📱',
                AppLocalizations.of(context).useCameraToRecognize,
                AppTheme.primaryColor,
                () => _switchToTab(1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                AppLocalizations.of(context).addReminder,
                '⏰',
                AppLocalizations.of(context).reminderForMedicines,
                AppTheme.accentColor,
                () => _switchToTab(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String emoji,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: PulseAnimation(
        child: GradientCard(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.heading3.copyWith(
                            color: color,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthStatsSection(
    BuildContext context,
    MedicineProvider medicineProvider,
    ReminderProvider reminderProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).healthStats,
          style: AppTheme.heading3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                AppLocalizations.of(context).registeredMedicines,
                '${medicineProvider.medicines.length}',
                Icons.medication_rounded,
                AppTheme.successColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                AppLocalizations.of(context).activeReminders,
                '${reminderProvider.reminders.length}',
                Icons.notifications_active_rounded,
                AppTheme.warningColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return GradientCard(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          AnimatedHealthIndicator(
            value: 0.8, // Placeholder value
            label: value,
            color: color,
            icon: icon,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTheme.caption.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMedicinesSection(
    BuildContext context,
    MedicineProvider medicineProvider,
  ) {
    final recentMedicines = medicineProvider.medicines.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).recentMedicines,
              style: AppTheme.heading3,
            ),
            if (medicineProvider.medicines.length > 3)
              TextButton(
                onPressed: () {
                  // Navigate to all medicines
                },
                child: Text(
                  AppLocalizations.of(context).viewAll,
                  style: AppTheme.labelLarge.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentMedicines.isEmpty)
          _buildEmptyState(
            AppLocalizations.of(context).noMedicinesRegistered,
            AppLocalizations.of(context).startScanningMedicine,
            Icons.medication_outlined,
          )
        else
          ...recentMedicines.map((medicine) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMedicineCard(context, medicine),
              )),
      ],
    );
  }

  Widget _buildMedicineCard(BuildContext context, medicine) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/medicine-detail',
          arguments: medicine,
        );
      },
      child: GradientCard(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.2),
                    AppTheme.primaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const HealthAIIcon(
                size: 24,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name ?? 'دواء غير معروف',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicine.brand ?? 'علامة تجارية غير معروفة',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textTertiaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingRemindersSection(
    BuildContext context,
    ReminderProvider reminderProvider,
  ) {
    final upcomingReminders = reminderProvider.reminders.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).upcomingReminders,
              style: AppTheme.heading3,
            ),
            if (reminderProvider.reminders.length > 2)
              TextButton(
                onPressed: () => _switchToTab(2),
                child: Text(
                  AppLocalizations.of(context).viewAll,
                  style: AppTheme.labelLarge.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (upcomingReminders.isEmpty)
          _buildEmptyState(
            AppLocalizations.of(context).noReminders,
            AppLocalizations.of(context).addNewReminder,
            Icons.notifications_outlined,
          )
        else
          ...upcomingReminders.map((reminder) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildReminderCard(context, reminder),
              )),
      ],
    );
  }

  Widget _buildReminderCard(BuildContext context, reminder) {
    return GradientCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      colors: [
        AppTheme.warningColor.withOpacity(0.1),
        AppTheme.warningColor.withOpacity(0.05),
      ],
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.warningColor.withOpacity(0.2),
                  AppTheme.warningColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppTheme.warningColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title ?? 'تذكير',
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reminder.description ?? 'لا يوجد وصف',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return GradientCard(
      padding: const EdgeInsets.all(32),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.textTertiaryColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textTertiaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _switchToTab(int index) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeState != null) {
      homeState.setState(() {
        homeState._currentIndex = index;
      });
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          AppLocalizations.of(context).searchMedicine,
          style: AppTheme.heading3,
        ),
        content: TextField(
          style: AppTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'اكتب اسم الدواء...',
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textTertiaryColor,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: AppTheme.labelLarge.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement search functionality
            },
            child: Text(
              'بحث',
              style: AppTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

