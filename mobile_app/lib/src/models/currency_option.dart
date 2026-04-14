class CurrencyOption {
  const CurrencyOption({
    required this.code,
    required this.country,
    required this.currency,
    required this.symbol,
  });

  final String code;
  final String country;
  final String currency;
  final String symbol;

  String get label => '$country • $currency';
}
