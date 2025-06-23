import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_project/localization/localization.dart'; // تأكد من استيراد ملف الترجمة الصحيح
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/gold_item_model.dart';
import '../../services/gold_management/gold_management_service.dart';

class GoldPriceWidget extends ConsumerWidget {
  const GoldPriceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goldPriceAsyncValue = ref.watch(goldPriceProvider);
    final localizations = AppLocalizations.of(context);

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
                  localizations.translate('current_gold_prices') ?? 'أسعار الذهب الحالية',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.refresh(goldPriceProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            goldPriceAsyncValue.when(
              data: (goldPrice) => _buildPriceDisplay(context, goldPrice),
              loading: () => _buildLoadingDisplay(),
              error: (error, stack) => _buildErrorDisplay(context, error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDisplay(BuildContext context, double goldPrice) {
    return Column(
      children: [
        _buildPriceCard(
          context,
          title: 'سعر الجرام',
          price: goldPrice,
          unit: 'ر.س/جرام',
          icon: Icons.scale,
          color: AppTheme.primaryGold,
        ),
        const SizedBox(height: UIConstants.paddingSmall),
        _buildPriceCard(
          context,
          title: 'سعر الأوقية',
          price: goldPrice * 31.1035, // تحويل من جرام إلى أوقية
          unit: 'ر.س/أوقية',
          icon: Icons.monetization_on,
          color: AppTheme.accentGold,
        ),
        const SizedBox(height: UIConstants.paddingSmall),
        _buildPriceCard(
          context,
          title: 'سعر الكيلو',
          price: goldPrice * 1000,
          unit: 'ر.س/كيلو',
          icon: Icons.fitness_center,
          color: AppTheme.secondaryBrown,
        ),
        const SizedBox(height: UIConstants.paddingMedium),
        Container(
          padding: const EdgeInsets.all(UIConstants.paddingSmall),
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
          ),
          child: Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppTheme.success,
                size: UIConstants.iconSizeSmall,
              ),
              const SizedBox(width: UIConstants.paddingSmall),
              Text(
                'آخر تحديث: ${DateTime.now().toString().substring(0, 16)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(
    BuildContext context, {
    required String title,
    required double price,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: UIConstants.iconSizeMedium,
          ),
          const SizedBox(width: UIConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.grey600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${price.toStringAsFixed(2)} $unit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDisplay() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: UIConstants.paddingMedium),
          Text(localizations.translate('loading_gold_prices') ?? 'جاري تحميل أسعار الذهب...'),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.error,
            size: UIConstants.iconSizeLarge,
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          Text(
            'خطأ في تحميل أسعار الذهب',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          Text(
            'يرجى المحاولة مرة أخرى',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.grey600,
            ),
          ),
        ],
      ),
    );
  }
}

