import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../services/hardware/hardware_service.dart';

class BarcodeScannerWidget extends ConsumerStatefulWidget {
  final Function(String)? onBarcodeScanned;
  
  const BarcodeScannerWidget({
    Key? key,
    this.onBarcodeScanned,
  }) : super(key: key);

  @override
  ConsumerState<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends ConsumerState<BarcodeScannerWidget> {
  String? _lastScannedBarcode;
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ماسح الباركود',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            
            // عرض الباركود المسحوب
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(UIConstants.paddingMedium),
              decoration: BoxDecoration(
                color: AppTheme.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
                border: Border.all(color: AppTheme.info.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: UIConstants.iconSizeLarge,
                    color: AppTheme.info,
                  ),
                  const SizedBox(height: UIConstants.paddingSmall),
                  Text(
                    _lastScannedBarcode ?? 'لم يتم مسح أي باركود',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _lastScannedBarcode != null ? AppTheme.info : AppTheme.grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_lastScannedBarcode != null) ...[
                    const SizedBox(height: UIConstants.paddingSmall),
                    Text(
                      'آخر باركود مسحوب',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.grey600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: UIConstants.paddingMedium),
            
            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isScanning ? null : _scanBarcode,
                    icon: _isScanning 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.qr_code_scanner),
                    label: Text(_isScanning ? 'جاري المسح...' : 'مسح باركود'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.info,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearBarcode,
                    icon: const Icon(Icons.clear),
                    label: const Text('مسح'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: UIConstants.paddingSmall),
            
            // زر المحاكاة للاختبار
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _simulateScan,
                icon: const Icon(Icons.science),
                label: const Text('محاكاة مسح (للاختبار)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warning,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            if (_lastScannedBarcode != null) ...[
              const SizedBox(height: UIConstants.paddingMedium),
              _buildBarcodeInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodeInfo() {
    final barcodeService = ref.read(barcodeServiceProvider);
    final isValid = barcodeService.validateBarcode(_lastScannedBarcode!);
    final itemId = barcodeService.extractItemIdFromBarcode(_lastScannedBarcode!);

    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      decoration: BoxDecoration(
        color: isValid 
            ? AppTheme.success.withOpacity(0.1)
            : AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        border: Border.all(
          color: isValid 
              ? AppTheme.success.withOpacity(0.3)
              : AppTheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.error,
                color: isValid ? AppTheme.success : AppTheme.error,
                size: UIConstants.iconSizeSmall,
              ),
              const SizedBox(width: UIConstants.paddingSmall),
              Text(
                isValid ? 'باركود صحيح' : 'باركود غير صحيح',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isValid ? AppTheme.success : AppTheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isValid && itemId != null) ...[
            const SizedBox(height: UIConstants.paddingSmall),
            Text(
              'معرف العنصر: $itemId',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _scanBarcode() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final barcodeService = ref.read(barcodeServiceProvider);
      final barcode = await barcodeService.scanBarcode();
      
      if (barcode != null) {
        setState(() {
          _lastScannedBarcode = barcode;
        });
        
        if (widget.onBarcodeScanned != null) {
          widget.onBarcodeScanned!(barcode);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في مسح الباركود: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _simulateScan() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final barcodeService = ref.read(barcodeServiceProvider);
      final barcode = await barcodeService.simulateBarcodeScan();
      
      setState(() {
        _lastScannedBarcode = barcode;
      });
      
      if (widget.onBarcodeScanned != null) {
        widget.onBarcodeScanned!(barcode);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في محاكاة المسح: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  void _clearBarcode() {
    setState(() {
      _lastScannedBarcode = null;
    });
  }
}

