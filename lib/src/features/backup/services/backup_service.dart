import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';

enum BackupType {
  full,
  incremental,
  differential
}

enum BackupStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled
}

enum BackupFrequency {
  daily,
  weekly,
  monthly,
  manual
}

class BackupService {
  static const String _backupDirectory = 'backups';
  static const String _tempDirectory = 'temp_backup';
  
  // إنشاء نسخة احتياطية كاملة
  static Future<BackupResult> createFullBackup({
    required String backupPath,
    String? description,
    bool compress = true,
    bool encrypt = false,
    String? encryptionKey,
  }) async {
    final backupId = _generateBackupId();
    final startTime = DateTime.now();
    
    try {
      // إنشاء مجلد النسخ الاحتياطي
      final backupDir = Directory(path.join(backupPath, _backupDirectory));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      // إنشاء مجلد مؤقت
      final tempDir = Directory(path.join(backupPath, _tempDirectory));
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      await tempDir.create(recursive: true);
      
      // نسخ قاعدة البيانات
      final dbBackupPath = await _backupDatabase(tempDir.path);
      
      // نسخ الملفات والصور
      final filesBackupPath = await _backupFiles(tempDir.path);
      
      // نسخ الإعدادات
      final settingsBackupPath = await _backupSettings(tempDir.path);
      
      // إنشاء ملف معلومات النسخة الاحتياطية
      final backupInfo = BackupInfo(
        id: backupId,
        type: BackupType.full,
        createdAt: startTime,
        description: description,
        size: await _calculateDirectorySize(tempDir.path),
        files: await _getFilesList(tempDir.path),
        checksum: await _calculateChecksum(tempDir.path),
      );
      
      final infoFile = File(path.join(tempDir.path, 'backup_info.json'));
      await infoFile.writeAsString(jsonEncode(backupInfo.toJson()));
      
      // ضغط النسخة الاحتياطية
      String finalBackupPath;
      if (compress) {
        finalBackupPath = await _compressBackup(tempDir.path, backupDir.path, backupId);
      } else {
        finalBackupPath = path.join(backupDir.path, backupId);
        await _copyDirectory(tempDir.path, finalBackupPath);
      }
      
      // تشفير النسخة الاحتياطية
      if (encrypt && encryptionKey != null) {
        finalBackupPath = await _encryptBackup(finalBackupPath, encryptionKey);
      }
      
      // حذف المجلد المؤقت
      await tempDir.delete(recursive: true);
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      return BackupResult(
        success: true,
        backupId: backupId,
        backupPath: finalBackupPath,
        duration: duration,
        size: await _getFileSize(finalBackupPath),
        message: 'تم إنشاء النسخة الاحتياطية بنجاح',
      );
      
    } catch (e) {
      // حذف المجلد المؤقت في حالة الخطأ
      final tempDir = Directory(path.join(backupPath, _tempDirectory));
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      return BackupResult(
        success: false,
        backupId: backupId,
        duration: duration,
        message: 'فشل في إنشاء النسخة الاحتياطية: $e',
        error: e.toString(),
      );
    }
  }
  
  // إنشاء نسخة احتياطية تزايدية
  static Future<BackupResult> createIncrementalBackup({
    required String backupPath,
    required String lastBackupId,
    String? description,
    bool compress = true,
  }) async {
    final backupId = _generateBackupId();
    final startTime = DateTime.now();
    
    try {
      // العثور على آخر نسخة احتياطية
      final lastBackupInfo = await _getBackupInfo(backupPath, lastBackupId);
      if (lastBackupInfo == null) {
        throw Exception('لم يتم العثور على النسخة الاحتياطية المرجعية');
      }
      
      // إنشاء مجلد مؤقت
      final tempDir = Directory(path.join(backupPath, _tempDirectory));
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      await tempDir.create(recursive: true);
      
      // نسخ الملفات المحدثة فقط
      final changedFiles = await _getChangedFiles(lastBackupInfo.createdAt);
      await _backupChangedFiles(tempDir.path, changedFiles);
      
      // إنشاء ملف معلومات النسخة الاحتياطية
      final backupInfo = BackupInfo(
        id: backupId,
        type: BackupType.incremental,
        createdAt: startTime,
        description: description,
        size: await _calculateDirectorySize(tempDir.path),
        files: await _getFilesList(tempDir.path),
        checksum: await _calculateChecksum(tempDir.path),
        parentBackupId: lastBackupId,
      );
      
      final infoFile = File(path.join(tempDir.path, 'backup_info.json'));
      await infoFile.writeAsString(jsonEncode(backupInfo.toJson()));
      
      // ضغط النسخة الاحتياطية
      final backupDir = Directory(path.join(backupPath, _backupDirectory));
      String finalBackupPath;
      if (compress) {
        finalBackupPath = await _compressBackup(tempDir.path, backupDir.path, backupId);
      } else {
        finalBackupPath = path.join(backupDir.path, backupId);
        await _copyDirectory(tempDir.path, finalBackupPath);
      }
      
      // حذف المجلد المؤقت
      await tempDir.delete(recursive: true);
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      return BackupResult(
        success: true,
        backupId: backupId,
        backupPath: finalBackupPath,
        duration: duration,
        size: await _getFileSize(finalBackupPath),
        message: 'تم إنشاء النسخة الاحتياطية التزايدية بنجاح',
      );
      
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      return BackupResult(
        success: false,
        backupId: backupId,
        duration: duration,
        message: 'فشل في إنشاء النسخة الاحتياطية التزايدية: $e',
        error: e.toString(),
      );
    }
  }
  
  // استعادة النسخة الاحتياطية
  static Future<RestoreResult> restoreBackup({
    required String backupPath,
    required String backupId,
    required String restorePath,
    bool overwriteExisting = false,
    String? encryptionKey,
    List<String>? selectedFiles,
  }) async {
    final startTime = DateTime.now();
    
    try {
      // العثور على النسخة الاحتياطية
      final backupFile = await _findBackupFile(backupPath, backupId);
      if (backupFile == null) {
        throw Exception('لم يتم العثور على النسخة الاحتياطية');
      }
      
      // إنشاء مجلد مؤقت للاستعادة
      final tempDir = Directory(path.join(restorePath, 'temp_restore'));
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      await tempDir.create(recursive: true);
      
      // فك التشفير إذا لزم الأمر
      String workingBackupPath = backupFile.path;
      if (encryptionKey != null) {
        workingBackupPath = await _decryptBackup(backupFile.path, encryptionKey, tempDir.path);
      }
      
      // فك الضغط
      String extractedPath;
      if (workingBackupPath.endsWith('.zip')) {
        extractedPath = await _extractBackup(workingBackupPath, tempDir.path);
      } else {
        extractedPath = workingBackupPath;
      }
      
      // قراءة معلومات النسخة الاحتياطية
      final backupInfo = await _readBackupInfo(extractedPath);
      
      // التحقق من سلامة النسخة الاحتياطية
      final isValid = await _verifyBackupIntegrity(extractedPath, backupInfo);
      if (!isValid) {
        throw Exception('النسخة الاحتياطية تالفة أو غير صحيحة');
      }
      
      // استعادة الملفات
      final restoredFiles = <String>[];
      if (selectedFiles != null && selectedFiles.isNotEmpty) {
        // استعادة ملفات محددة
        for (final file in selectedFiles) {
          final sourcePath = path.join(extractedPath, file);
          final targetPath = path.join(restorePath, file);
          
          if (await File(sourcePath).exists()) {
            await _copyFileWithDirectories(sourcePath, targetPath, overwriteExisting);
            restoredFiles.add(file);
          }
        }
      } else {
        // استعادة جميع الملفات
        await _restoreAllFiles(extractedPath, restorePath, overwriteExisting);
        restoredFiles.addAll(backupInfo.files);
      }
      
      // حذف المجلد المؤقت
      await tempDir.delete(recursive: true);
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      return RestoreResult(
        success: true,
        backupId: backupId,
        restoredFiles: restoredFiles,
        duration: duration,
        message: 'تم استعادة النسخة الاحتياطية بنجاح',
      );
      
    } catch (e) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      return RestoreResult(
        success: false,
        backupId: backupId,
        restoredFiles: [],
        duration: duration,
        message: 'فشل في استعادة النسخة الاحتياطية: $e',
        error: e.toString(),
      );
    }
  }
  
  // الحصول على قائمة النسخ الاحتياطية
  static Future<List<BackupInfo>> getBackupsList(String backupPath) async {
    final backups = <BackupInfo>[];
    
    try {
      final backupDir = Directory(path.join(backupPath, _backupDirectory));
      if (!await backupDir.exists()) {
        return backups;
      }
      
      await for (final entity in backupDir.list()) {
        if (entity is File && entity.path.endsWith('.zip')) {
          try {
            final backupInfo = await _getBackupInfoFromFile(entity);
            if (backupInfo != null) {
              backups.add(backupInfo);
            }
          } catch (e) {
            // تجاهل الملفات التالفة
          }
        } else if (entity is Directory) {
          try {
            final backupInfo = await _readBackupInfo(entity.path);
            backups.add(backupInfo);
          } catch (e) {
            // تجاهل المجلدات التالفة
          }
        }
      }
      
      // ترتيب النسخ الاحتياطية حسب التاريخ
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
    } catch (e) {
      throw Exception('فشل في جلب قائمة النسخ الاحتياطية: $e');
    }
    
    return backups;
  }
  
  // حذف نسخة احتياطية
  static Future<bool> deleteBackup(String backupPath, String backupId) async {
    try {
      final backupFile = await _findBackupFile(backupPath, backupId);
      if (backupFile != null) {
        await backupFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('فشل في حذف النسخة الاحتياطية: $e');
    }
  }
  
  // تنظيف النسخ الاحتياطية القديمة
  static Future<int> cleanupOldBackups(String backupPath, {
    int maxBackups = 10,
    Duration maxAge = const Duration(days: 90),
  }) async {
    int deletedCount = 0;
    
    try {
      final backups = await getBackupsList(backupPath);
      final cutoffDate = DateTime.now().subtract(maxAge);
      
      // حذف النسخ الاحتياطية القديمة
      for (final backup in backups) {
        if (backup.createdAt.isBefore(cutoffDate)) {
          await deleteBackup(backupPath, backup.id);
          deletedCount++;
        }
      }
      
      // حذف النسخ الاحتياطية الزائدة
      final remainingBackups = await getBackupsList(backupPath);
      if (remainingBackups.length > maxBackups) {
        final excessBackups = remainingBackups.skip(maxBackups);
        for (final backup in excessBackups) {
          await deleteBackup(backupPath, backup.id);
          deletedCount++;
        }
      }
      
    } catch (e) {
      throw Exception('فشل في تنظيف النسخ الاحتياطية: $e');
    }
    
    return deletedCount;
  }
  
  // الطرق المساعدة
  static String _generateBackupId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'backup_$timestamp';
  }
  
  static Future<String> _backupDatabase(String tempPath) async {
    // نسخ قاعدة البيانات
    // يجب تنفيذ هذا حسب نوع قاعدة البيانات المستخدمة
    return path.join(tempPath, 'database');
  }
  
  static Future<String> _backupFiles(String tempPath) async {
    // نسخ الملفات والصور
    return path.join(tempPath, 'files');
  }
  
  static Future<String> _backupSettings(String tempPath) async {
    // نسخ الإعدادات
    return path.join(tempPath, 'settings');
  }
  
  static Future<int> _calculateDirectorySize(String dirPath) async {
    int totalSize = 0;
    final dir = Directory(dirPath);
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    
    return totalSize;
  }
  
  static Future<List<String>> _getFilesList(String dirPath) async {
    final files = <String>[];
    final dir = Directory(dirPath);
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = path.relative(entity.path, from: dirPath);
        files.add(relativePath);
      }
    }
    
    return files;
  }
  
  static Future<String> _calculateChecksum(String dirPath) async {
    final files = await _getFilesList(dirPath);
    files.sort();
    
    final digest = sha256;
    for (final file in files) {
      final filePath = path.join(dirPath, file);
      final fileBytes = await File(filePath).readAsBytes();
      digest.add(fileBytes);
    }
    
    return digest.close().toString();
  }
  
  static Future<String> _compressBackup(String sourcePath, String targetDir, String backupId) async {
    final archive = Archive();
    final sourceDir = Directory(sourcePath);
    
    await for (final entity in sourceDir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = path.relative(entity.path, from: sourcePath);
        final fileBytes = await entity.readAsBytes();
        final archiveFile = ArchiveFile(relativePath, fileBytes.length, fileBytes);
        archive.addFile(archiveFile);
      }
    }
    
    final zipData = ZipEncoder().encode(archive);
    final zipPath = path.join(targetDir, '$backupId.zip');
    await File(zipPath).writeAsBytes(zipData!);
    
    return zipPath;
  }
  
  static Future<String> _encryptBackup(String backupPath, String encryptionKey) async {
    // تنفيذ تشفير النسخة الاحتياطية
    // يمكن استخدام مكتبة التشفير المناسبة
    return backupPath;
  }
  
  static Future<void> _copyDirectory(String sourcePath, String targetPath) async {
    final sourceDir = Directory(sourcePath);
    final targetDir = Directory(targetPath);
    
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    
    await for (final entity in sourceDir.list(recursive: true)) {
      final relativePath = path.relative(entity.path, from: sourcePath);
      final targetEntityPath = path.join(targetPath, relativePath);
      
      if (entity is File) {
        final targetFile = File(targetEntityPath);
        await targetFile.parent.create(recursive: true);
        await entity.copy(targetEntityPath);
      }
    }
  }
  
  static Future<int> _getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    
    final dir = Directory(filePath);
    if (await dir.exists()) {
      return await _calculateDirectorySize(filePath);
    }
    
    return 0;
  }
  
  static Future<BackupInfo?> _getBackupInfo(String backupPath, String backupId) async {
    // البحث عن معلومات النسخة الاحتياطية
    return null;
  }
  
  static Future<List<String>> _getChangedFiles(DateTime since) async {
    // الحصول على قائمة الملفات المحدثة منذ تاريخ معين
    return [];
  }
  
  static Future<void> _backupChangedFiles(String tempPath, List<String> files) async {
    // نسخ الملفات المحدثة
  }
  
  static Future<File?> _findBackupFile(String backupPath, String backupId) async {
    // البحث عن ملف النسخة الاحتياطية
    return null;
  }
  
  static Future<String> _decryptBackup(String backupPath, String encryptionKey, String tempPath) async {
    // فك تشفير النسخة الاحتياطية
    return backupPath;
  }
  
  static Future<String> _extractBackup(String zipPath, String extractPath) async {
    // فك ضغط النسخة الاحتياطية
    return extractPath;
  }
  
  static Future<BackupInfo> _readBackupInfo(String backupPath) async {
    // قراءة معلومات النسخة الاحتياطية
    throw UnimplementedError();
  }
  
  static Future<bool> _verifyBackupIntegrity(String backupPath, BackupInfo backupInfo) async {
    // التحقق من سلامة النسخة الاحتياطية
    return true;
  }
  
  static Future<void> _copyFileWithDirectories(String sourcePath, String targetPath, bool overwrite) async {
    // نسخ ملف مع إنشاء المجلدات
  }
  
  static Future<void> _restoreAllFiles(String sourcePath, String targetPath, bool overwrite) async {
    // استعادة جميع الملفات
  }
  
  static Future<BackupInfo?> _getBackupInfoFromFile(File file) async {
    // استخراج معلومات النسخة الاحتياطية من الملف
    return null;
  }
}

// نماذج البيانات
class BackupInfo {
  final String id;
  final BackupType type;
  final DateTime createdAt;
  final String? description;
  final int size;
  final List<String> files;
  final String checksum;
  final String? parentBackupId;

  BackupInfo({
    required this.id,
    required this.type,
    required this.createdAt,
    this.description,
    required this.size,
    required this.files,
    required this.checksum,
    this.parentBackupId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'size': size,
      'files': files,
      'checksum': checksum,
      'parentBackupId': parentBackupId,
    };
  }

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      id: json['id'],
      type: BackupType.values[json['type']],
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'],
      size: json['size'],
      files: List<String>.from(json['files']),
      checksum: json['checksum'],
      parentBackupId: json['parentBackupId'],
    );
  }
}

class BackupResult {
  final bool success;
  final String backupId;
  final String? backupPath;
  final Duration duration;
  final int? size;
  final String message;
  final String? error;

  BackupResult({
    required this.success,
    required this.backupId,
    this.backupPath,
    required this.duration,
    this.size,
    required this.message,
    this.error,
  });
}

class RestoreResult {
  final bool success;
  final String backupId;
  final List<String> restoredFiles;
  final Duration duration;
  final String message;
  final String? error;

  RestoreResult({
    required this.success,
    required this.backupId,
    required this.restoredFiles,
    required this.duration,
    required this.message,
    this.error,
  });
}

