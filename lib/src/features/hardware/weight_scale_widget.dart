import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../services/hardware/hardware_service.dart';

class WeightScaleWidget extends ConsumerStatefulWidget {
  final Function(double)? onWeightChanged;
  
  const WeightScaleWidget({
    Key? key,
    this.onWeightChanged,
  }) : super(key: key);

  @override
  ConsumerState<WeightScaleWidget> createState() => _WeightScaleWidgetState();
}

class _WeightScaleWidgetState extends ConsumerState<WeightScaleWidget> {
  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(scaleConnectionProvider);
    final currentWeight = ref.watch(currentWeightProvider);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الميزان الإلكتروني',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isConnected ? AppTheme.success : AppTheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: UIConstants.paddingSmall),
                    Text(
                      isConnected ? 'متصل' : 'غير متصل',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isConnected ? AppTheme.success : AppTheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            
            // عرض الوزن الحالي
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(UIConstants.paddingLarge),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
                border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.scale,
                    size: UIConstants.iconSizeLarge,
                    color: AppTheme.primaryGold,
                  ),
                  const SizedBox(height: UIConstants.paddingSmall),
                  Text(
                    currentWeight != null 
                        ? '${currentWeight.toStringAsFixed(3)} جرام'
                        : '--- جرام',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                  if (currentWeight != null) ...[
                    const SizedBox(height: UIConstants.paddingSmall),
                    Text(
                      'الوزن الحالي',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    onPressed: isConnected ? _readWeight : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text('قراءة الوزن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isConnected ? _tareScale : null,
                    icon: const Icon(Icons.exposure_zero),
                    label: const Text('تصفير'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.info,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: UIConstants.paddingSmall),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isConnected ? null : _connectScale,
                    icon: const Icon(Icons.link),
                    label: const Text('اتصال'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: UIConstants.paddingSmall),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isConnected ? _disconnectScale : null,
                    icon: const Icon(Icons.link_off),
                    label: const Text('قطع الاتصال'),
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
                onPressed: _simulateReading,
                icon: const Icon(Icons.science),
                label: const Text('محاكاة قراءة (للاختبار)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warning,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _connectScale() async {
    await ref.read(scaleConnectionProvider.notifier).connect();
  }

  Future<void> _disconnectScale() async {
    await ref.read(scaleConnectionProvider.notifier).disconnect();
  }

  Future<void> _readWeight() async {
    await ref.read(currentWeightProvider.notifier).readWeight();
    final weight = ref.read(currentWeightProvider);
    if (weight != null && widget.onWeightChanged != null) {
      widget.onWeightChanged!(weight);
    }
  }

  Future<void> _tareScale() async {
    await ref.read(currentWeightProvider.notifier).tareScale();
  }

  Future<void> _simulateReading() async {
    await ref.read(currentWeightProvider.notifier).simulateReading();
    final weight = ref.read(currentWeightProvider);
    if (weight != null && widget.onWeightChanged != null) {
      widget.onWeightChanged!(weight);
    }
  }
}

