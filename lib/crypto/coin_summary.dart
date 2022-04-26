import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:robinhood/crypto/crypto_theme.dart';
import 'package:robinhood/currency.dart';

import 'glitchy_price.dart';

/// Widget that displays the summary for a crypto's current price
/// and price action.
///
/// Displays:
///  - Abbreviation
///  - Name
///  - Price (USD)
///  - Today's price action in USD and percent
class CoinSummary extends StatelessWidget {
  const CoinSummary({
    Key? key,
    required this.abbreviation,
    required this.name,
    required this.price,
    required this.deltaPrice,
    required this.deltaPercent,
  }) : super(key: key);

  /// The coin's abbreviation, e.g., "BTC".
  final String abbreviation;

  /// The coin's name, e.g., "Bitcoin".
  final String name;

  /// The coin's current price in US dollars, e.g., "$40,123.00".
  final USD price;

  /// The latest change in price, e.g., "-$123.00"
  final USD deltaPrice;

  /// The percent change of the latest delta price, e.g., "-0.005".
  final double deltaPercent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          abbreviation,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
          ),
        ),
        const SizedBox(height: 12),
        GlitchyPrice(
          price: price,
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 48,
          ),
        ),
        const SizedBox(height: 8),
        _buildDailyChangeLine(),
      ],
    );
  }

  Widget _buildDailyChangeLine() {
    final sign = deltaPrice.inCents >= 0 ? "+" : "-";
    final formattedPercent = _percentFormat.format(deltaPercent);
    final priceAndPercentChange = "$sign${deltaPrice.toFormattedString()} ($formattedPercent)";

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$priceAndPercentChange ",
          style: const TextStyle(
            color: priceIncreaseColor,
            fontSize: 20,
            fontWeight: FontWeight.w200,
          ),
        ),
        const Text(
          "Today",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w200,
          ),
        ),
      ],
    );
  }
}

final _percentFormat = NumberFormat.decimalPercentPattern(decimalDigits: 2);
