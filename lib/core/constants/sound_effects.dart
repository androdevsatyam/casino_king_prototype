import 'package:flutter/services.dart';

/// Provides tactile haptic feedback mimicking real casino chips, reels, and wins
class CasinoAudioFeedback {
  static void buttonClick() {
    HapticFeedback.lightImpact();
  }

  static void chipBet() {
    HapticFeedback.selectionClick();
  }

  static void spinTick() {
    HapticFeedback.lightImpact();
  }

  static void winJackpot() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 150), () {
      HapticFeedback.heavyImpact();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      HapticFeedback.vibrate();
    });
  }

  static void coinCollect() {
    HapticFeedback.mediumImpact();
  }

  static void crashLoss() {
    HapticFeedback.heavyImpact();
  }
}
