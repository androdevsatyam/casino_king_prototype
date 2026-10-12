import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';
import '../models/coin_package_model.dart';
import '../models/bet_record_model.dart';
import '../core/constants/sound_effects.dart';

class CasinoState extends ChangeNotifier {
  UserModel _user = UserModel.guest();
  String _activeCategory = 'Hot';
  String _activeFilter = 'All Game';
  final Set<String> _favorites = {'aviator_pro', 'fortune_gems_500', 'fortune_777_slots'};
  final List<GameModel> _recentGames = [];
  final List<BetRecordModel> _betRecords = [];

  final List<String> _winnerTicker = [
    'player_7842 successfully withdraw ₹ 2,000',
    '79******49 successfully withdraw ₹ 3,000',
    '89******32 successfully withdraw ₹ 2,000',
    'rahul_win88 hit 25.4X in Aviator Pro ₹ 12,700',
    'vip_tiger7 hit Mega Jackpot in Fortune Gems ₹ 45,000',
    'lucky_star99 won ₹ 8,500 in Royal 777 Slots',
    'arjun_king successfully withdraw ₹ 10,000',
    'priya_88 cashed out at 48.2X in FlyX ₹ 24,100',
  ];

  Timer? _tickerTimer;
  bool _soundEnabled = true;

  CasinoState() {
    _initRecentGames();
    _startTickerSimulation();
  }

  UserModel get user => _user;
  double get coinBalance => _user.coinBalance;
  String get activeCategory => _activeCategory;
  String get activeFilter => _activeFilter;
  Set<String> get favorites => _favorites;
  List<BetRecordModel> get betRecords => List.unmodifiable(_betRecords);
  List<String> get winnerTicker => List.unmodifiable(_winnerTicker);
  bool get soundEnabled => _soundEnabled;

  void _initRecentGames() {
    _recentGames.addAll(GameModel.initialGames.take(3));
  }

  void _startTickerSimulation() {
    _tickerTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      final random = Random();
      final phonePrefix = 70 + random.nextInt(29);
      final phoneSuffix = 10 + random.nextInt(89);
      final amounts = [1000, 2000, 3000, 5000, 7500, 12000, 25000];
      final amt = amounts[random.nextInt(amounts.length)];
      
      final newNotice = random.nextBool()
          ? '$phonePrefix******$phoneSuffix successfully withdraw ₹ $amt'
          : 'player_${random.nextInt(9000) + 1000} won ₹ $amt in ${random.nextBool() ? "Aviator Pro" : "Fortune Gems"}';
      
      _winnerTicker.insert(0, newNotice);
      if (_winnerTicker.length > 25) {
        _winnerTicker.removeLast();
      }
      notifyListeners();
    });
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  void selectCategory(String category) {
    if (_activeCategory != category) {
      _activeCategory = category;
      CasinoAudioFeedback.buttonClick();
      notifyListeners();
    }
  }

  void selectFilter(String filter) {
    if (_activeFilter != filter) {
      _activeFilter = filter;
      CasinoAudioFeedback.buttonClick();
      notifyListeners();
    }
  }

  void toggleFavorite(String gameId) {
    if (_favorites.contains(gameId)) {
      _favorites.remove(gameId);
    } else {
      _favorites.add(gameId);
    }
    CasinoAudioFeedback.buttonClick();
    notifyListeners();
  }

  bool isFavorite(String gameId) => _favorites.contains(gameId);

  List<GameModel> get filteredGames {
    List<GameModel> list = GameModel.initialGames;

    // Filter by Tab (All Game, Favorite, Recent)
    if (_activeFilter == 'Favorite') {
      list = list.where((g) => _favorites.contains(g.id)).toList();
    } else if (_activeFilter == 'Recent') {
      list = _recentGames;
    }

    // Filter by Left Sidebar Category (Hot, Casino, Slots, Crash, Fishing, Games, Sports)
    if (_activeCategory == 'Hot') {
      list = list.where((g) => g.isHot || g.isNew).toList();
    } else {
      list = list.where((g) => g.category.toLowerCase() == _activeCategory.toLowerCase()).toList();
    }

    if (list.isEmpty) {
      // Fallback so user always sees games
      list = GameModel.initialGames;
    }

    return list;
  }

  void markGamePlayed(GameModel game) {
    _recentGames.removeWhere((g) => g.id == game.id);
    _recentGames.insert(0, game);
    if (_recentGames.length > 6) {
      _recentGames.removeLast();
    }
    notifyListeners();
  }

  bool placeBet(double amount) {
    if (_user.coinBalance < amount) {
      return false;
    }
    _user = _user.copyWith(
      coinBalance: _user.coinBalance - amount,
      totalBet: _user.totalBet + amount,
    );
    CasinoAudioFeedback.chipBet();
    notifyListeners();
    return true;
  }

  void settleBet({
    required String gameTitle,
    required double betAmount,
    required double winAmount,
    required double multiplier,
  }) {
    final bool isWin = winAmount > 0;
    final double newBalance = _user.coinBalance + winAmount;
    final int extraVip = (betAmount / 10).round();

    _user = _user.copyWith(
      coinBalance: newBalance,
      totalWon: _user.totalWon + winAmount,
      vipPoints: _user.vipPoints + extraVip,
      vipLevel: 1 + (_user.vipPoints ~/ 500),
    );

    _betRecords.insert(
      0,
      BetRecordModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        gameTitle: gameTitle,
        betAmount: betAmount,
        winAmount: winAmount,
        multiplier: multiplier,
        timestamp: DateTime.now(),
        isWin: isWin,
      ),
    );

    if (isWin) {
      CasinoAudioFeedback.winJackpot();
    }
    notifyListeners();
  }

  void purchaseCoins(CoinPackageModel package) {
    final double coinsToAdd = package.totalCoins;
    final int extraVip = (package.priceINR / 5).round();

    _user = _user.copyWith(
      coinBalance: _user.coinBalance + coinsToAdd,
      vipPoints: _user.vipPoints + extraVip,
      vipLevel: 1 + ((_user.vipPoints + extraVip) ~/ 500),
    );

    CasinoAudioFeedback.coinCollect();
    notifyListeners();
  }

  void claimDailyBonus(double amount) {
    _user = _user.copyWith(
      coinBalance: _user.coinBalance + amount,
    );
    CasinoAudioFeedback.coinCollect();
    notifyListeners();
  }

  void login({required String username, required String phone}) {
    _user = _user.copyWith(
      username: username.isEmpty ? 'RoyalPlayer_${Random().nextInt(9999)}' : username,
      phone: phone.isEmpty ? '+91 98765 43210' : phone,
      isLoggedIn: true,
      coinBalance: _user.coinBalance + 2000, // Sign-up bonus coins!
    );
    CasinoAudioFeedback.winJackpot();
    notifyListeners();
  }

  void logout() {
    _user = UserModel.guest();
    notifyListeners();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}
