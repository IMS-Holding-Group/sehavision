import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tts_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/health_ai_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(AppLocalizations.of(context).appearance),
          _buildAppearanceSettings(context),

          _buildSectionHeader(AppLocalizations.of(context).accessibility),
          _buildAccessibilitySettings(context),

          _buildSectionHeader(AppLocalizations.of(context).account),
          _buildAccountSettings(context),

          _buildSectionHeader(AppLocalizations.of(context).about),
          _buildAboutSettings(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: AppTheme.heading3.copyWith(color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildAppearanceSettings(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    // final localizations = AppLocalizations.of(context)!;

    return GradientCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          // زر تغيير اللغة
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.language_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
            title: const Text('اللغة'),
            subtitle: Text(
              languageProvider.isArabic
                ? 'العربية'
                : 'English'
            ),
            trailing: Switch(
              value: !languageProvider.isArabic,
              onChanged: (value) {
                languageProvider.toggleLanguage();
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.palette_rounded,
                color: AppTheme.primaryColor,
              ),
            ),
            title: Text(AppLocalizations.of(context).darkMode),
            subtitle: Text(AppLocalizations.of(context).alwaysEnabled),
            trailing: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySettings(BuildContext context) {
    final ttsProvider = Provider.of<TTSProvider>(context);

    return GradientCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(AppLocalizations.of(context).textToSpeech),
            subtitle: Text(AppLocalizations.of(context).enableVoiceAnnouncements),
            value: ttsProvider.isEnabled,
            onChanged: (value) {
              ttsProvider.setEnabled(value);
            },
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                color: AppTheme.accentColor,
              ),
            ),
          ),
          if (ttsProvider.isEnabled) ...[
            const Divider(),
            ListTile(
              title: Text(AppLocalizations.of(context).speechRate),
              subtitle: Slider(
                value: ttsProvider.rate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                onChanged: (value) {
                  ttsProvider.setRate(value);
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(AppLocalizations.of(context).voicePitch),
              subtitle: Slider(
                value: ttsProvider.pitch,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                onChanged: (value) {
                  ttsProvider.setPitch(value);
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(AppLocalizations.of(context).volumeLevel),
              subtitle: Slider(
                value: ttsProvider.volume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (value) {
                  ttsProvider.setVolume(value);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return GradientCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          if (authProvider.isAuthenticated) ...[
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppTheme.secondaryColor,
                ),
              ),
              title: Text(AppLocalizations.of(context).profile),
              subtitle: Text(authProvider.user?.name ?? AppLocalizations.of(context).user),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                _showProfileDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: AppTheme.warningColor,
                ),
              ),
              title: Text(AppLocalizations.of(context).changePassword),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.errorColor,
                ),
              ),
              title: Text(AppLocalizations.of(context).logout),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ] else ...[
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.login_rounded,
                  color: AppTheme.primaryColor,
                ),
              ),
              title: const Text('تسجيل الدخول'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
    return GradientCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_rounded,
                color: AppTheme.infoColor,
              ),
            ),
            title: Text(AppLocalizations.of(context).appVersion),
            subtitle: const Text('1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.help_rounded,
                color: AppTheme.accentColor,
              ),
            ),
            title: Text(AppLocalizations.of(context).supportAndHelp),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              _showHelpDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.privacy_tip_rounded,
                color: AppTheme.successColor,
              ),
            ),
            title: Text(AppLocalizations.of(context).privacyPolicy),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              _showPrivacyDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.description_rounded,
                color: AppTheme.warningColor,
              ),
            ),
            title: Text(AppLocalizations.of(context).termsOfService),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              _showTermsDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final nameController = TextEditingController(
      text: authProvider.user?.name ?? '',
    );
    final phoneController = TextEditingController(
      text: authProvider.user?.phone ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(AppLocalizations.of(context).editProfile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: AppTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              style: AppTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'الهاتف',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
            onPressed: () async {
              final success = await authProvider.updateProfile(
                nameController.text.trim(),
                phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
              );

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث الملف الشخصي بنجاح'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: Text(
              'حفظ',
              style: AppTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(AppLocalizations.of(context).changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: AppTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: AppTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: AppTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمات المرور غير متطابقة'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }

              final success = await authProvider.changePassword(
                currentPasswordController.text,
                newPasswordController.text,
              );

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تغيير كلمة المرور بنجاح'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: Text(
              'تغيير',
              style: AppTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(AppLocalizations.of(context).logout),
        content: Text(AppLocalizations.of(context).logoutConfirm),
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
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              authProvider.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(
              'تسجيل الخروج',
              style: AppTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(AppLocalizations.of(context).supportAndHelp),
        content: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(context).helpAndSupportContent,
            style: AppTheme.bodyMedium,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).close,
              style: AppTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(AppLocalizations.of(context).privacyPolicy),
        content: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(context).privacyPolicyContent,
            style: AppTheme.bodyMedium,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).close,
              style: AppTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(AppLocalizations.of(context).termsOfService),
        content: SingleChildScrollView(
          child: Text(
            AppLocalizations.of(context).termsOfServiceContent,
            style: AppTheme.bodyMedium,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).close,
              style: AppTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}
