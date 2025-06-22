import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_model.dart';
import '../../services/database/postgresql_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين والصلاحيات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showUserForm(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
          ),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا يوجد مستخدمون لعرضهم.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: UIConstants.paddingMedium, vertical: UIConstants.paddingSmall),
                  child: ListTile(
                    title: Text(user.fullName),
                    subtitle: Text('${user.username} - ${user.role.toString().split('.').last}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showUserForm(user: user),
                        ),
                        IconButton(
                          icon: Icon(user.isActive ? Icons.toggle_on : Icons.toggle_off),
                          color: user.isActive ? AppTheme.success : AppTheme.error,
                          onPressed: () async {
                            // Deactivate/Activate user logic
                            final updatedUser = user.copyWith(isActive: !user.isActive);
                            await PostgreSQLService.instance.updateUser(updatedUser, 'admin-user-id'); // TODO: Replace with actual admin user ID
                            _refreshUsers();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            // Delete user logic
                            await PostgreSQLService.instance.deleteUser(user.id, 'admin-user-id'); // TODO: Replace with actual admin user ID
                            _refreshUsers();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
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

    return AlertDialog(
      title: Text(widget.user == null ? 'إضافة مستخدم جديد' : 'تعديل مستخدم'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الاسم الكامل';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'اسم المستخدم'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المستخدم';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty && widget.user == null) {
                    return 'الرجاء إدخال كلمة المرور';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'الدور'),
                items: allowedRoles.map((role) {
                  String roleName;
                  switch (role) {
                    case UserRole.manager:
                      roleName = 'مدير الإنتاج';
                      break;
                    case UserRole.accountant:
                      roleName = 'أمين المخزن';
                      break;
                    case UserRole.artisan:
                      roleName = 'حرفي';
                      break;
                    default:
                      roleName = role.toString().split('.').last; // Fallback
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
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveUser,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}


