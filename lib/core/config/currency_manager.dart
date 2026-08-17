import 'package:shared_preferences/shared_preferences.dart';

class CurrencyManager {
  static String _currencyCode = 'COP';
  static String _currencySymbol = '\$';

  static String get currencyCode => _currencyCode;
  static String get currencySymbol => _currencySymbol;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currencyCode = prefs.getString('app_currency_code') ?? 'COP';
    _currencySymbol = prefs.getString('app_currency_symbol') ?? '\$';
  }

  static Future<void> setCurrency(String code, String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    _currencyCode = code;
    _currencySymbol = symbol;
    await prefs.setString('app_currency_code', code);
    await prefs.setString('app_currency_symbol', symbol);
  }

  static String format(double amount) {
    final amountStr = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '$_currencySymbol$amountStr $_currencyCode';
  }
}
