import 'dart:async';

import 'package:clone_tools/clone_tools.dart';
import 'package:flutter/material.dart';
import 'package:robinhood/crypto/coin_summary.dart';
import 'package:robinhood/crypto/crypto_theme.dart';
import 'package:robinhood/currency.dart';

class CryptoSummaryDemo extends StatefulWidget {
  const CryptoSummaryDemo({Key? key}) : super(key: key);

  @override
  _CryptoSummaryDemoState createState() => _CryptoSummaryDemoState();
}

class _CryptoSummaryDemoState extends State<CryptoSummaryDemo> {
  static const _btcPrices = [
    USD.fromCents(4013042),
    USD.fromCents(4018634),
    USD.fromCents(4018716),
    USD.fromCents(4010211),
    USD.fromCents(4020359),
    USD.fromCents(3999646),
    USD.fromCents(4029080),
    USD.fromCents(4017045),
    USD.fromCents(4012737),
    USD.fromCents(4026222),
    USD.fromCents(4021498),
    USD.fromCents(4022052),
    USD.fromCents(4014613),
    USD.fromCents(4019625),
    USD.fromCents(3999742),
    USD.fromCents(4048220),
  ];

  int _priceIndex = 0;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 1500), _shake);
  }

  void _shake() {
    if (mounted) {
      setState(() {
        _priceIndex = (_priceIndex + 1) % _btcPrices.length;
      });

      Timer(const Duration(milliseconds: 1500), _shake);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard.wide(
      background: screenBackground,
      child: Center(
        child: SizedBox(
          width: 300,
          child: CoinSummary(
            abbreviation: "BTC",
            name: "Bitcoin",
            price: _btcPrices[_priceIndex],
            deltaPrice: const USD.fromCents(45865),
            deltaPercent: 0.0115,
          ),
        ),
      ),
    );
  }
}
