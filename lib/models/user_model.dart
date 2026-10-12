class UserModel {
  final String id;
  final String username;
  final String phone;
  final double coinBalance;
  final int vipLevel;
  final int vipPoints;
  final bool isLoggedIn;
  final double totalWon;
  final double totalBet;

  const UserModel({
    required this.id,
    required this.username,
    required this.phone,
    required this.coinBalance,
    this.vipLevel = 1,
    this.vipPoints = 120,
    this.isLoggedIn = false,
    this.totalWon = 15400.0,
    this.totalBet = 12000.0,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? phone,
    double? coinBalance,
    int? vipLevel,
    int? vipPoints,
    bool? isLoggedIn,
    double? totalWon,
    double? totalBet,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      coinBalance: coinBalance ?? this.coinBalance,
      vipLevel: vipLevel ?? this.vipLevel,
      vipPoints: vipPoints ?? this.vipPoints,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      totalWon: totalWon ?? this.totalWon,
      totalBet: totalBet ?? this.totalBet,
    );
  }

  static UserModel guest() {
    return const UserModel(
      id: 'guest_8829',
      username: 'Guest Player',
      phone: '+91 98******12',
      coinBalance: 5000.0,
      vipLevel: 1,
      vipPoints: 150,
      isLoggedIn: false,
    );
  }
}
