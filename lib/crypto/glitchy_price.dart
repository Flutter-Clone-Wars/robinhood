import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:robinhood/currency.dart';

import 'crypto_theme.dart' as theme;

/// Displays a USD price and glitches whenever the price changes.
class GlitchyPrice extends StatefulWidget {
  const GlitchyPrice({
    Key? key,
    required this.price,
    required this.textStyle,
    this.priceIncreaseColor = theme.priceIncreaseColor,
    this.priceDecreaseColor = theme.priceDecreaseColor,
  }) : super(key: key);

  /// Price to display, in US dollars.
  final USD price;

  /// The base text style for the text that displays the price.
  final TextStyle textStyle;

  /// The color of the glitchy text when the price goes up.
  final Color priceIncreaseColor;

  /// The color of the glitchy text when the price goes down.
  final Color priceDecreaseColor;

  @override
  State<GlitchyPrice> createState() => _GlitchyPriceState();
}

class _GlitchyPriceState extends State<GlitchyPrice> with SingleTickerProviderStateMixin {
  static const _glitchDistance = 15.0;

  late _PriceGlitchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _PriceGlitchController(
      vsync: this,
      priceIncreaseColor: widget.priceIncreaseColor,
      priceDecreaseColor: widget.priceDecreaseColor,
    );
  }

  @override
  void didUpdateWidget(GlitchyPrice oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.price != oldWidget.price) {
      if (widget.price < oldWidget.price) {
        _controller.glitchNegative();
      } else {
        _controller.glitchPositive();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      // Dispose on next frame so that the AnimatedBuilder doesn't
      // throw exception when it de-registers its listener.
      _controller.dispose();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyText = widget.price.toFormattedString();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return _buildLeftGlitchText(currencyText);
          },
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return _buildRightGlitchText(currencyText);
          },
        ),
        // When we're not glitching, this is the only text that we see.
        _buildPrimaryText(currencyText),
      ],
    );
  }

  Widget _buildLeftGlitchText(String currencyText) {
    return Positioned(
      left: -_glitchDistance * _controller.leftGlitchPercent,
      child: Text(
        currencyText,
        style: widget.textStyle.copyWith(color: _controller.color.withOpacity(0.4)),
      ),
    );
  }

  Widget _buildRightGlitchText(String currencyText) {
    return Positioned(
      left: _glitchDistance * _controller.rightGlitchPercent,
      child: Text(
        currencyText,
        style: widget.textStyle.copyWith(color: _controller.color.withOpacity(0.4)),
      ),
    );
  }

  Widget _buildPrimaryText(String currencyText) {
    return Text(
      currencyText,
      style: widget.textStyle,
    );
  }
}

/// Controller that animates a glitch effect for a [GlitchyPrice].
class _PriceGlitchController with ChangeNotifier {
  _PriceGlitchController({
    required TickerProvider vsync,
    Duration glitchTime = const Duration(milliseconds: 500),
    required Color priceIncreaseColor,
    required Color priceDecreaseColor,
  })  : _glitchTime = glitchTime,
        _priceIncreaseColor = priceIncreaseColor,
        _priceDecreaseColor = priceDecreaseColor,
        _color = priceIncreaseColor {
    _ticker = vsync.createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker
      ..stop()
      ..dispose();
    super.dispose();
  }

  late final Ticker _ticker;
  final Duration _glitchTime;
  final Color _priceIncreaseColor;
  final Color _priceDecreaseColor;

  /// The color to use for the glitch text.
  Color get color => _color;
  Color _color;

  /// The left-sided glitch distance, as a percent.
  ///
  /// Clients should multiply this percent by a desired max glitch distance.
  double get leftGlitchPercent => _leftGlitchPercent;
  double _leftGlitchPercent = 0.0;

  /// The right-sided glitch distance, as a percent.
  ///
  /// Clients should multiply this percent by a desired max glitch distance.
  double get rightGlitchPercent => _rightGlitchPercent;
  double _rightGlitchPercent = 0.0;

  Duration _glitchStartTime = Duration.zero;
  Duration? _lastGlitchTime;
  // A random multiple applied to each side's jitter phase
  // length so that each side moves in a slightly different
  // manner.
  double _leftGlitchJitterAdjustment = 0.0;
  double _rightGlitchJitterAdjustment = 0.0;

  /// Animate a positive (price increase) glitch.
  void glitchPositive() {
    _color = _priceIncreaseColor;
    _glitch();
  }

  /// Animate a negative (price decrease) glitch.
  void glitchNegative() {
    _color = _priceDecreaseColor;
    _glitch();
  }

  void _glitch() {
    if (_lastGlitchTime != null) {
      // A glitch is on-going. Update tracking info to continue
      // using the on-going ticker.
      _glitchStartTime = _lastGlitchTime!;
      return;
    }

    _glitchStartTime = Duration.zero;
    final random = Random();
    _leftGlitchJitterAdjustment = random.nextDouble() * 2;
    _rightGlitchJitterAdjustment = random.nextDouble() * 2;
    _ticker.start();
  }

  void _onTick(Duration elapsedTime) {
    final dt = elapsedTime - _glitchStartTime;

    _leftGlitchPercent = _calculateJitterPercent(dt, _leftGlitchJitterAdjustment);
    _rightGlitchPercent = _calculateJitterPercent(dt, _rightGlitchJitterAdjustment);

    if (elapsedTime - _glitchStartTime > _glitchTime) {
      _ticker.stop();
      _lastGlitchTime = null;
    } else {
      _lastGlitchTime = elapsedTime;
    }

    notifyListeners();
  }

  double _calculateJitterPercent(Duration dt, double jitterPhaseAdjustment) {
    final cyclePercent = dt.inMilliseconds / _glitchTime.inMilliseconds;
    // Only cycle from 0.0 to pi because we only want the half of the
    // cycle that moves away from the origin and back.
    final cycleMotion = sin(cyclePercent * pi);
    final jitterMotion = sin(cyclePercent * 3 * jitterPhaseAdjustment * pi + (pi / 4));

    return cycleMotion * jitterMotion;
  }
}
