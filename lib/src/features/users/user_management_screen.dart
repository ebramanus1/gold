import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_model.dart';
import '../../services/database/postgresql_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_localizations.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    return PostgreSQLService.instance.getAllUsers();
  }

  void _showUserForm({User? user}) {
    showDialog(
      context: context,
      builder: (context) => UserFormDialog(user: user, onSave: _refreshUsers),
    );
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('إدارة المستخدمين', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(UIConstants.paddingLarge),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'بحث عن مستخدم...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          // ...existing code for filtering...
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {/* إضافة مستخدم */},
                      icon: const Icon(Icons.person_add),
                      label: const Text('إضافة مستخدم'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.all(UIConstants.paddingLarge),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  child: FutureBuilder<List<User>>(
                    future: _usersFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final users = snapshot.data!;
                      return ListView.separated(
                        padding: const EdgeInsets.all(UIConstants.paddingLarge),
                        itemCount: users.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryGold.withOpacity(0.1),
                              child: const Icon(Icons.person, color: AppTheme.primaryGold),
                            ),
                            title: Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(user.role.toString()),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {/* تعديل */},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {/* حذف */},
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserFormDialog extends ConsumerStatefulWidget {
  final User? user;
  final VoidCallback onSave;

  const UserFormDialog({Key? key, this.user, required this.onSave}) : super(key: key);

  @override
  ConsumerState<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late UserRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user?.fullName ?? '');
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _passwordController = TextEditingController(text: widget.user?.passwordHash ?? ''); // In a real app, handle password securely
    _selectedRole = widget.user?.role ?? UserRole.manager; // Default role to manager
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      final String id = widget.user?.id ?? const Uuid().v4();
      final newUser = User(
        id: id,
        fullName: _fullNameController.text,
        username: _usernameController.text,
        email: '${_usernameController.text}@goldworkshop.com', // Placeholder email
        passwordHash: _passwordController.text, // Hash password in a real app
        role: _selectedRole,
        createdAt: widget.user?.createdAt ?? DateTime.now(),
        isActive: widget.user?.isActive ?? true,
      );

      try {
        if (widget.user == null) {
          await PostgreSQLService.instance.insertUser(newUser);
        } else {
          await PostgreSQLService.instance.updateUser(newUser, 'admin-user-id'); // TODO: Replace with actual admin user ID
        }
        widget.onSave();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل حفظ المستخدم: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter roles to only show Production Manager (manager), Inventory Clerk (accountant), Artisan
    final List<UserRole> allowedRoles = [
      UserRole.manager,
      UserRole.accountant,
      UserRole.artisan,
    ];

    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.user == null ? localizations.translate('add_user') ?? 'إضافة مستخدم جديد' : localizations.translate('edit_user') ?? 'تعديل مستخدم'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: localizations.translate('full_name') ?? 'الاسم الكامل'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.translate('enter_full_name') ?? 'الرجاء إدخال الاسم الكامل';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: localizations.translate('username') ?? 'اسم المستخدم'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations.translate('enter_username') ?? 'الرجاء إدخال اسم المستخدم';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: localizations.translate('password') ?? 'كلمة المرور'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty && widget.user == null) {
                    return localizations.translate('enter_password') ?? 'الرجاء إدخال كلمة المرور';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: InputDecoration(labelText: localizations.translate('role') ?? 'الدور'),
                items: allowedRoles.map((role) {
                  String roleName;
                  switch (role) {
                    case UserRole.manager:
                      roleName = localizations.translate('production_manager') ?? 'مدير الإنتاج';
                      break;
                    case UserRole.accountant:
                      roleName = localizations.translate('inventory_clerk') ?? 'أمين المخزن';
                      break;
                    case UserRole.artisan:
                      roleName = localizations.translate('artisan') ?? 'حرفي';
                      break;
                    default:
                      roleName = role.toString().split('.').last;
                  }
                  return DropdownMenuItem(
                    value: role,
                    child: Text(roleName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.translate('cancel') ?? 'إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveUser,
          child: Text(localizations.translate('save') ?? 'حفظ'),
        ),
      ],
    );
  }
}


