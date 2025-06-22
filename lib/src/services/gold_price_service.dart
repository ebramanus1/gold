import 'package:flutter_riverpod/flutter_riverpod.dart';

// Dummy Gold Price Service
class GoldPriceService {
  Future<double> fetchGoldPrice() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Return a dummy gold price
    return 220.50; // Example price per gram
  }
}

final goldPriceServiceProvider = Provider((ref) => GoldPriceService());

final goldPriceProvider = FutureProvider<double>((ref) async {
  final goldPriceService = ref.watch(goldPriceServiceProvider);
  return goldPriceService.fetchGoldPrice();
});

