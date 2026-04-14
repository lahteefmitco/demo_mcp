import '../models/currency_option.dart';

const currencyOptions = <CurrencyOption>[
  CurrencyOption(
    code: 'USD',
    country: 'United States',
    currency: 'US Dollar',
    symbol: '\$',
  ),
  CurrencyOption(
    code: 'INR',
    country: 'India',
    currency: 'Indian Rupee',
    symbol: '₹',
  ),
  CurrencyOption(
    code: 'EUR',
    country: 'European Union',
    currency: 'Euro',
    symbol: '€',
  ),
  CurrencyOption(
    code: 'GBP',
    country: 'United Kingdom',
    currency: 'Pound Sterling',
    symbol: '£',
  ),
  CurrencyOption(
    code: 'JPY',
    country: 'Japan',
    currency: 'Japanese Yen',
    symbol: '¥',
  ),
  CurrencyOption(
    code: 'CNY',
    country: 'China',
    currency: 'Chinese Yuan',
    symbol: '¥',
  ),
  CurrencyOption(
    code: 'CAD',
    country: 'Canada',
    currency: 'Canadian Dollar',
    symbol: 'C\$',
  ),
  CurrencyOption(
    code: 'AUD',
    country: 'Australia',
    currency: 'Australian Dollar',
    symbol: 'A\$',
  ),
  CurrencyOption(
    code: 'CHF',
    country: 'Switzerland',
    currency: 'Swiss Franc',
    symbol: 'Fr',
  ),
  CurrencyOption(
    code: 'SGD',
    country: 'Singapore',
    currency: 'Singapore Dollar',
    symbol: 'S\$',
  ),
  CurrencyOption(
    code: 'AED',
    country: 'United Arab Emirates',
    currency: 'UAE Dirham',
    symbol: 'د.إ',
  ),
  CurrencyOption(
    code: 'SAR',
    country: 'Saudi Arabia',
    currency: 'Saudi Riyal',
    symbol: 'ر.س',
  ),
  CurrencyOption(
    code: 'KRW',
    country: 'South Korea',
    currency: 'South Korean Won',
    symbol: '₩',
  ),
  CurrencyOption(
    code: 'RUB',
    country: 'Russia',
    currency: 'Russian Ruble',
    symbol: '₽',
  ),
  CurrencyOption(
    code: 'BRL',
    country: 'Brazil',
    currency: 'Brazilian Real',
    symbol: 'R\$',
  ),
  CurrencyOption(
    code: 'MXN',
    country: 'Mexico',
    currency: 'Mexican Peso',
    symbol: 'Mex\$',
  ),
  CurrencyOption(
    code: 'ZAR',
    country: 'South Africa',
    currency: 'South African Rand',
    symbol: 'R',
  ),
  CurrencyOption(
    code: 'TRY',
    country: 'Turkey',
    currency: 'Turkish Lira',
    symbol: '₺',
  ),
  CurrencyOption(
    code: 'THB',
    country: 'Thailand',
    currency: 'Thai Baht',
    symbol: '฿',
  ),
  CurrencyOption(
    code: 'MYR',
    country: 'Malaysia',
    currency: 'Malaysian Ringgit',
    symbol: 'RM',
  ),
];

const defaultCurrency = CurrencyOption(
  code: 'INR',
  country: 'India',
  currency: 'Indian Rupee',
  symbol: '₹',
);

CurrencyOption currencyFromCode(String? code) {
  for (final option in currencyOptions) {
    if (option.code == code) {
      return option;
    }
  }

  return defaultCurrency;
}

String formatMoney(CurrencyOption currency, double amount) {
  return '${currency.symbol}${amount.toStringAsFixed(2)}';
}

String formatSignedMoney(
  CurrencyOption currency,
  double amount, {
  required bool isPositive,
}) {
  final prefix = isPositive ? '+' : '-';
  return '$prefix${currency.symbol}${amount.toStringAsFixed(2)}';
}
