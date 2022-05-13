import 'package:clone_tools/clone_tools.dart';
import 'package:flutter/material.dart';
import 'package:robinhood/crypto/crypto_theme.dart';
import 'package:robinhood/crypto/neon_horizon.dart';

class NeonHorizonDemo extends StatelessWidget {
  const NeonHorizonDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const DemoCard.wide(
      background: screenBackground,
      child: NeonHorizon(
        color: priceIncreaseColor,
        animate: true,
      ),
    );
  }
}
