class BetRecordModel {
  final String id;
  final String gameTitle;
  final double betAmount;
  final double winAmount;
  final double multiplier;
  final DateTime timestamp;
  final bool isWin;

  const BetRecordModel({
    required this.id,
    required this.gameTitle,
    required this.betAmount,
    required this.winAmount,
    required this.multiplier,
    required this.timestamp,
    required this.isWin,
  });

  double get netProfit => winAmount - betAmount;
}
