import 'dart:io';
import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:crypto/crypto.dart';

class CloudBackupService {
  static const List<String> _scopes = [drive.DriveApi.driveFileScope];
  static const String _credentialsPath = 'assets/credentials/service_account.json';
  
  drive.DriveApi? _driveApi;
  bool _isAuthenticated = false;

  // المصادقة مع Google Drive
  Future<bool> authenticate() async {
    try {
      final credentialsFile = File(_credentialsPath);
      if (!await credentialsFile.exists()) {
        throw Exception('ملف بيانات الاعتماد غير موجود');
      }

      final credentialsJson = await credentialsFile.readAsString();
      final credentials = ServiceAccountCredentials.fromJson(credentialsJson);
      
      final client = await clientViaServiceAccount(credentials, _scopes);
      _driveApi = drive.DriveApi(client);
      _isAuthenticated = true;
      
      return true;
    } catch (e) {
      print('فشل في المصادقة: $e');
      return false;
    }
  }

  // رفع نسخة احتياطية إلى السحابة
  Future<CloudBackupResult> uploadBackup({
    required String localBackupPath,
    required String backupName,
    String? description,
    bool encrypt = true,
    String? encryptionKey,
  }) async {
    if (!_isAuthenticated || _driveApi == null) {
      throw Exception('يجب المصادقة أولاً');
    }

    try {
      final startTime = DateTime.now();
      final backupFile = File(localBackupPath);
      
      if (!await backupFile.exists()) {
        throw Exception('ملف النسخة الاحتياطية غير موجود');
      }

      // تشفير الملف إذا لزم الأمر
      File fileToUpload = backupFile;
      if (encrypt && encryptionKey != null) {
        fileToUpload = await _encryptFile(backupFile, encryptionKey);
      }

      // إنشاء معلومات الملف
      final driveFile = drive.File()
        ..name = backupName
        ..description = description ?? 'نسخة احتياطية من Gold Workshop AI'
        ..parents = [await _getOrCreateBackupFolder()];

      // رفع الملف
      final media = drive.Media(fileToUpload.openRead(), await fileToUpload.length());
      final uploadedFile = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      // حذف الملف المشفر المؤقت
      if (encrypt && fileToUpload != backupFile) {
        await fileToUpload.delete();
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      return CloudBackupResult(
        success: true,
        fileId: uploadedFile.id!,
        fileName: backupName,
        size: await backupFile.length(),
        duration: duration,
        message: 'تم رفع النسخة الاحتياطية بنجاح',
      );

    } catch (e) {
      return CloudBackupResult(
        success: false,
        fileName: backupName,
        message: 'فشل في رفع النسخة الاحتياطية: $e',
        error: e.toString(),
      );
    }
  }

  // تحميل نسخة احتياطية من السحابة
  Future<CloudBackupResult> downloadBackup({
    required String fileId,
    required String localPath,
    bool decrypt = true,
    String? encryptionKey,
  }) async {
    if (!_isAuthenticated || _driveApi == null) {
      throw Exception('يجب المصادقة أولاً');
    }

    try {
      final startTime = DateTime.now();

      // الحصول على معلومات الملف
      final fileInfo = await _driveApi!.files.get(fileId);
      
      // تحميل الملف
      final media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final downloadedFile = File(localPath);
      await downloadedFile.parent.create(recursive: true);
      
      final sink = downloadedFile.openWrite();
      await media.stream.pipe(sink);
      await sink.close();

      // فك التشفير إذا لزم الأمر
      if (decrypt && encryptionKey != null) {
        await _decryptFile(downloadedFile, encryptionKey);
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      return CloudBackupResult(
        success: true,
        fileId: fileId,
        fileName: fileInfo.name ?? 'backup',
        size: await downloadedFile.length(),
        duration: duration,
        message: 'تم تحميل النسخة الاحتياطية بنجاح',
      );

    } catch (e) {
      return CloudBackupResult(
        success: false,
        fileId: fileId,
        message: 'فشل في تحميل النسخة الاحتياطية: $e',
        error: e.toString(),
      );
    }
  }

  // الحصول على قائمة النسخ الاحتياطية السحابية
  Future<List<CloudBackupInfo>> getCloudBackups() async {
    if (!_isAuthenticated || _driveApi == null) {
      throw Exception('يجب المصادقة أولاً');
    }

    try {
      final backupFolderId = await _getOrCreateBackupFolder();
      
      final fileList = await _driveApi!.files.list(
        q: "'$backupFolderId' in parents and trashed=false",
        orderBy: 'createdTime desc',
        spaces: 'drive',
      );

      final backups = <CloudBackupInfo>[];
      for (final file in fileList.files ?? []) {
        backups.add(CloudBackupInfo(
          id: file.id!,
          name: file.name!,
          description: file.description,
          size: int.tryParse(file.size ?? '0') ?? 0,
          createdTime: file.createdTime ?? DateTime.now(),
          modifiedTime: file.modifiedTime ?? DateTime.now(),
          mimeType: file.mimeType ?? 'application/octet-stream',
        ));
      }

      return backups;
    } catch (e) {
      throw Exception('فشل في جلب قائمة النسخ الاحتياطية: $e');
    }
  }

  // حذف نسخة احتياطية من السحابة
  Future<bool> deleteCloudBackup(String fileId) async {
    if (!_isAuthenticated || _driveApi == null) {
      throw Exception('يجب المصادقة أولاً');
    }

    try {
      await _driveApi!.files.delete(fileId);
      return true;
    } catch (e) {
      print('فشل في حذف النسخة الاحتياطية: $e');
      return false;
    }
  }

  // مزامنة النسخ الاحتياطية
  Future<SyncResult> syncBackups({
    required String localBackupPath,
    bool uploadNew = true,
    bool downloadMissing = true,
    bool deleteOld = false,
    int maxCloudBackups = 10,
  }) async {
    try {
      final startTime = DateTime.now();
      int uploaded = 0;
      int downloaded = 0;
      int deleted = 0;
      final errors = <String>[];

      // الحصول على النسخ المحلية والسحابية
      final localBackups = await _getLocalBackups(localBackupPath);
      final cloudBackups = await getCloudBackups();

      // رفع النسخ الجديدة
      if (uploadNew) {
        for (final localBackup in localBackups) {
          final exists = cloudBackups.any((cloud) => cloud.name == localBackup.name);
          if (!exists) {
            try {
              await uploadBackup(
                localBackupPath: localBackup.path,
                backupName: localBackup.name,
                description: 'مزامنة تلقائية',
              );
              uploaded++;
            } catch (e) {
              errors.add('فشل في رفع ${localBackup.name}: $e');
            }
          }
        }
      }

      // تحميل النسخ المفقودة
      if (downloadMissing) {
        for (final cloudBackup in cloudBackups) {
          final exists = localBackups.any((local) => local.name == cloudBackup.name);
          if (!exists) {
            try {
              final localPath = '$localBackupPath/${cloudBackup.name}';
              await downloadBackup(
                fileId: cloudBackup.id,
                localPath: localPath,
              );
              downloaded++;
            } catch (e) {
              errors.add('فشل في تحميل ${cloudBackup.name}: $e');
            }
          }
        }
      }

      // حذف النسخ القديمة
      if (deleteOld && cloudBackups.length > maxCloudBackups) {
        final oldBackups = cloudBackups.skip(maxCloudBackups);
        for (final oldBackup in oldBackups) {
          try {
            await deleteCloudBackup(oldBackup.id);
            deleted++;
          } catch (e) {
            errors.add('فشل في حذف ${oldBackup.name}: $e');
          }
        }
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      return SyncResult(
        success: errors.isEmpty,
        uploaded: uploaded,
        downloaded: downloaded,
        deleted: deleted,
        errors: errors,
        duration: duration,
      );

    } catch (e) {
      return SyncResult(
        success: false,
        errors: ['خطأ في المزامنة: $e'],
        duration: Duration.zero,
      );
    }
  }

  // التحقق من مساحة التخزين المتاحة
  Future<StorageInfo> getStorageInfo() async {
    if (!_isAuthenticated || _driveApi == null) {
      throw Exception('يجب المصادقة أولاً');
    }

    try {
      final about = await _driveApi!.about.get($fields: 'storageQuota');
      final quota = about.storageQuota;

      return StorageInfo(
        totalSpace: int.tryParse(quota?.limit ?? '0') ?? 0,
        usedSpace: int.tryParse(quota?.usage ?? '0') ?? 0,
        freeSpace: int.tryParse(quota?.limit ?? '0') ?? 0 - (int.tryParse(quota?.usage ?? '0') ?? 0),
      );
    } catch (e) {
      throw Exception('فشل في جلب معلومات التخزين: $e');
    }
  }

  // الطرق المساعدة
  Future<String> _getOrCreateBackupFolder() async {
    const folderName = 'Gold Workshop AI Backups';
    
    // البحث عن المجلد الموجود
    final folderList = await _driveApi!.files.list(
      q: "name='$folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
    );

    if (folderList.files?.isNotEmpty == true) {
      return folderList.files!.first.id!;
    }

    // إنشاء مجلد جديد
    final folder = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder';

    final createdFolder = await _driveApi!.files.create(folder);
    return createdFolder.id!;
  }

  Future<File> _encryptFile(File file, String encryptionKey) async {
    // تنفيذ تشفير الملف
    // يمكن استخدام مكتبة التشفير المناسبة
    final encryptedPath = '${file.path}.encrypted';
    final encryptedFile = File(encryptedPath);
    
    // نسخ الملف مؤقتاً (يجب تنفيذ التشفير الفعلي)
    await file.copy(encryptedPath);
    
    return encryptedFile;
  }

  Future<void> _decryptFile(File file, String encryptionKey) async {
    // تنفيذ فك تشفير الملف
    // يجب تنفيذ فك التشفير الفعلي
  }

  Future<List<LocalBackupInfo>> _getLocalBackups(String backupPath) async {
    final backups = <LocalBackupInfo>[];
    final backupDir = Directory(backupPath);
    
    if (!await backupDir.exists()) {
      return backups;
    }

    await for (final entity in backupDir.list()) {
      if (entity is File) {
        final stat = await entity.stat();
        backups.add(LocalBackupInfo(
          name: entity.uri.pathSegments.last,
          path: entity.path,
          size: stat.size,
          modifiedTime: stat.modified,
        ));
      }
    }

    return backups;
  }
}

// نماذج البيانات
class CloudBackupResult {
  final bool success;
  final String? fileId;
  final String fileName;
  final int? size;
  final Duration? duration;
  final String message;
  final String? error;

  CloudBackupResult({
    required this.success,
    this.fileId,
    required this.fileName,
    this.size,
    this.duration,
    required this.message,
    this.error,
  });
}

class CloudBackupInfo {
  final String id;
  final String name;
  final String? description;
  final int size;
  final DateTime createdTime;
  final DateTime modifiedTime;
  final String mimeType;

  CloudBackupInfo({
    required this.id,
    required this.name,
    this.description,
    required this.size,
    required this.createdTime,
    required this.modifiedTime,
    required this.mimeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'size': size,
      'createdTime': createdTime.toIso8601String(),
      'modifiedTime': modifiedTime.toIso8601String(),
      'mimeType': mimeType,
    };
  }

  factory CloudBackupInfo.fromJson(Map<String, dynamic> json) {
    return CloudBackupInfo(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      size: json['size'],
      createdTime: DateTime.parse(json['createdTime']),
      modifiedTime: DateTime.parse(json['modifiedTime']),
      mimeType: json['mimeType'],
    );
  }
}

class LocalBackupInfo {
  final String name;
  final String path;
  final int size;
  final DateTime modifiedTime;

  LocalBackupInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.modifiedTime,
  });
}

class SyncResult {
  final bool success;
  final int uploaded;
  final int downloaded;
  final int deleted;
  final List<String> errors;
  final Duration duration;

  SyncResult({
    required this.success,
    this.uploaded = 0,
    this.downloaded = 0,
    this.deleted = 0,
    this.errors = const [],
    required this.duration,
  });
}

class StorageInfo {
  final int totalSpace;
  final int usedSpace;
  final int freeSpace;

  StorageInfo({
    required this.totalSpace,
    required this.usedSpace,
    required this.freeSpace,
  });

  double get usagePercentage => totalSpace > 0 ? (usedSpace / totalSpace) * 100 : 0;
  
  String get totalSpaceFormatted => _formatBytes(totalSpace);
  String get usedSpaceFormatted => _formatBytes(usedSpace);
  String get freeSpaceFormatted => _formatBytes(freeSpace);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

// إعدادات النسخ الاحتياطي السحابي
class CloudBackupSettings {
  final bool autoSync;
  final Duration syncInterval;
  final bool encryptBackups;
  final int maxCloudBackups;
  final bool deleteLocalAfterUpload;
  final bool notifyOnSync;

  CloudBackupSettings({
    this.autoSync = false,
    this.syncInterval = const Duration(hours: 24),
    this.encryptBackups = true,
    this.maxCloudBackups = 10,
    this.deleteLocalAfterUpload = false,
    this.notifyOnSync = true,
  });

  factory CloudBackupSettings.fromJson(Map<String, dynamic> json) {
    return CloudBackupSettings(
      autoSync: json['autoSync'] ?? false,
      syncInterval: Duration(hours: json['syncIntervalHours'] ?? 24),
      encryptBackups: json['encryptBackups'] ?? true,
      maxCloudBackups: json['maxCloudBackups'] ?? 10,
      deleteLocalAfterUpload: json['deleteLocalAfterUpload'] ?? false,
      notifyOnSync: json['notifyOnSync'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoSync': autoSync,
      'syncIntervalHours': syncInterval.inHours,
      'encryptBackups': encryptBackups,
      'maxCloudBackups': maxCloudBackups,
      'deleteLocalAfterUpload': deleteLocalAfterUpload,
      'notifyOnSync': notifyOnSync,
    };
  }
}

