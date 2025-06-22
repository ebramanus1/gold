import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/client_model.dart';
import '../../services/database/postgresql_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class ClientManagementScreen extends ConsumerStatefulWidget {
  const ClientManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends ConsumerState<ClientManagementScreen> {
  final _searchController = TextEditingController();
  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final clients = await PostgreSQLService.instance.getAllClients();
      setState(() {
        _clients = clients;
        _filteredClients = clients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('خطأ في تحميل بيانات العملاء: $e');
    }
  }

  void _filterClients(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredClients = _clients;
      } else {
        _filteredClients = _clients.where((client) {
          return client.name.toLowerCase().contains(query.toLowerCase()) ||
                 client.phone.contains(query) ||
                 (client.businessName?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  void _showAddClientDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditClientDialog(
        onSave: (client) async {
          try {
                await PostgreSQLService.instance.insertClient(client, 'current_user_id');
            _loadClients();
            _showSuccessSnackBar('تم إضافة العميل بنجاح');
          } catch (e) {
            _showErrorSnackBar('خطأ في إضافة العميل: $e');
          }
        },
      ),
    );
  }

  void _showEditClientDialog(Client client) {
    showDialog(
      context: context,
      builder: (context) => AddEditClientDialog(
        client: client,
        onSave: (updatedClient) async {
          try {
            // TODO: Implement update client method
            _loadClients();
            _showSuccessSnackBar('تم تحديث بيانات العميل بنجاح');
          } catch (e) {
            _showErrorSnackBar('خطأ في تحديث بيانات العميل: $e');
          }
        },
      ),
    );
  }

  void _showClientDetails(Client client) {
    showDialog(
      context: context,
      builder: (context) => ClientDetailsDialog(client: client),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // عنوان الصفحة والأزرار
          Container(
            padding: const EdgeInsets.all(UIConstants.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إدارة العملاء',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadClients,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة عميل'),
                      onPressed: _showAddClientDialog,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(UIConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'البحث عن عميل',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterClients,
            ),
          ),
          
          // إحصائيات سريعة
          _buildQuickStats(),
          
          // قائمة العملاء
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClients.isEmpty
                    ? _buildEmptyState()
                    : _buildClientsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalClients = _clients.length;
    final activeClients = _clients.where((c) => c.isActive).length;
    final totalBalance = _clients.fold<double>(0, (sum, client) => sum + client.totalBalance);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UIConstants.paddingMedium),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'إجمالي العملاء',
              value: totalClients.toString(),
              icon: Icons.people,
              color: AppTheme.primaryGold,
            ),
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Expanded(
            child: _buildStatCard(
              title: 'العملاء النشطون',
              value: activeClients.toString(),
              icon: Icons.person_add,
              color: AppTheme.success,
            ),
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Expanded(
            child: _buildStatCard(
              title: 'إجمالي الأرصدة',
              value: '${totalBalance.toStringAsFixed(1)} جرام',
              icon: Icons.account_balance,
              color: AppTheme.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingSmall),
        child: Column(
          children: [
            Icon(icon, color: color, size: UIConstants.iconSizeMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppTheme.grey400,
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          Text(
            _searchQuery.isEmpty ? 'لا توجد عملاء مسجلين' : 'لا توجد نتائج للبحث',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.grey600,
            ),
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: _showAddClientDialog,
              icon: const Icon(Icons.add),
              label: const Text('إضافة عميل جديد'),
            ),
        ],
      ),
    );
  }

  Widget _buildClientsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      itemCount: _filteredClients.length,
      itemBuilder: (context, index) {
        final client = _filteredClients[index];
        return _buildClientCard(client);
      },
    );
  }

  Widget _buildClientCard(Client client) {
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.paddingSmall),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: client.isActive ? AppTheme.primaryGold : AppTheme.grey400,
          child: Text(
            client.name.isNotEmpty ? client.name[0].toUpperCase() : '؟',
            style: const TextStyle(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الهاتف: ${client.phone}'),
            if (client.businessName != null)
              Text('النشاط التجاري: ${client.businessName}'),
            Text(
              'إجمالي الرصيد: ${client.totalBalance.toStringAsFixed(3)} جرام',
              style: TextStyle(
                color: client.totalBalance > 0 ? AppTheme.success : AppTheme.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!client.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'غير نشط',
                  style: TextStyle(
                    color: AppTheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _showClientDetails(client);
                    break;
                  case 'edit':
                    _showEditClientDialog(client);
                    break;
                  case 'transactions':
                    // TODO: Navigate to client transactions
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('عرض التفاصيل'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('تعديل'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'transactions',
                  child: ListTile(
                    leading: Icon(Icons.history),
                    title: Text('المعاملات'),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showClientDetails(client),
      ),
    );
  }
}

// حوار إضافة/تعديل العميل
class AddEditClientDialog extends StatefulWidget {
  final Client? client;
  final Function(Client) onSave;

  const AddEditClientDialog({
    Key? key,
    this.client,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddEditClientDialog> createState() => _AddEditClientDialogState();
}

class _AddEditClientDialogState extends State<AddEditClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _commercialRegistrationController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _notesController = TextEditingController();
  
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _populateFields(widget.client!);
    }
  }

  void _populateFields(Client client) {
    _nameController.text = client.name;
    _businessNameController.text = client.businessName ?? '';
    _phoneController.text = client.phone;
    _emailController.text = client.email ?? '';
    _addressController.text = client.address ?? '';
    _commercialRegistrationController.text = client.commercialRegistration ?? '';
    _taxNumberController.text = client.taxNumber ?? '';
    _contactPersonController.text = client.contactPerson ?? '';
    _creditLimitController.text = client.creditLimit.toString();
    _notesController.text = client.notes ?? '';
    _isActive = client.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _commercialRegistrationController.dispose();
    _taxNumberController.dispose();
    _contactPersonController.dispose();
    _creditLimitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveClient() {
    if (!_formKey.currentState!.validate()) return;

    final client = Client(
      id: widget.client?.id ?? 'client_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      businessName: _businessNameController.text.trim().isEmpty 
          ? null 
          : _businessNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty 
          ? null 
          : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty 
          ? null 
          : _addressController.text.trim(),
      commercialRegistration: _commercialRegistrationController.text.trim().isEmpty 
          ? null 
          : _commercialRegistrationController.text.trim(),
      taxNumber: _taxNumberController.text.trim().isEmpty 
          ? null 
          : _taxNumberController.text.trim(),
      contactPerson: _contactPersonController.text.trim().isEmpty 
          ? null 
          : _contactPersonController.text.trim(),
      creditLimit: double.tryParse(_creditLimitController.text) ?? 0.0,
      currentBalance24k: widget.client?.currentBalance24k ?? 0.0,
      currentBalance22k: widget.client?.currentBalance22k ?? 0.0,
      currentBalance21k: widget.client?.currentBalance21k ?? 0.0,
      currentBalance18k: widget.client?.currentBalance18k ?? 0.0,
      isActive: _isActive,
      createdAt: widget.client?.createdAt ?? DateTime.now(),
      lastTransactionAt: widget.client?.lastTransactionAt,
      notes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
    );

    widget.onSave(client);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.client == null ? 'إضافة عميل جديد' : 'تعديل بيانات العميل',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: UIConstants.paddingLarge),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // الاسم
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم العميل *',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم العميل';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // اسم النشاط التجاري
                      TextFormField(
                        controller: _businessNameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم النشاط التجاري',
                          prefixIcon: Icon(Icons.business),
                        ),
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // رقم الهاتف
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف *',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال رقم الهاتف';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // البريد الإلكتروني
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!value.contains('@')) {
                              return 'يرجى إدخال بريد إلكتروني صحيح';
                            }
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // العنوان
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'العنوان',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // السجل التجاري
                      TextFormField(
                        controller: _commercialRegistrationController,
                        decoration: const InputDecoration(
                          labelText: 'رقم السجل التجاري',
                          prefixIcon: Icon(Icons.assignment),
                        ),
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // الرقم الضريبي
                      TextFormField(
                        controller: _taxNumberController,
                        decoration: const InputDecoration(
                          labelText: 'الرقم الضريبي',
                          prefixIcon: Icon(Icons.receipt),
                        ),
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // الشخص المسؤول
                      TextFormField(
                        controller: _contactPersonController,
                        decoration: const InputDecoration(
                          labelText: 'الشخص المسؤول',
                          prefixIcon: Icon(Icons.contact_phone),
                        ),
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // حد الائتمان
                      TextFormField(
                        controller: _creditLimitController,
                        decoration: const InputDecoration(
                          labelText: 'حد الائتمان (جرام)',
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'يرجى إدخال رقم صحيح';
                            }
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // الملاحظات
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'ملاحظات',
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: UIConstants.paddingMedium),
                      
                      // حالة النشاط
                      SwitchListTile(
                        title: const Text('عميل نشط'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: UIConstants.paddingLarge),
              
              // أزرار الحفظ والإلغاء
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: UIConstants.paddingSmall),
                  ElevatedButton(
                    onPressed: _saveClient,
                    child: Text(widget.client == null ? 'إضافة' : 'حفظ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// حوار عرض تفاصيل العميل
class ClientDetailsDialog extends StatelessWidget {
  final Client client;

  const ClientDetailsDialog({
    Key? key,
    required this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryGold,
                  child: Text(
                    client.name.isNotEmpty ? client.name[0].toUpperCase() : '؟',
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: UIConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (client.businessName != null)
                        Text(
                          client.businessName!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.grey600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!client.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'غير نشط',
                      style: TextStyle(
                        color: AppTheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: UIConstants.paddingLarge),
            
            // معلومات الاتصال
            _buildInfoSection(
              context,
              'معلومات الاتصال',
              [
                _buildInfoRow('الهاتف', client.phone),
                if (client.email != null) _buildInfoRow('البريد الإلكتروني', client.email!),
                if (client.address != null) _buildInfoRow('العنوان', client.address!),
                if (client.contactPerson != null) _buildInfoRow('الشخص المسؤول', client.contactPerson!),
              ],
            ),
            
            const SizedBox(height: UIConstants.paddingMedium),
            
            // المعلومات التجارية
            if (client.commercialRegistration != null || client.taxNumber != null)
              _buildInfoSection(
                context,
                'المعلومات التجارية',
                [
                  if (client.commercialRegistration != null) 
                    _buildInfoRow('السجل التجاري', client.commercialRegistration!),
                  if (client.taxNumber != null) 
                    _buildInfoRow('الرقم الضريبي', client.taxNumber!),
                ],
              ),
            
            const SizedBox(height: UIConstants.paddingMedium),
            
            // الأرصدة
            _buildInfoSection(
              context,
              'أرصدة الذهب',
              [
                _buildInfoRow('عيار 24', '${client.currentBalance24k.toStringAsFixed(3)} جرام'),
                _buildInfoRow('عيار 22', '${client.currentBalance22k.toStringAsFixed(3)} جرام'),
                _buildInfoRow('عيار 21', '${client.currentBalance21k.toStringAsFixed(3)} جرام'),
                _buildInfoRow('عيار 18', '${client.currentBalance18k.toStringAsFixed(3)} جرام'),
                _buildInfoRow('الإجمالي', '${client.totalBalance.toStringAsFixed(3)} جرام', 
                    isTotal: true),
              ],
            ),
            
            const SizedBox(height: UIConstants.paddingMedium),
            
            // معلومات إضافية
            _buildInfoSection(
              context,
              'معلومات إضافية',
              [
                _buildInfoRow('حد الائتمان', '${client.creditLimit.toStringAsFixed(3)} جرام'),
                _buildInfoRow('تاريخ التسجيل', client.createdAt.toString().split(' ')[0]),
                if (client.lastTransactionAt != null)
                  _buildInfoRow('آخر معاملة', client.lastTransactionAt!.toString().split(' ')[0]),
                if (client.notes != null) _buildInfoRow('ملاحظات', client.notes!),
              ],
            ),
            
            const SizedBox(height: UIConstants.paddingLarge),
            
            // زر الإغلاق
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إغلاق'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGold,
          ),
        ),
        const SizedBox(height: UIConstants.paddingSmall),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? AppTheme.primaryGold : AppTheme.grey600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? AppTheme.primaryGold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

