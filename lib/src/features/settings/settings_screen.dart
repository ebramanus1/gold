import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/language_provider.dart' as lang;
import '../../core/providers/theme_provider.dart' as theme;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(lang.languageProvider);
    final currentTheme = ref.watch(theme.themeProvider);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(localizations.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(UIConstants.paddingXXLarge),
            children: [
              _buildSectionCard(
                context,
                title: localizations.translate('general_settings') ?? 'الإعدادات العامة',
                icon: Icons.settings,
                children: [
                  _buildSettingRow(
                    context,
                    icon: Icons.language,
                    title: localizations.language,
                    subtitle: currentLocale.languageCode == 'ar' ? localizations.arabic : localizations.english,
                    trailing: DropdownButton<Locale>(
                      value: currentLocale,
                      borderRadius: BorderRadius.circular(16),
                      items: const [
                        DropdownMenuItem(
                          value: Locale('ar'),
                          child: Text('العربية'),
                        ),
                        DropdownMenuItem(
                          value: Locale('en'),
                          child: Text('English'),
                        ),
                      ],
                      onChanged: (Locale? newLocale) {
                        if (newLocale != null) {
                          ref.read(lang.languageProvider.notifier).changeLanguage(newLocale);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                newLocale.languageCode == 'ar'
                                    ? 'تم تغيير اللغة إلى العربية'
                                    : 'Language changed to English',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const Divider(height: 32),
                  _buildSettingRow(
                    context,
                    icon: Icons.palette,
                    title: localizations.theme,
                    subtitle: _getThemeText(currentTheme, localizations),
                    trailing: DropdownButton<ThemeMode>(
                      value: currentTheme,
                      borderRadius: BorderRadius.circular(16),
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.light_mode, size: 20),
                              const SizedBox(width: 8),
                              Text(localizations.lightTheme),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.dark_mode, size: 20),
                              const SizedBox(width: 8),
                              Text(localizations.darkTheme),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.settings_system_daydream, size: 20),
                              const SizedBox(width: 8),
                              Text(localizations.systemTheme),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (ThemeMode? newTheme) {
                        if (newTheme != null) {
                          ref.read(theme.themeProvider.notifier).changeTheme(newTheme);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                localizations.translate('theme_changed') ??
                                    (currentLocale.languageCode == 'ar'
                                        ? 'تم تغيير المظهر'
                                        : 'Theme changed'),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.paddingLarge),
              _buildSectionCard(
                context,
                title: localizations.translate('backup_settings') ?? 'إعدادات النسخ الاحتياطي',
                icon: Icons.backup,
                children: [
                  SwitchListTile(
                    value: true,
                    onChanged: (value) {},
                    title: Text(localizations.translate('auto_backup') ?? 'النسخ الاحتياطي التلقائي'),
                    subtitle: Text(localizations.translate('backup_description') ?? 'نسخ احتياطي يومي للبيانات'),
                    secondary: const Icon(Icons.backup, color: AppTheme.primaryGold),
                  ),
                  SwitchListTile(
                    value: false,
                    onChanged: (value) {},
                    title: Text(localizations.translate('cloud_backup') ?? 'النسخ الاحتياطي السحابي'),
                    subtitle: Text(localizations.translate('cloud_backup_description') ?? 'رفع النسخ الاحتياطية للسحابة'),
                    secondary: const Icon(Icons.cloud_upload, color: AppTheme.primaryGold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _createBackup,
                          icon: const Icon(Icons.save),
                          label: Text(localizations.translate('create_backup') ?? 'إنشاء نسخة احتياطية'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: UIConstants.paddingMedium),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _restoreBackup,
                          icon: const Icon(Icons.restore),
                          label: Text(localizations.translate('restore_backup') ?? 'استعادة نسخة احتياطية'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.paddingLarge),
              _buildSectionCard(
                context,
                title: localizations.translate('notification_settings') ?? 'إعدادات الإشعارات',
                icon: Icons.notifications,
                children: [
                  SwitchListTile(
                    value: true,
                    onChanged: (value) {},
                    title: Text(localizations.translate('work_order_notifications') ?? 'إشعارات أوامر العمل'),
                    subtitle: Text(localizations.translate('work_order_notifications_desc') ?? 'إشعارات عند تحديث حالة أوامر العمل'),
                    secondary: const Icon(Icons.notifications, color: AppTheme.primaryGold),
                  ),
                  SwitchListTile(
                    value: true,
                    onChanged: (value) {},
                    title: Text(localizations.translate('stock_notifications') ?? 'إشعارات المخزون'),
                    subtitle: Text(localizations.translate('stock_notifications_desc') ?? 'إشعارات عند انخفاض مستوى المخزون'),
                    secondary: const Icon(Icons.inventory, color: AppTheme.primaryGold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryGold.withOpacity(0.1),
                  child: Icon(icon, color: AppTheme.primaryGold),
                ),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(BuildContext context, {required IconData icon, required String title, required String subtitle, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGold),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: AppTheme.grey600)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  String _getThemeText(ThemeMode themeMode, AppLocalizations localizations) {
    switch (themeMode) {
      case ThemeMode.light:
        return localizations.lightTheme;
      case ThemeMode.dark:
        return localizations.darkTheme;
      case ThemeMode.system:
        return localizations.systemTheme;
    }
  }

  void _createBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.translate('backup_created') ?? 'تم إنشاء نسخة احتياطية بنجاح',
        ),
      ),
    );
  }

  void _restoreBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.translate('backup_restored') ?? 'تم استعادة النسخة الاحتياطية بنجاح',
        ),
      ),
    );
  }
}
