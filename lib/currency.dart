import 'package:intl/intl.dart';

/// Currency amount in US dollars.
class USD implements Comparable<USD> {
  static final _currencyFormat = NumberFormat.currency(
    symbol: "\$",
    decimalDigits: 2,
  );

  /// Creates USD, whose total value is equal to the given [cents].
  const USD.fromCents(int cents) : _inCents = cents;

  /// Creates a USD, whose total value is the given [dollars] + the given [cents].
  const USD.fromDollarsAndCents({
    required int dollars,
    required int cents,
  }) : _inCents = (dollars * 100) + cents;

  final int _inCents;

  /// Returns the dollars portion of this USD, ignoring the [cents].
  int get dollars => _inCents ~/ 100;

  /// Returns the cents portion of this USD, ignoring the [dollars].
  int get cents => _inCents % 100;

  /// Returns the total value of this USD, represented as cents.
  int get inCents => _inCents;

  /// Returns the total value of this USD, as a dollar fraction, e.g.,
  /// `USD.fromCents(11530).asFraction` => `115.30`.
  double get asFraction => dollars + (cents / 100);

  /// Returns the value of this USD, as a traditionally formatted
  /// currency value, e.g., "$1,234.56".
  String toFormattedString() => _currencyFormat.format(asFraction);

  bool operator <(USD other) => _inCents < other._inCents;

  bool operator >(USD other) => _inCents > other._inCents;

  @override
  int compareTo(USD other) => _inCents.compareTo(other._inCents);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is USD && runtimeType == other.runtimeType && _inCents == other._inCents;

  @override
  int get hashCode => _inCents.hashCode;
}
