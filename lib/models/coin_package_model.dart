class CoinPackageModel {
  final String id;
  final String name;
  final double coinAmount;
  final double bonusCoins;
  final double priceINR;
  final String? badge;
  final bool isPopular;
  final String iconEmoji;

  const CoinPackageModel({
    required this.id,
    required this.name,
    required this.coinAmount,
    required this.bonusCoins,
    required this.priceINR,
    this.badge,
    this.isPopular = false,
    this.iconEmoji = '🪙',
  });

  double get totalCoins => coinAmount + bonusCoins;

  static List<CoinPackageModel> get packages => [
    const CoinPackageModel(
      id: 'pack_starter',
      name: 'Starter Chest',
      coinAmount: 1000,
      bonusCoins: 200,
      priceINR: 99,
      badge: '+20% BONUS',
      iconEmoji: '💰',
    ),
    const CoinPackageModel(
      id: 'pack_popular',
      name: 'Treasure Sack',
      coinAmount: 5000,
      bonusCoins: 1500,
      priceINR: 499,
      badge: 'MOST POPULAR',
      isPopular: true,
      iconEmoji: '💎',
    ),
    const CoinPackageModel(
      id: 'pack_high_roller',
      name: 'Royal Vault',
      coinAmount: 18000,
      bonusCoins: 6000,
      priceINR: 1499,
      badge: 'HOT DEAL 🔥',
      iconEmoji: '👑',
    ),
    const CoinPackageModel(
      id: 'pack_vip_king',
      name: 'Emperor\'s Hoard',
      coinAmount: 65000,
      bonusCoins: 25000,
      priceINR: 4999,
      badge: 'VIP SPECIAL',
      iconEmoji: '🏆',
    ),
    const CoinPackageModel(
      id: 'pack_mega_tycoon',
      name: 'Crown Jackpot',
      coinAmount: 150000,
      bonusCoins: 75000,
      priceINR: 9999,
      badge: '50% EXTRA FREE',
      iconEmoji: '✨',
    ),
  ];
}
