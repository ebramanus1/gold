import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/network/network_config_service.dart';
import '../../services/network/network_discovery_service.dart';
import '../../services/sync/data_sync_service.dart';

/// شاشة إعدادات الشبكة المحلية
class NetworkSettingsScreen extends StatefulWidget {
  const NetworkSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NetworkSettingsScreen> createState() => _NetworkSettingsScreenState();
}

class _NetworkSettingsScreenState extends State<NetworkSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _databaseController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isOfflineMode = false;
  bool _autoDiscover = true;
  bool _isDiscovering = false;
  List<String> _discoveredServers = [];
  NetworkStatus _networkStatus = NetworkStatus.disconnected;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkNetworkStatus();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _databaseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// تحميل الإعدادات الحالية
  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final config = NetworkConfigService.instance;
      final settings = await config.getAllSettings();
      
      setState(() {
        _hostController.text = settings['serverHost'];
        _portController.text = settings['serverPort'].toString();
        _databaseController.text = settings['databaseName'];
        _usernameController.text = settings['username'];
        _passwordController.text = settings['password'];
        _isOfflineMode = settings['isOfflineMode'];
        _autoDiscover = settings['autoDiscover'];
      });
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل الإعدادات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// فحص حالة الشبكة
  Future<void> _checkNetworkStatus() async {
    final networkService = NetworkDiscoveryService.instance;
    final status = await networkService.getNetworkStatus();
    
    setState(() {
      _networkStatus = status;
    });
  }

  /// اكتشاف الخوادم المتاحة
  Future<void> _discoverServers() async {
    setState(() {
      _isDiscovering = true;
      _discoveredServers.clear();
    });

    try {
      final networkService = NetworkDiscoveryService.instance;
      final servers = await networkService.discoverServers(
        onServerFound: (server) {
          setState(() {
            _discoveredServers.add(server);
          });
        },
      );
      
      if (servers.isEmpty) {
        _showInfoSnackBar('لم يتم العثور على خوادم متاحة');
      } else {
        _showSuccessSnackBar('تم العثور على ${servers.length} خادم');
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في اكتشاف الخوادم: $e');
    } finally {
      setState(() => _isDiscovering = false);
    }
  }

  /// اختبار الاتصال
  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final networkService = NetworkDiscoveryService.instance;
      final host = _hostController.text.trim();
      final port = int.parse(_portController.text.trim());
      
      final isConnected = await networkService.testConnection(host, port);
      
      if (isConnected) {
        _showSuccessSnackBar('تم الاتصال بنجاح!');
      } else {
        _showErrorSnackBar('فشل في الاتصال بالخادم');
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في اختبار الاتصال: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// حفظ الإعدادات
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final config = NetworkConfigService.instance;
      
      await config.saveConfiguration(
        host: _hostController.text.trim(),
        port: int.parse(_portController.text.trim()),
        database: _databaseController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        offlineMode: _isOfflineMode,
        autoDiscover: _autoDiscover,
      );
      
      _showSuccessSnackBar('تم حفظ الإعدادات بنجاح');
      Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackBar('خطأ في حفظ الإعدادات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// إعادة تعيين الإعدادات
  Future<void> _resetSettings() async {
    final confirmed = await _showConfirmDialog(
      'إعادة تعيين الإعدادات',
      'هل أنت متأكد من إعادة تعيين جميع الإعدادات للقيم الافتراضية؟',
    );
    
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final config = NetworkConfigService.instance;
      await config.resetToDefaults();
      await _loadSettings();
      _showSuccessSnackBar('تم إعادة تعيين الإعدادات');
    } catch (e) {
      _showErrorSnackBar('خطأ في إعادة تعيين الإعدادات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// مزامنة البيانات
  Future<void> _syncData() async {
    setState(() => _isLoading = true);

    try {
      final syncService = DataSyncService.instance;
      final result = await syncService.performSync();
      
      if (result.success) {
        _showSuccessSnackBar(result.message);
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في مزامنة البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الشبكة المحلية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkNetworkStatus,
            tooltip: 'تحديث حالة الشبكة',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildNetworkStatusCard(),
                    const SizedBox(height: 16),
                    _buildServerDiscoveryCard(),
                    const SizedBox(height: 16),
                    _buildConnectionSettingsCard(),
                    const SizedBox(height: 16),
                    _buildDatabaseSettingsCard(),
                    const SizedBox(height: 16),
                    _buildAdvancedSettingsCard(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  /// بطاقة حالة الشبكة
  Widget _buildNetworkStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'حالة الشبكة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getNetworkStatusIcon(),
                  color: _getNetworkStatusColor(),
                ),
                const SizedBox(width: 8),
                Text(
                  _getNetworkStatusText(),
                  style: TextStyle(
                    color: _getNetworkStatusColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة اكتشاف الخوادم
  Widget _buildServerDiscoveryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'اكتشاف الخوادم',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _isDiscovering ? null : _discoverServers,
                  icon: _isDiscovering
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(_isDiscovering ? 'جاري البحث...' : 'بحث'),
                ),
              ],
            ),
            if (_discoveredServers.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('الخوادم المكتشفة:'),
              const SizedBox(height: 8),
              ...(_discoveredServers.map((server) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.computer),
                    title: Text(server),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        _hostController.text = server;
                      },
                    ),
                  ))),
            ],
          ],
        ),
      ),
    );
  }

  /// بطاقة إعدادات الاتصال
  Widget _buildConnectionSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إعدادات الاتصال',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'عنوان الخادم',
                hintText: '192.168.1.100',
                prefixIcon: Icon(Icons.computer),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال عنوان الخادم';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'منفذ الخادم',
                hintText: '5432',
                prefixIcon: Icon(Icons.settings_ethernet),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال منفذ الخادم';
                }
                final port = int.tryParse(value);
                if (port == null || port < 1 || port > 65535) {
                  return 'منفذ غير صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _testConnection,
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('اختبار الاتصال'),
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة إعدادات قاعدة البيانات
  Widget _buildDatabaseSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إعدادات قاعدة البيانات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _databaseController,
              decoration: const InputDecoration(
                labelText: 'اسم قاعدة البيانات',
                prefixIcon: Icon(Icons.storage),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسم قاعدة البيانات';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسم المستخدم';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال كلمة المرور';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة الإعدادات المتقدمة
  Widget _buildAdvancedSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إعدادات متقدمة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('الوضع غير المتصل'),
              subtitle: const Text('العمل بدون اتصال بالشبكة'),
              value: _isOfflineMode,
              onChanged: (value) {
                setState(() => _isOfflineMode = value);
              },
            ),
            SwitchListTile(
              title: const Text('الاكتشاف التلقائي'),
              subtitle: const Text('البحث التلقائي عن الخوادم المتاحة'),
              value: _autoDiscover,
              onChanged: (value) {
                setState(() => _autoDiscover = value);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _syncData,
              icon: const Icon(Icons.sync),
              label: const Text('مزامنة البيانات'),
            ),
          ],
        ),
      ),
    );
  }

  /// أزرار الإجراءات
  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('حفظ الإعدادات'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: _resetSettings,
                child: const Text('إعادة تعيين'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods
  IconData _getNetworkStatusIcon() {
    switch (_networkStatus) {
      case NetworkStatus.connectedToServer:
        return Icons.wifi;
      case NetworkStatus.connectedNoServer:
        return Icons.wifi_off;
      case NetworkStatus.disconnected:
        return Icons.signal_wifi_off;
    }
  }

  Color _getNetworkStatusColor() {
    switch (_networkStatus) {
      case NetworkStatus.connectedToServer:
        return Colors.green;
      case NetworkStatus.connectedNoServer:
        return Colors.orange;
      case NetworkStatus.disconnected:
        return Colors.red;
    }
  }

  String _getNetworkStatusText() {
    switch (_networkStatus) {
      case NetworkStatus.connectedToServer:
        return 'متصل بالخادم';
      case NetworkStatus.connectedNoServer:
        return 'متصل بالشبكة - لا يوجد خادم';
      case NetworkStatus.disconnected:
        return 'غير متصل';
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

